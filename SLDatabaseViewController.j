
@import <Foundation/Foundation.j>
@import "Categories/CPSplitView+Categories.j"
@import "SJTableViewController.j"


@implementation SLDatabaseViewController : CPObject
{
    @outlet CPSplitView dbSplitView;
    CPTableView tableView;
    CPView contentView;
    SJTableViewController tableViewController;
}


- (void)setHidden:(BOOL)isHidden
{
  [dbSplitView setHidden:isHidden];
}

- (void)awakeFromCib
{
  [self setHidden:YES];
}

- (void)setContentView:(CPView)aView
{
  contentView = aView;
}

- (void)setupView
{ 
   [dbSplitView setFrame:CGRectMake(0, 0, [contentView bounds].size.width, [contentView bounds].size.height)];
   [dbSplitView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
   [self addTableStructure];
}

- (void)cibDidFailToLoad:(id)sender
{
  alert(@"Failed to load CIB");
}

- (void)addTableStructure
{  
  var topContentView = [dbSplitView viewAtIndex:0];
  var viewWidth = [contentView bounds].size.width;
  
  tableViewController = [[SJTableViewController alloc] initWithView:topContentView andWidth:viewWidth];
  
  if(contentView) {
    [contentView addSubview:dbSplitView];
  }
}

@end
