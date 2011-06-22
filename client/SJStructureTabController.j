@import <Foundation/Foundation.j>
@import "SJTabBaseController.j"
@import "Categories/CPSplitView+Categories.j"
@import "SJTableViewController.j"
@import "SJIndexesViewController.j"
@import "SJConstants.j"


@implementation SJStructureTabController : SJTabBaseController
{
    @outlet CPSplitView dbSplitView;
    SJTableViewController tableViewController;
    SJIndexesViewController indexesViewController;
    BOOL didAddSplitView;
}

- (void)viewDidSet
{
  [super viewDidSet];
  [self addTableStructure];
}


- (void)viewDidAdjust
{
  [super viewDidAdjust];
  var frame = [[self view] frame];
  [dbSplitView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
  [dbSplitView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  if (tableViewController) {
    [tableViewController adjustView];
  }
  if (indexesViewController) {
    [indexesViewController adjustView];
  }
}


- (void)viewWillAppear
{
  [super viewWillAppear];
}


- (void)addTableStructure
{
  var topContentView = [dbSplitView viewAtIndex:0];
  var bottomContentView = [dbSplitView viewAtIndex:1];
  var viewWidth = [[self view] bounds].size.width;
  
  tableViewController = [[SJTableViewController alloc] initWithView:topContentView andWidth:viewWidth];
  [tableViewController setTableName:[self tableName]];
  [tableViewController setTheWindow: [[self contentView] window] ];

  indexesViewController = [[SJIndexesViewController alloc] initWithView:bottomContentView andWidth:viewWidth];
  [indexesViewController setTableName:[self tableName]];
  [indexesViewController setTheWindow: [[self contentView] window] ];
  
  
  [[self view] addSubview:dbSplitView];
}

- (void)viewWillAppear
{
  [self requestTableData];
}

- (void)databaseTableSelected
{
  [self requestTableData];
}

- (void)setTableName:(CPString)name
{
  [super setTableName:name];
  [tableViewController setTableName:[self tableName]];
  [indexesViewController setTableName:[self tableName]];
  
  [tableViewController setTheWindow: [[self contentView] window] ];
  [indexesViewController setTheWindow: [[self contentView] window] ];
}

- (void)requestTableData
{
  if([self tableName]) {
    var httpRequest = [SJHTTPRequest requestWithURL:SERVER_BASE + "/schema/"+ [self tableName]];
    [httpRequest setParams: [[SJDataManager sharedInstance] credentials] ];
    [self connectionWithRequest:httpRequest];
  }
}


- (void)requestDidFinish:(id)js
{
  if (js.path.indexOf('/schema/') != -1) {
   [self handleSchemaResponse:js]; 
  }
  else if (js.path.indexOf('/indexes/') != -1) {
    [self handleIndexesResponse:js];
  }
}

- (void)requestDidFail:(id)js
{
  alert(js.error);
}

- (void)handleSchemaResponse:(id)js
{
  var httpRequest = [SJHTTPRequest requestWithURL:SERVER_BASE + "/indexes/"+ [self tableName]];
  [httpRequest setParams: [[SJDataManager sharedInstance] credentials] ];
  [self connectionWithRequest:httpRequest];
  
  [tableViewController setFields:js.fields];
  [tableViewController reloadData];
}

- (void)handleIndexesResponse:(id)js
{
  [indexesViewController setIndexes:js.indexes];
  [indexesViewController reloadData];
}

@end
