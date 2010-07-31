
@import <Foundation/CPObject.j>

@implementation SJLeftView : CPObject
{
  CPView theSuperView;
  CPTableView tableView;
  CPArray tableList;
}

- (id)initWithSuperView:(CPView)aSuperView
{
  if (self = [super init]) {
    theSuperView = aSuperView;
    [self setupView];
    tableList = [[CPArray alloc] init];
  
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(showDBTables:) name:@"kLoginSuccess" object:nil];
  }
  return self;
}

- (void)setupView
{
  var viewWidth = [theSuperView bounds].size.width;

 // create a CPScrollView that will contain the CPTableView
  var scrollView = [[CPScrollView alloc] initWithFrame:[theSuperView bounds]];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setAutohidesScrollers:YES];

  // create the CPTableView
  tableView = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
  [tableView setDataSource:self];
  [tableView setUsesAlternatingRowBackgroundColors:YES];

  var column = [[CPTableColumn alloc] initWithIdentifier:@"SJTableNames"];
  [[column headerView] setStringValue:@"Tables"];
  [column setWidth:(viewWidth - 15)];
  [tableView addTableColumn:column];
  
  [scrollView setDocumentView:tableView];
  [theSuperView addSubview:scrollView];
}


- (CPNumber)numberOfRowsInTableView:(CPTableView)aTableView
{
  return [tableList count];
}


- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)row
{
  return [tableList objectAtIndex:row];
}

// -- Show the Database Tables

- (void)showDBTables:(CPNotification)aNotification
{
  alert("Populate Tables");
}

@end
