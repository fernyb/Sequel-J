@import <Foundation/CPObject.j>
@import "SJHTTPRequest.j"
@import "SJConstants.j"


@implementation SJFavouritesListViewController : CPObject
{
  CPView		theSuperView;
  CPArray		favourites;
  CPTableView	tableView;
  CPURLConnection httpConnection;
  CPArray 		responseData;
}

- (id)initWithSuperView:(CPView)aSuperView
{
  if (self = [super init]) {
    theSuperView = aSuperView;
    [self setupView];
    responseData = [[CPArray alloc] init];
  }
  return self;
}

- (void)setupView
{
	
  favourites = [@"Local Machine", @"Rackspace Dedicated", @"CloudServers"];

  var viewWidth = [theSuperView bounds].size.width;

 // create a CPScrollView that will contain the CPTableView
  var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0,0,viewWidth,[theSuperView frame].size.height)];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setAutohidesScrollers:YES];
  [scrollView setHasHorizontalScroller:NO];
  [scrollView setBackgroundColor:[CPColor colorWithHexString:@"DEE4EA"]];
  
  // create the CPTableView
  tableView = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
  [tableView setDataSource:self];
  [tableView setDelegate:self];
  [tableView setColumnAutoresizingStyle:CPTableViewLastColumnOnlyAutoresizingStyle];
  [tableView setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleSourceList];
  [tableView setCornerView:nil];
  [tableView setBackgroundColor:[CPColor colorWithHexString:@"DEE4EA"]];
  [tableView setRowHeight:20];
  
  var column = [[CPTableColumn alloc] initWithIdentifier:@"SJFavouritName"];
  [[column headerView] setStringValue:@"FAVOURITES"];
  [column setWidth:(viewWidth - 15)];
  
  [[column headerView] setValue:[CPColor colorWithHexString:@"DEE4EA"] forThemeAttribute:@"background-color"];
  [[column headerView] setValue:[CPColor colorWithHexString:@"626262"] forThemeAttribute:@"text-color"];
  [[column headerView] setValue:[CPFont boldSystemFontOfSize:12] forThemeAttribute:@"text-font"];
  
  [tableView addTableColumn:column];
  
  [scrollView setDocumentView:tableView];
  
  [theSuperView addSubview:scrollView];
  
  [tableView reloadData];
}


- (CPNumber)numberOfRowsInTableView:(CPTableView)aTableView
{
  return [favourites count];
}


- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)row
{
  return [favourites objectAtIndex:row];
}

@end
