
@import <Foundation/Foundation.j>
@import "Categories/CPSplitView+Categories.j"
@import "SJHTTPRequest.j"
@import "SJDataManager.j"


@implementation SJTableViewController : CPObject 
{
  CPView contentView;
  CPTableView tableView;
  CGFloat viewWidth;
  CPURLConnection httpRequest;
  CPArray tableList;
  CPArray responseData;
}


- (id)initWithView:(CPView)aView  andWidth:(CGFloat)aWidth
{
  [self init];
  contentView = aView;
  viewWidth = aWidth;
  tableList = [[CPArray alloc] init];
  responseData = [[CPArray alloc] init];
  
  [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectDatabaseTable:) name:@"SJSelectedDBTableRow" object:nil];

  [self setupView];
  return self;
}

- (void)setupView
{
  var scrollview = [self addTableView];
  [contentView addSubview:scrollview];
}

- (CPScrollView)addTableView
{
   // create a CPScrollView that will contain the CPTableView
  var scrollView = [[CPScrollView alloc] initWithFrame:[contentView bounds]];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setAutohidesScrollers:YES];

  // create the CPTableView
  tableView = [[CPTableView alloc] initWithFrame:[contentView bounds]];
  [tableView setDataSource:self];
  [tableView setUsesAlternatingRowBackgroundColors:YES];
  
  var widthOfHeader = (viewWidth - 15) / [[self headerNames] count];
  for(var i=0; i<[[self headerNames] count]; i++) {
    var columnName = [[self headerNames] objectAtIndex:i];
    var column = [[CPTableColumn alloc] initWithIdentifier:[CPString stringWithFormat:@"SJTableColumn%@", columnName]];
    [[column headerView] setStringValue:columnName];
    [column setWidth:widthOfHeader];
    [tableView addTableColumn:column];
  }
  
  [scrollView setDocumentView:tableView];
  
  return scrollView;
}


- (CPArray)headerNames
{
  return ["Field", "Type", "Length", "Unsigned", "Zerofill", "Binary", "Allow Null", "Key", "Default", "Extra"];
}

- (CPNumber)numberOfRowsInTableView:(CPTableView)aTableView
{
  return [tableList count];
}


- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPNumber)row
{
  var field = [tableList objectAtIndex:row];
  
  switch([aTableColumn identifier]) {
   case @"SJTableColumnField" :
    return field.field;
   break; 
  
   case @"SJTableColumnType" :
    return field.type;
   break;
  
   case @"SJTableColumnLength" :
    return @"";
   break;
  
   case @"SJTableColumnKey" :
    return field.key;
   break;
  
   case @"SJTableColumnExtra" :
    return field.extra;
   break;

 
   case @"SJTableColumnAllow Null" :
    return field['null'];
   break;
  
   case @"SJTableColumnDefault" :
    return field['default'];
   break;
   
   default :
    return @"";
   break;
  }
}

- (void)didSelectDatabaseTable:(CPNotification)aNotification
{
  var httpRequest = [SJHTTPRequest requestWithURL:"http://localhost:3000/columns/" + [aNotification object]];
  [httpRequest setParams: [[SJDataManager sharedInstance] credentials] ];
  
  httpConnection = [CPURLConnection connectionWithRequest:[httpRequest toRequest] delegate:self];
}


- (void)handleBadResponse:(id)jsObject
{
  alert(jsObject.message);
}

- (void)handleGoodResponse:(id)jsObject
{
  for(var i=0; i < jsObject.rows.length; i++) {
    [tableList addObject:jsObject.rows[i]];
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

  [tableList removeAllObjects];
  [responseData removeAllObjects];
    
  if(json['error'] == "true") {
    [self handleBadResponse:json];
  } else {
    [self handleGoodResponse:json];
  }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
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