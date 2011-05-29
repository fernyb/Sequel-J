@import <Foundation/Foundation.j>
@import "Categories/CPArray+Categories.j"


@implementation SJIndexesViewController : CPObject 
{
  CPView contentView;
  CPTableView tableView;
  CGFloat viewWidth;
  CPArray indexes;
}


- (id)initWithView:(CPView)aView  andWidth:(CGFloat)aWidth
{
  [self init];
  contentView = aView;
  viewWidth = aWidth;
  
  [self setupView];
  return self;
}

- (void)setIndexes:(CPArray)idxs
{
  indexes = idxs;
}

- (void)reloadData
{
  [tableView reloadData];
}

- (void)setupView
{
  indexes = [[CPArray alloc] init];
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

- (CPArray)headerNames
{
  return ["Non_unique", "Key_name", "Seq_in_index", "Column_name", "Collation", "Cardinality", "Sub_part", "Packed", "Comment"];
}

- (CPNumber)numberOfRowsInTableView:(CPTableView)aTableView
{
  return [indexes count];
}


- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPNumber)row
{
  var field = [indexes objectAtIndex:row];
  
  switch([aTableColumn identifier]) {
    case @"SJTableColumnNon_unique" :
      return field['Non_unique'];
    break;
    case @"SJTableColumnKey_name" :
      return field['Key_name']
    break;
    case @"SJTableColumnSeq_in_index" :
      return field['Seq_in_index'];
    break;
    case @"SJTableColumnColumn_name" :
      return field['Column_name'];
    break;
    case @"SJTableColumnCollation" :
      return field['Collation'];
    break;
    case @"SJTableColumnCardinality" :
      return field['Cardinality'];
    break;
    case @"SJTableColumnSub_part" :
      return field['Sub_part'];
    break;
    case @"SJTableColumnPacked" :
      return field['Packed'];
    break;
    case @"SJTableColumnComment" :
      return field['Comment'];
    break;
    default :
      return @"";
    break;
  }
}

@end