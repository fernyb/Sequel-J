
@import <Foundation/Foundation.j>
@import "Categories/CPSplitView+Categories.j"


@implementation SLDatabaseViewController : CPObject
{
    @outlet CPSplitView dbSplitView;
    CPTableView tableView;
    CPView contentView;
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

- (void)showTableStructure
{
  [dbSplitView setHidden:NO];
}

- (void)cibDidFailToLoad:(id)sender
{
  alert(@"Failed to load CIB");
}

- (void)addTableStructure
{  
  var topView = [dbSplitView viewAtIndex:0];
  var viewWidth = [contentView bounds].size.width;

 // create a CPScrollView that will contain the CPTableView
  var scrollView = [[CPScrollView alloc] initWithFrame:[topView bounds]];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setAutohidesScrollers:YES];

  // create the CPTableView
  tableView = [[CPTableView alloc] initWithFrame:[topView bounds]];
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
  
  // Add the ScrollView to the TopView
  [topView addSubview:scrollView];
  
  if(contentView) {
    [contentView addSubview:dbSplitView];
  }
}

- (CPArray)headerNames
{
  return ["Field", "Type", "Length", "Unsigned", "Zerofill", "Binary", "Allow Null", "Key", "Default", "Extra"];
}

- (CPNumber)numberOfRowsInTableView:(CPTableView)aTableView
{
  return 1;
}


- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPNumber)row
{
  if([aTableColumn identifier] === @"SJTableStructure") {
    return @"id";
  }
  return @"aValue";
}

@end
