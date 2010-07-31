
@import <Foundation/CPObject.j>
@import "SJHTTPRequest.j"


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
  
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(showDBTables:) name:@"kShowDatabaseTables" object:nil];
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
  [tableView setUsesAlternatingRowBackgroundColors:YES];

  var column = [[CPTableColumn alloc] initWithIdentifier:@"SJTableNames"];
  [[column headerView] setStringValue:@"Tables"];
  [column setWidth:(viewWidth - 15)];
  [tableView addTableColumn:column];
  
  [scrollView setDocumentView:tableView];
  [theSuperView addSubview:scrollView];
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
  var httpRequest = [SJHTTPRequest requestWithURL:"http://localhost:3000/tables"];
  [httpRequest setParams: [[SJDataManager sharedInstance] credentials] ];
  
  httpConnection = [CPURLConnection connectionWithRequest:[httpRequest toRequest] delegate:self];
}


- (void)handleBadResponse:(id)jsObject
{
  alert(jsObject.message);
}

- (void)handleGoodResponse:(id)jsObject
{
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
  
  if(json['error'] == "true") {
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
