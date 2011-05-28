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

  CPLog(@"SJStructureTabController, View Did Set");
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
  indexesViewController = [[SJIndexesViewController alloc] initWithView:bottomContentView andWidth:viewWidth];

  [[self view] addSubview:dbSplitView];
}

@end
