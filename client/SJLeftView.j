@import <Foundation/CPObject.j>
@import "SJHTTPRequest.j"
@import "SJConstants.j"


@implementation SJLeftView : CPObject
{
  CPView theSuperView;
  CPTableView tableView;
  CPArray tableList;
  CPURLConnection httpConnection;
  CPArray responseData;
}

- (id)initWithSuperView:(CPView)aSuperView
{
  if (self = [super init]) {
    theSuperView = aSuperView;
    [self setupView];
    tableList = [[CPArray alloc] init];
    responseData = [[CPArray alloc] init];

    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(showDBTables:) name:SHOW_DATABASE_TABLES_NOTIFICATION object:nil];
  }
  return self;
}

- (void)setupView
{
  var viewWidth = [theSuperView bounds].size.width;

 // create a CPScrollView that will contain the CPTableView
  var scrollView = [[CPScrollView alloc] initWithFrame:[theSuperView bounds]];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setAutohidesScrollers:YES];

  // create the CPTableView
  tableView = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
  [tableView setDataSource:self];
  [tableView setDelegate:self];
  [tableView setUsesAlternatingRowBackgroundColors:YES];

  var column = [[CPTableColumn alloc] initWithIdentifier:@"SJTableNames"];
  [[column headerView] setStringValue:@"Tables"];
  [column setWidth:(viewWidth - 15)];
  [tableView addTableColumn:column];
  
  [scrollView setDocumentView:tableView];
  [theSuperView addSubview:scrollView];
}


- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(CPInteger)aRow
{
  // FIXME: Find out what 'SJSelectedDBTableRow' notification does...
  // [[CPNotificationCenter defaultCenter] postNotificationName:@"SJSelectedDBTableRow" object:[tableList objectAtIndex:aRow]];
  var tablename = [tableList objectAtIndex:aRow];
  [[CPNotificationCenter defaultCenter] postNotificationName:TABLE_SELECTED_NOTIFICATION object:tablename];

 return YES;
}


- (CPNumber)numberOfRowsInTableView:(CPTableView)aTableView
{
  return [tableList count];
}


- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)row
{
  return [tableList objectAtIndex:row];
}


// -- Show the Database Tables

- (void)showDBTables:(CPNotification)aNotification
{
  var httpRequest = [SJHTTPRequest requestWithURL:SERVER_BASE + "/tables"];
  [httpRequest setParams: [[SJDataManager sharedInstance] credentials] ];

  var dbName = [aNotification object];
  if(dbName && dbName != null && dbName != 'undefined' && dbName != "" && [dbName length] > 0) {
    [httpRequest setObject:dbName forKey:@"database"];
  }

 if ([httpRequest objectForKey:@"database"] === "") {
   return;
 }

  httpConnection = [CPURLConnection connectionWithRequest:[httpRequest toRequest] delegate:self];
}


- (void)handleBadResponse:(id)jsObject
{
  alert(jsObject.error);
}

- (void)handleGoodResponse:(id)jsObject
{
  [tableList removeAllObjects];
  for(var i=0; i < jsObject.tables.length; i++) {
    [tableList addObject:jsObject.tables[i]];
  }
  [tableView reloadData];
}

/*
*
* CPURLConnection Methods
*
*/

- (void)connectionDidFinishLoading:(CPURLConnection)connection
{
  var json = JSON.parse([responseData componentsJoinedByString:@""]);
  response = nil;
  [responseData removeAllObjects];

  if(json['error'] != '') {
    [self handleBadResponse:json];
  } else {
    [self handleGoodResponse:json];
  }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
  //This method is called when a connection receives a response. in a
  //multi-part request, this method will (eventually) be called multiple times,
  //once for each part in the response.
  
  [responseData addObject:data];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    //This method is called if the request fails for any reason.
    alert("Connection Failed: " + error);
}

- (void)clearConnection:(CPURLConnection)aConnection
{
    //we no longer need to hold on to a reference to this connection
    if (aConnection == httpConnection)
        httpConnection = nil;
}

@end
