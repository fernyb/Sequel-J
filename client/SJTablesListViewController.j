@import <Foundation/CPObject.j>
@import "SJHTTPRequest.j"
@import "SJConstants.j"
@import "SJTableListItemDataView.j"


@implementation SJTablesListViewController : CPObject
{
  CPView		theSuperView;
  CPTableView 	tableView;
  CPArray 		tableList;
  CPArray		filteredTableList;
  CPURLConnection httpConnection;
  CPArray 		responseData;
  CPSearchField	tableFilterSearchField;
  CPButtonBar	bottomButtonBar;
}

- (id)initWithSuperView:(CPView)aSuperView
{
  if (self = [super init]) {
    theSuperView = aSuperView;
    [self setupView];
    tableList = [[CPArray alloc] init];
    filteredTableList = [[CPArray alloc] init];
    responseData = [[CPArray alloc] init];

    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(showDBTables:) name:SHOW_DATABASE_TABLES_NOTIFICATION object:nil];
  }
  return self;
}

- (void)setupView
{
  var viewWidth = [theSuperView bounds].size.width;

 // create a CPScrollView that will contain the CPTableView
  var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0,35,viewWidth,[theSuperView frame].size.height - 35 - 23)];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setAutohidesScrollers:YES];
  [scrollView setHasHorizontalScroller:NO];
  [scrollView setBackgroundColor:[CPColor colorWithHexString:@"DEE4EA"]];
  
  // create the filter earch field
  tableFilterSearchField = [[CPSearchField alloc] initWithFrame:CGRectMake(4,2,viewWidth-8,30)];
  [tableFilterSearchField setPlaceholderString:@"Filter"];
  [tableFilterSearchField setAutoresizingMask:CPViewWidthSizable];
  [tableFilterSearchField setTarget:self];
  [tableFilterSearchField setAction:@selector(tableFilterSearchFieldDidChange:)];
  [tableFilterSearchField setSendsSearchStringImmediately:YES];
  
  // create the CPTableView
  tableView = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
  [tableView setDataSource:self];
  [tableView setDelegate:self];
  [tableView setColumnAutoresizingStyle:CPTableViewLastColumnOnlyAutoresizingStyle];
  [tableView setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleSourceList];
  [tableView setCornerView:nil];
  [tableView setBackgroundColor:[CPColor colorWithHexString:@"DEE4EA"]];
  [tableView setAllowsEmptySelection:NO];
  [tableView setRowHeight:20];
  
  var column = [[CPTableColumn alloc] initWithIdentifier:@"SJTableNames"];
  [[column headerView] setStringValue:@"TABLES"];
  [column setWidth:(viewWidth - 15)];
  [column setDataView:[[SJTableListItemDataView alloc] initWithFrame:CGRectMake(0,0,viewWidth,20)]];
  
  [[column headerView] setValue:[CPColor colorWithHexString:@"DEE4EA"] forThemeAttribute:@"background-color"];
  [[column headerView] setValue:[CPColor colorWithHexString:@"626262"] forThemeAttribute:@"text-color"];
  [[column headerView] setValue:[CPFont boldSystemFontOfSize:12] forThemeAttribute:@"text-font"];
  
  [tableView addTableColumn:column];
  
  [scrollView setDocumentView:tableView];
  
  // create the bottom button bar
  bottomButtonBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(0,[theSuperView frame].size.height-23, viewWidth, 23)];
  [bottomButtonBar setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];

  var addButton = [CPButtonBar plusButton];
  [addButton setAction:@selector(showAddTableDialog:)];
  [addButton setTarget:self];
  [addButton setEnabled:YES];
  
  var settingsButton = [CPButtonBar actionPopupButton];
  [settingsButton setAction:@selector(showSettingsPopup:)];
  [settingsButton setTarget:self];
  [settingsButton setEnabled:YES];
  [settingsButton addItemsWithTitles:[@"Rename Table...", @"Duplicate Table..."]];
  
   var refreshButton = [CPButtonBar plusButton];
  [refreshButton setAction:@selector(refreshTables:)];
  [refreshButton setTarget:self];
  [refreshButton setEnabled:YES];
  
  [bottomButtonBar setButtons:[addButton, settingsButton, refreshButton]];
  
  [theSuperView addSubview:scrollView];
  [theSuperView addSubview:tableFilterSearchField];
  [theSuperView setBackgroundColor:[CPColor colorWithHexString:@"DEE4EA"]];
  [theSuperView addSubview:bottomButtonBar];
  
  [[theSuperView superview] setButtonBar:bottomButtonBar forDividerAtIndex:0];
}


- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(CPInteger)aRow
{
  // FIXME: Find out what 'SJSelectedDBTableRow' notification does...
  // [[CPNotificationCenter defaultCenter] postNotificationName:@"SJSelectedDBTableRow" object:[tableList objectAtIndex:aRow]];
  var tablename = [filteredTableList objectAtIndex:aRow];
  [[CPNotificationCenter defaultCenter] postNotificationName:TABLE_SELECTED_NOTIFICATION object:tablename];

 return YES;
}


- (CPNumber)numberOfRowsInTableView:(CPTableView)aTableView
{
  return [filteredTableList count];
}


- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)row
{
  return [filteredTableList objectAtIndex:row];
}


// -- Show the Database Tables

- (void)showDBTables:(CPNotification)aNotification
{
  var dbName = [aNotification object]
  
  if( !dbName )
  	return;
  
  [[[SJAPIRequest sharedAPIRequest] credentials] setObject:dbName forKey:@"database"];
  
  [[SJAPIRequest sharedAPIRequest] sendRequestToTablesWithOptions:nil callback:function( jsObject ) 
  {
	[tableList removeAllObjects];

	for(var i=0; i < jsObject.tables.length; i++) {
    	[tableList addObject:jsObject.tables[i]];
	}
  
	filteredTableList = [tableList copy];
  
	[tableView reloadData];
  }];
}

- (@action)tableFilterSearchFieldDidChange:(id)sender
{
	var count = [tableList count];
	var searchString = [tableFilterSearchField stringValue];
	
	// if there is no search, fill the array and return
	if( searchString == @"" )
	{
		filteredTableList = [tableList copy];
		[tableView reloadData];
		return;
	}
	
	[filteredTableList removeAllObjects];
	
	for( var i = 0; i < count; i++ ) 
	{
		var range = [[tableList objectAtIndex:i] rangeOfString:searchString options:CPCaseInsensitiveSearch];
		
		if( range.length )
			[filteredTableList addObject:[tableList objectAtIndex:i]];
	}
	
	[tableView reloadData];
}

- (@action)showAddTableDialog:(id)sender
{
	alert( 'Add Table' );
}

- (@action)refreshTables:(id)sender
{
	alert( "Refresh Tables" );
}

/*
*
* CPURLConnection Methods
*
*/

- (void)connectionDidFinishLoading:(CPURLConnection)connection
{
  var json = JSON.parse([responseData componentsJoinedByString:@""]);
  response = nil;
  [responseData removeAllObjects];

  if(json['error'] != '') {
    [self handleBadResponse:json];
  } else {
    [self handleGoodResponse:json];
  }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
  //This method is called when a connection receives a response. in a
  //multi-part request, this method will (eventually) be called multiple times,
  //once for each part in the response.
  
  [responseData addObject:data];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    //This method is called if the request fails for any reason.
    alert("Connection Failed: " + error);
}

- (void)clearConnection:(CPURLConnection)aConnection
{
    //we no longer need to hold on to a reference to this connection
    if (aConnection == httpConnection)
        httpConnection = nil;
}

@end
