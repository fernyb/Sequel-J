
@import <Foundation/Foundation.j>
@import "Categories/CPSplitView+Categories.j"
@import "Categories/CPArray+Categories.j"
@import "SJHTTPRequest.j"
@import "SJDataManager.j"
@import "SJConstants.j"


@implementation SJTableViewController : CPObject 
{
  CPView contentView;
  CPTableView tableView;
  CGFloat viewWidth;
  CPArray tableList;
}


- (id)initWithView:(CPView)aView  andWidth:(CGFloat)aWidth
{
  [self init];
  contentView = aView;
  viewWidth = aWidth;
  tableList = [[CPArray alloc] init];
  responseData = [[CPArray alloc] init];
  
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

- (void)adjustView
{
  var columns = [tableView tableColumns];
  var columnWidth = ([tableView frame].size.width - 15) / [columns count];
  [columns map:function(column) {
    [column setWidth:columnWidth];
  }];
}

- (void)setFields:(CPArray)fields
{
  tableList = fields;
}

- (void)reloadData
{
  [tableView reloadData];
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
    return field['Field'];
   break; 
  
   case @"SJTableColumnType" :
    return field['Type'];
   break;
  
   case @"SJTableColumnLength" :
    return field['Length'];
   break;
  
   case @"SJTableColumnKey" :
    return field['Key'];
   break;
  
   case @"SJTableColumnExtra" :
    return field['Extra'];
   break;

 
   case @"SJTableColumnAllow Null" :
    return field['Null'];
   break;
  
   case @"SJTableColumnDefault" :
    return field['Default'];
   break;
   
   default :
    return @"";
   break;
  }
}


@end