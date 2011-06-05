
@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"

@implementation SJContentTabController : SJTabBaseController
{
  CPScrollView scrollview;
  CPArray headerNames;
  CPArray tbrows;
  CPString cachedTableName;
  CPButtonBar bottomBar;
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
    
    var rect = [scrollview frame];
    rect.size.height -= 23.0;
    
    [scrollview setFrame:rect];
    [[self view] addSubview:scrollview];
    
    [self addBottomBarWithRect:rect];
    
    // We need to get the rows for the table, lets do that here
    var httpRequest = [SJHTTPRequest requestWithURL:SERVER_BASE + "/rows/"+ [self tableName]];
    [httpRequest setParams: [[SJDataManager sharedInstance] credentials] ];
    [self connectionWithRequest:httpRequest];
  }
}

- (void)addBottomBarWithRect:(CGRect)rect
{
  if(bottomBar) return;
  
  var originY = rect.size.height;
  bottomBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(0, originY, rect.size.width, 23.0)];    
  [bottomBar setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
  
  var img = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"button_bar_spacer.png"]];
  [bottomBar setValue:[CPColor colorWithPatternImage:img] forThemeAttribute:@"bezel-color"];
  [bottomBar setValue:[CPColor colorWithPatternImage:img] forThemeAttribute:@"button-bezel-color" inState:CPThemeStateNormal];
  // TODO: add in the alternate image
  [bottomBar setValue:[CPColor colorWithPatternImage:img] forThemeAttribute:@"button-bezel-color" inState:CPThemeStateHighlighted];
  
  [[self view] addSubview:bottomBar];
  
  var addButton = [CPButtonBar plusButton];
  [addButton setAction:@selector(addRow:)];
  [addButton setTarget:self];
  [addButton setEnabled:YES];
  
  var minusButton = [CPButtonBar minusButton];
  [minusButton setAction:@selector(removeRow:)];
  [minusButton setTarget:self];
  [minusButton setEnabled:YES];
  
  [bottomBar setButtons:[addButton, minusButton]];
  [bottomBar setHasResizeControl:NO];
}

- (void)addRow:(id)sender
{
  alert('Add Row');
}

- (void)removeRow:(id)sender
{
  alert('Remove Row');
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
