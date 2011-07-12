@import <Foundation/CPObject.j>
@import "SJHTTPRequest.j"
@import "SJConstants.j"
@import "SJTableListItemDataView.j"
@import "SJAPIRequest.j"
@import "Categories/CPAlert+Categories.j"
@import "SJDuplicateTableWindowController.j"
@import "SJRenameTableWindowController.j"


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
  CPString databaseName @accessors;
  
  CPWindow addTableWindow;
  CPTextField fieldTableName;
  CPPopUpButton fieldTableType;
  CPPopUpButton fieldTableEncoding;
  CPArray characterSets @accessors;
  SJDuplicateTableWindowController duptableWinController;
}

- (id)initWithSuperView:(CPView)aSuperView
{
  if (self = [super init]) {
    theSuperView = aSuperView;
    characterSets = [CPArray array];
    [self setupView];
    tableList = [[CPArray alloc] init];
    filteredTableList = [[CPArray alloc] init];
    responseData = [[CPArray alloc] init];

    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(showDBTables:) name:SHOW_DATABASE_TABLES_NOTIFICATION object:nil];
  }
  return self;
}

- (CPView)contentView
{
  return theSuperView;
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
  [settingsButton setAction:@selector(settingsItemSelectedAction:)];
  [settingsButton setTarget:self];
  [settingsButton setEnabled:YES];
  [settingsButton addItemsWithTitles:[@"Rename Table...", @"Duplicate Table...", @"Truncate Table", @"Remove Table"]];
  
   var refreshButton = [CPButtonBar plusButton];
  [refreshButton setAction:@selector(refreshTables:)];
  [refreshButton setTarget:self];
  [refreshButton setEnabled:YES];
  var refreshImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"refresh-icon.png"] size:CGSizeMake(14, 15)];
  [refreshButton setImage:refreshImage];
  [refreshButton setImagePosition:CPImageOnly];
  
  [bottomButtonBar setButtons:[addButton, settingsButton, refreshButton]];
  
  [theSuperView addSubview:scrollView];
  [theSuperView addSubview:tableFilterSearchField];
  [theSuperView setBackgroundColor:[CPColor colorWithHexString:@"DEE4EA"]];
  [theSuperView addSubview:bottomButtonBar];
  
  [[theSuperView superview] setButtonBar:bottomButtonBar forDividerAtIndex:0];
}


- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(CPInteger)aRow
{
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
  databaseName = [aNotification object];
  if (!databaseName)
    return;

  [[CPNotificationCenter defaultCenter] postNotificationName:DATABASE_SELECTED_NOTIFICATION object:databaseName];
  [self loadDatabaseTables];
}

- (void)loadDatabaseTables
{
  [[[SJAPIRequest sharedAPIRequest] credentials] setObject:[self databaseName] forKey:@"database"];
  [[SJAPIRequest sharedAPIRequest] requestTablesForDatabase:[self databaseName] callback:function( js) {
    if(js.error == '') {
      [tableList removeAllObjects];
      for(var i=0; i < js.tables.length; i++) {
    	  [tableList addObject:js.tables[i]];
	    }
	    filteredTableList = [tableList copy];
	    [tableView reloadData];
    } else {
      console.log(js.error);
    }
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
  if (!addTableWindow) {
    addTableWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(30,30, 360, 160) styleMask:CPDocModalWindowMask];
    var addContentView = [addTableWindow contentView];
    
    var labelTableName = [[CPTextField alloc] initWithFrame:CGRectMake(20, 20, 110, 20)];
    [labelTableName setAlignment:CPRightTextAlignment];
    [labelTableName setStringValue:@"Table Name:"];
    [labelTableName setFont:[CPFont boldSystemFontOfSize:12.0]];
    [addContentView addSubview:labelTableName];
    
    fieldTableName = [[CPTextField alloc] initWithFrame:CGRectMake(132, 16, 205, 28)];
    [fieldTableName setAlignment:CPLeftTextAlignment];
    [fieldTableName setStringValue:@""];  
    [fieldTableName setEditable:YES];
    [fieldTableName setEnabled:YES];
    [fieldTableName setBezeled:YES];
    [fieldTableName setFont:[CPFont boldSystemFontOfSize:12.0]];
    [addContentView addSubview:fieldTableName];
    
    // ---
    var labelTableEncoding = [[CPTextField alloc] initWithFrame:CGRectMake(20, (24 * 2) + 2, 110, 20)];
    [labelTableEncoding setAlignment:CPRightTextAlignment];
    [labelTableEncoding setStringValue:@"Table Encoding:"];
    [labelTableEncoding setFont:[CPFont boldSystemFontOfSize:12.0]];
    [addContentView addSubview:labelTableEncoding];

    fieldTableEncoding = [[CPPopUpButton alloc] initWithFrame:CGRectMake(135, (24 * 2) - 2, 200, 24)];
    [fieldTableEncoding setTarget:self];
	  [fieldTableEncoding setAction:@selector(selectedTableEncoding:)];
	  [fieldTableEncoding setTitle:@"Default"];
	  if([characterSets count] > 0) {
      [fieldTableEncoding addItem:[CPMenuItem separatorItem]];
    }
	  for(var i=0; i<[characterSets count]; i++) {
	    var item = [characterSets objectAtIndex:i];
      var name = item['Description'] +" ("+ item['Charset'] +")";
	    [fieldTableEncoding addItemWithTitle:name];
	  }
    [addContentView addSubview:fieldTableEncoding];
    
    // -----
    var labelTableType = [[CPTextField alloc] initWithFrame:CGRectMake(20, (26 * 3) + 2, 110, 20)];
    [labelTableType setAlignment:CPRightTextAlignment];
    [labelTableType setStringValue:@"Table Type:"];
    [labelTableType setFont:[CPFont boldSystemFontOfSize:12.0]];
    [addContentView addSubview:labelTableType];
    
    fieldTableType = [[CPPopUpButton alloc] initWithFrame:CGRectMake(135, (26 * 3) - 2, 200, 24)];
    [fieldTableType setTarget:self];
	  [fieldTableType setAction:@selector(selectedTableType:)];
	  [fieldTableType setTitle:@"Default"];
	  var types = [self tableTypes];
	  if([types count] > 0) {
      [fieldTableType addItem:[CPMenuItem separatorItem]];
    }
    for(var i=0; i<[types count]; i++) {
       [fieldTableType addItemWithTitle:[types objectAtIndex:i]];
    }
    [addContentView addSubview:fieldTableType];
    
    var cancelBtn = [[CPButton alloc] initWithFrame:CGRectMake(225, (30 * 4) - 3, 0, 0)];
    [cancelBtn setTitle:@"Cancel"];
    [cancelBtn sizeToFit];
    [cancelBtn setTarget:self];
    [cancelBtn setAction:@selector(didClickCancelAction:)];
    [addContentView addSubview:cancelBtn];
    
    var saveBtn = [[CPButton alloc] initWithFrame:CGRectMake(292, (30 * 4) - 3, 0, 0)];
    [saveBtn setTitle:@" Add "];
    [saveBtn sizeToFit];
    [saveBtn setTarget:self];
    [saveBtn setAction:@selector(didClickAddTableAction:)];
    [addContentView addSubview:saveBtn];
  }

  [CPApp beginSheet: addTableWindow
          modalForWindow: [[self contentView] window]
           modalDelegate: self
          didEndSelector: null
             contextInfo: null];  
}

- (void)selectedTableEncoding:(CPPopUpButton)sender
{
  // console.log("Selected Table Encoding");
}

- (void)selectedTableType:(CPPopUpButton)sender
{
  // console.log("Selected Table Type");
}

- (void)didClickCancelAction:(CPButton)sender
{
  [self endAddTableWindowSheet];
}

- (void)didClickAddTableAction:(CPButton)sender
{
  var newTableName = [fieldTableName stringValue];
  var selectedEncodingIndex = [fieldTableEncoding selectedIndex] - 2;
  var selectedTableTypeIndex = [fieldTableType selectedIndex] - 2;
  
  var selectedEncoding = {'Charset' : ''};
  if (selectedEncodingIndex > 0) {
    selectedEncoding = [characterSets objectAtIndex:selectedEncodingIndex];
  }
  
  var selectedTableType = '';
  if (selectedTableTypeIndex > 0) {
    selectedTableType = [[self tableTypes] objectAtIndex:selectedTableTypeIndex];
  }
  
  var params = [CPDictionary dictionary];
  [params setObject:selectedEncoding['Charset'] forKey:@"table_encoding"];
  [params setObject:selectedTableType forKey:@"table_type"];
  
  [[SJAPIRequest sharedAPIRequest] sendRequestAddTable:newTableName query:params callback:function (js) {
    if(js.error == '') {
      [tableList removeAllObjects];
      for(var i=0; i < js.tables.length; i++) {
    	  [tableList addObject:js.tables[i]];
	    }
	    filteredTableList = [tableList copy];
	    [tableView reloadData];
    } else {
      console.log(js.error);
    }
    
    [self endAddTableWindowSheet];
  }];
}

- (void)endAddTableWindowSheet
{
  [CPApp endSheet:addTableWindow returnCode:CPCancelButton];
}

- (@action)refreshTables:(id)sender
{
  [self loadDatabaseTables];
}

- (CPArray)tableTypes
{
  return [@"InnoDB", @"MRG_MYISAM", @"BLACKHOLE", @"CSV", @"MEMORY", @"ARCHIVE", @"MyISAM"];
}

- (void)settingsItemSelectedAction:(id)sender
{
  var item = [sender selectedItem];
  
  switch([item title]) {
    case @"Remove Table" :
      [self removeTable];
    break;
    case @"Truncate Table" :
      [self truncateTable];
    break;
    case @"Duplicate Table..." :
      [self duplicateTable];
    break;
    case @"Rename Table..." :
      [self renameTable];
    break;
  }
}

- (CPString)selectedTableName
{
  var selectedRow = [tableView selectedRow];
  if (selectedRow == -1) {
    return @"";
  }
 return [tableList objectAtIndex:selectedRow];
}

- (void)renameTable
{
  var tableName = [self selectedTableName];
  if(tableName == @"") return;
  
  if(!duptableWinController) {
    duptableWinController = [[SJRenameTableWindowController alloc] init];
  }
  [duptableWinController setTableName:tableName];
  [duptableWinController setParentController:self];
  [duptableWinController willDisplayController];
  
  [CPApp beginSheet: [duptableWinController window]
        modalForWindow: [[self contentView] window]
         modalDelegate: self
        didEndSelector: null
           contextInfo: null];
}

- (void)renameTableComplete:(id)js
{
  if (js.error == '') {
    [tableList removeAllObjects];
    tableList = [js.tables copy];
    filteredTableList = [tableList copy];
    [tableView reloadData];
  } else {
    console.log(js.error);
  }  
}

- (void)duplicateTable
{
  var tableName = [self selectedTableName];
  if(tableName == @"") return;
  
  if(!duptableWinController) {
    duptableWinController = [[SJDuplicateTableWindowController alloc] init];
  }
  [duptableWinController setTableName:tableName];
  [duptableWinController setParentController:self];
  [duptableWinController willDisplayController];
  
  [CPApp beginSheet: [duptableWinController window]
        modalForWindow: [[self contentView] window]
         modalDelegate: self
        didEndSelector: null
           contextInfo: null];
}

- (void)duplicateTableComplete:(id)js
{
  if (js.error == '') {
    [tableList removeAllObjects];
    tableList = [js.tables copy];
    filteredTableList = [tableList copy];
    [tableView reloadData];
  } else {
    console.log(js.error);
  }
}


- (void)truncateTable
{
  var tableName = [self selectedTableName];
  if (tableName == @"") {
    return;
  }
  
  var didEndCallback = function (returnCode, contextInfo) {
    if(returnCode == 0) {
      [[SJAPIRequest sharedAPIRequest] sendRequestTruncateTable:tableName callback:function (js) {
        if(js.error == '') {
          [tableList removeAllObjects];
          tableList = [js.tables copy];
          filteredTableList = [tableList copy];
          [tableView reloadData];
        } else {
          console.log(js.error);
        }
      }];
    }
  };
  
  var alert = [CPAlert new];
  [alert addButtonWithTitle:@"Truncate"];    
  [alert addButtonWithTitle:@"Cancel"];
  [alert setMessageText:@"Truncate table '"+ tableName +"'?"];
  [alert setInformativeText:@"Are you sure you want to truncate the table '"+ tableName +"'? This action cannot be undone."];
  [alert setAlertStyle:CPWarningAlertStyle];
  [alert beginSheetModalForWindow:[[self contentView] window]
                    modalDelegate:self 
                    didEndCallback:didEndCallback
                    contextInfo:nil];
}

- (void)removeTable
{  
  var selectedRow = [tableView selectedRow];
  if (selectedRow == -1) {
    return;
  }
  var tableName = [tableList objectAtIndex:selectedRow];
  
  var didEndCallback = function (returnCode, contextInfo) {
    if(returnCode == 0) {
      [[SJAPIRequest sharedAPIRequest] sendRequestRemoveTable:tableName callback:function (js) {
        if(js.error == '') {
          [tableList removeAllObjects];
          tableList = [js.tables copy];
          filteredTableList = [tableList copy];
          [tableView reloadData];
          [tableView selectRowIndexes:[CPIndexSet indexSetWithIndex:-1] byExtendingSelection:NO];
          [[CPNotificationCenter defaultCenter] postNotificationName:TABLE_SELECTED_NOTIFICATION object:nil];

        } else {
          console.log(js.error);
        }
      }];
    }
  };
 
  var alert = [CPAlert new];
  [alert addButtonWithTitle:@"Delete"];    
  [alert addButtonWithTitle:@"Cancel"];
  [alert setMessageText:@"Delete table '"+ tableName +"'?"];
  [alert setInformativeText:@"Are you sure you want to delete the table '"+ tableName +"'? This action cannot be undone."];
  [alert setAlertStyle:CPWarningAlertStyle];
  [alert beginSheetModalForWindow:[[self contentView] window]
                    modalDelegate:self 
                    didEndCallback:didEndCallback
                    contextInfo:nil];
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
