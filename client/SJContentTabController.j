
@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"

@implementation SJContentTabController : SJTabBaseController
{
  CPScrollView scrollview;
  CPArray headerNames;
  CPArray tbrows;
  CPString cachedTableName;
}

- (void)viewWillAppear
{
  if (cachedTableName != [self tableName]) {
   cachedTableName = [self tableName];
   [self databaseTableSelected];
  }
}

- (void)databaseTableSelected
{
  [self fetchHeaderNamesForTableName:[self tableName]];
}

- (void)fetchHeaderNamesForTableName:(CPString)tableName
{
  CPLog("Fetch Header Names For Table Name: "+ tableName);
  
  if(tableName == null || tableName == 'undefined' || tableName == '') {
    return;
  }

  var httpRequest = [SJHTTPRequest requestWithURL:SERVER_BASE + "/header_names/"+ tableName];
  [httpRequest setParams: [[SJDataManager sharedInstance] credentials] ];

  [self connectionWithRequest:httpRequest];
}

- (void)requestDidFail:(id)js
{
  alert(js.error);
}

- (void)requestDidFinish:(id)js
{
  if (js.path.indexOf('/header_names') != -1) {
    [self handleHeaderNamesResponse:js];
  } 
  else if (js.path.indexOf('/rows') != -1) {
    [self handleTableRowsResponse:js];
  }
}

- (void)handleHeaderNamesResponse:(id)js
{
  if(scrollview) {
    [self setTbrows:[CPArray array]];
    [[self tableView] reloadData];
    [scrollview removeFromSuperview];
    scrollview = nil;
  }

  if (!scrollview) {
    headerNames = [[CPArray alloc] initWithArray:js.header_names];
    scrollview = [self createTableViewForView:[self view] headerNames:[self headerNames]];
    [[self view] addSubview:scrollview];
    
    // We need to get the rows for the table, lets do that here
    var httpRequest = [SJHTTPRequest requestWithURL:SERVER_BASE + "/rows/"+ [self tableName]];
    [httpRequest setParams: [[SJDataManager sharedInstance] credentials] ];
    [self connectionWithRequest:httpRequest];
  }
}



- (void)handleTableRowsResponse:(id)js
{
  [self setTbrows:js.rows];
  [[self tableView] reloadData];
}


- (CPArray)headerNames
{
  return headerNames;
}

- (CPArray)tbrows
{
  if(!tbrows) {
    [self setTbrows:[[CPArray alloc] init]];
  }
  return tbrows;
}

- (void)setTbrows:(CPArray)trows
{
  tbrows = trows;
}

- (CPInteger)numberOfRowsInTableView:(CPTableView)aTableView
{
  return [[self tbrows] count];
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)rowIndex
{
  var rowData = [[self tbrows] objectAtIndex:rowIndex];
  var headerName = [[aTableColumn headerView] stringValue];

  return rowData[headerName];
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{
 return YES;
}


@end
