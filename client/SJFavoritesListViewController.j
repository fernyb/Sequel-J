@import <Foundation/CPObject.j>
@import "SJHTTPRequest.j"
@import "SJConstants.j"
@import "SJFavoritesController.j"


@implementation SJFavoritesListViewController : CPObject
{
  CPView		theSuperView;
  CPTableView	tableView;
  CPURLConnection httpConnection;
  CPArray 		responseData;
}

- (id)initWithSuperView:(CPView)aSuperView
{
	if (self = [super init]) 
	{
	  theSuperView = aSuperView;
	  [self setupView];
	  responseData = [[CPArray alloc] init];
	}
	
	[[CPNotificationCenter defaultCenter] addObserver:tableView selector:@selector(reloadData) name:@"didAddFavorite" object:nil];
	
	return self;
}

- (void)setupView
{
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
	[tableView setDoubleAction:@selector(tableViewWasDoubleClicked:)];
	[tableView setTarget:self];
	
	var column = [[CPTableColumn alloc] initWithIdentifier:@"SJFavouritName"];
	[[column headerView] setStringValue:@"FAVORITES"];
	[column setWidth:(viewWidth - 15)];
	
	[[column headerView] setValue:[CPColor colorWithHexString:@"DEE4EA"] forThemeAttribute:@"background-color"];
	[[column headerView] setValue:[CPColor colorWithHexString:@"626262"] forThemeAttribute:@"text-color"];
	[[column headerView] setValue:[CPFont boldSystemFontOfSize:12] forThemeAttribute:@"text-font"];
	
	[tableView addTableColumn:column];
	
	[scrollView setDocumentView:tableView];
	
	[theSuperView addSubview:scrollView];
}


- (CPNumber)numberOfRowsInTableView:(CPTableView)aTableView
{
	return [[[SJFavoritesController sharedFavoritesController] favorites] count];
}


- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)row
{
  return [[[[SJFavoritesController sharedFavoritesController] favorites] objectAtIndex:row] nodeName];
}

- (void)tableViewSelectionDidChange:(CPNotification)notification
{
    var row = [tableView selectedRow];
	
	if( row == -1 )
		return;
	
	var favoriteNode = [[[SJFavoritesController sharedFavoritesController] favorites] objectAtIndex:row];
		
	[[SJLoginViewController sharedLoginViewController] populateWithConnectionDetails:[favoriteNode nodeConnectionDetails] name:[favoriteNode nodeName]];
}

- (void)tableViewWasDoubleClicked:aTableView
{
	if( [tableView clickedRow] == -1 )
		return;
	
	[[SJLoginViewController sharedLoginViewController] connectionButtonPressed:self];
}

@end
