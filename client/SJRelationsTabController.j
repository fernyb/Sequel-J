
@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"
@import "Categories/CPTableView+Categories.j"


@implementation SJRelationsTabController : SJTabBaseController
{
}

// View Did Set is only called when the [self view] is set.
- (void)viewDidSet
{
  [super viewDidSet];
  [self addTableStructure];
}

- (void)addTableStructure
{
  var scrollview = [self createTableViewForView:[self view] headerNames:[self headerNames]];
  // After we create the TableView we add it to the view as a subview.
  [[self view] addSubview:scrollview];
}

- (CPArray)headerNames
{
  return [@"Name", @"Columns", @"FK Table", @"FK Columns", @"On Update", @"On Delete"];
}

- (void)viewDidAdjust
{
  [[self tableView] adjustColumnsToFit];
}

@end
