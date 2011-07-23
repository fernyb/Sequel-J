@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"
@import "Categories/CPDictionary+Categories.j"
@import "Categories/CPArray+Categories.j"
@import "Categories/CPAlert+Categories.j"
@import "SJContentPrefWindowController.j"


@implementation SJContentTabController : SJTabBaseController
{
  CPScrollView scrollview;
  CPArray headerNames;
  CPArray columnFields;
  CPArray tbrows;
  CPString cachedTableName;
  CPButtonBar bottomBar;
  BOOL clickedAddRow;
  CPInteger newRowAtIndex;
  CPTextField labelTableInfo;
  CPInteger totalRows;
  SJContentPrefWindowController prefWindow;
}

- (void)viewWillAppear
{
  if (cachedTableName != [self tableName]) {
   cachedTableName = [self tableName];
   [self databaseTableSelected];
  }
}

- (void)viewDidSet
{
}

- (CPString)limitKey
{
  var key = @"ContentTab_limit_"+ [self databaseHost] +"_"+ [self databaseName] +"_"+ [self tableName];
  return key;
}

- (CPString)offsetKey
{
  var key = @"ContentTab_offset_"+ [self databaseHost] +"_"+ [self databaseName] +"_"+ [self tableName];
  return key;
}

- (CPInteger)limit
{
  var key = [self limitKey];
  var limit = [[CPUserDefaults standardUserDefaults] objectForKey:key];
  if(!limit) {
    limit = 100;
    [self setLimit:limit];
  }
  return (typeof(limit) == "number" ? limit : parseInt(limit));
}

- (CPInteger)offset
{
  var key = [self offsetKey];
  var offset = [[CPUserDefaults standardUserDefaults] objectForKey:key]; 
  if(!offset) {
    offset = 0;
    [self setOffset:offset];
  } 
  return (typeof(offset) == "number" ? offset : parseInt(offset));
}

- (void)setOffset:(CPInteger)anOffset
{
  var key = [self offsetKey];
  [[CPUserDefaults standardUserDefaults] setObject:anOffset forKey:key];
}

- (void)setLimit:(CPInteger)aLimit
{
  var key = [self limitKey];
  [[CPUserDefaults standardUserDefaults] setObject:aLimit forKey:key];
}

- (CPString)deferLoadingKey
{
  var key = @"ContentTab_deferLoading_"+ [self databaseHost] +"_"+ [self databaseName] +"_"+ [self tableName];
  return key;
}

- (void)setDeferLoadingBlobsAndText:(BOOL)b
{
  var key = [self deferLoadingKey];
  [[CPUserDefaults standardUserDefaults] setObject:b forKey:key];
}

- (BOOL)deferLoadingBlobsAndText
{
  var key = [self deferLoadingKey];
  var defer = [[CPUserDefaults standardUserDefaults] objectForKey:key];
  defer = defer == YES ? YES : NO;
  [self setDeferLoadingBlobsAndText:defer];
  return defer;
}

- (void)databaseTableSelected
{
  [self fetchHeaderNamesForTableName:[self tableName]];
}

- (void)fetchHeaderNamesForTableName:(CPString)tableName
{
  CPLog("Fetch Header Names For Table Name: "+ tableName);
  
  if(tableName == null || tableName == 'undefined' || tableName == '') {
    headerNames = [];
    tbrows = [];
    [self setTbrows:nil];
    [[self tableView] reloadData];
    return;
  }
  
  [[SJTaskProgressWindowController sharedTaskProgressWindowController] showTaskProgressWindowForTitle:@"Fetching results..." withCancelCallback:function() {}];

  [[SJAPIRequest sharedAPIRequest] sendRequestToEndpoint:@"schema" tableName:tableName callback:function ( js ) 
  {
  	if(scrollview) {
      [self setTbrows:[CPArray array]];
      [[self tableView] reloadData];
      [scrollview removeFromSuperview];
      scrollview = nil;
    }
    
    if (!scrollview) {
      columnFields = js.fields;
      
      var names = [columnFields collect:function (f) {
        return f['Field'];
      }];
    
      scrollview = [self createTableViewForView:[self view] headerFields:columnFields];
      
      var rect = [scrollview frame];
      rect.size.height -= 23.0;
      
      [scrollview setFrame:rect];
      [[self view] addSubview:scrollview];
      [[self tableView] setDelegate:self];
      
      var columns = [[self tableView] tableColumns];
      for(var i=0; i<[columns count]; i++) {
        [[columns objectAtIndex:i] setEditable:YES];
      }
      
      [self addBottomBarWithRect:rect];
      
      // We need to get the rows for the table, lets do that here
      var params = [CPDictionary dictionary];
      [params setObject:[self deferLoadingBlobsAndText] forKey:@"defer_blob_text"];
      [params setObject:[self offset] forKey:@"offset"];
      [params setObject:[self limit] forKey:@"limit"];

      [[SJAPIRequest sharedAPIRequest] sendRequestTableRows:tableName query:params callback:function (js) {
        [self handleTableRowsResponse:js];
        [[SJTaskProgressWindowController sharedTaskProgressWindowController] hideTaskProgressWindowForCurrentTask];
      }];
    }
  
  }];
}

- (void)addBottomBarWithRect:(CGRect)rect
{
  if(bottomBar) return;
  
  var originY = rect.size.height;
  bottomBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(0, originY, rect.size.width, 23.0)];    
  [bottomBar setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
  
  [[self view] addSubview:bottomBar];
  
  var addButton = [CPButtonBar plusButton];
  [addButton setAction:@selector(addRow:)];
  [addButton setTarget:self];
  [addButton setEnabled:YES];
  
  var minusButton = [CPButtonBar minusButton];
  [minusButton setAction:@selector(removeRow:)];
  [minusButton setTarget:self];
  [minusButton setEnabled:YES];
  
  var duplicateButton = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
  var duplicateImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"duplicate-icon.png"] size:CGSizeMake(13, 8)];
  [duplicateButton setBordered:NO];
  [duplicateButton setTarget:self];
  [duplicateButton setAction:@selector(duplicateRowAction:)];
  [duplicateButton setImage:duplicateImage];
  [duplicateButton setImagePosition:CPImageOnly];
  
  var refreshBtn = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
  var refreshImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"refresh-icon.png"] size:CGSizeMake(14, 15)];
  [refreshBtn setBordered:NO];
  [refreshBtn setTarget:self];
  [refreshBtn setAction:@selector(refreshAction:)];
  [refreshBtn setImage:refreshImage];
  [refreshBtn setImagePosition:CPImageOnly];
  
  [bottomBar setButtons:[addButton, minusButton, duplicateButton, refreshBtn]];
  
    
  labelTableInfo = [[CPTextField alloc] initWithFrame:CGRectMake(35 * [[bottomBar buttons] count], 4, 300,20)];
  [labelTableInfo setStringValue:@""];
  [labelTableInfo setEditable:NO];
  [labelTableInfo setFont:[CPFont systemFontOfSize:11.0]];
  [bottomBar addSubview:labelTableInfo];
  
  /**
  * Show the previous, pref & next navigation buttons
  */
  var pagePrefButton = [[CPButton alloc] initWithFrame:CGRectMake(([bottomBar frame].size.width - (35 * 2)) + 1, 1, 35, 25)];
  var pagePrefButtonImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:[CPButtonBar class]] pathForResource:@"action_button.png"] size:CGSizeMake(22, 14)];
  [pagePrefButton setBordered:NO];
  [pagePrefButton setTarget:self];
  [pagePrefButton setAction:@selector(pagePrefButtonAction:)];
  [pagePrefButton setImage:pagePrefButtonImage];
  [pagePrefButton setImagePosition:CPImageOnly];

  var nextPageButton = [[CPButton alloc] initWithFrame:CGRectMake([bottomBar frame].size.width - 35, 1, 35, 25)];
  var nextPageImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"arrow_right.png"] size:CGSizeMake(11, 14)];
  [nextPageButton setBordered:NO];
  [nextPageButton setTarget:self];
  [nextPageButton setAction:@selector(nextPageAction:)];
  [nextPageButton setImage:nextPageImage];
  [nextPageButton setImagePosition:CPImageOnly];
  
  var prevPageButton = [[CPButton alloc] initWithFrame:CGRectMake(([bottomBar frame].size.width - (35 * 3)) + 2, 1, 35, 25)];
  var prevPageImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"arrow_left.png"] size:CGSizeMake(11, 14)];
  [prevPageButton setBordered:NO];
  [prevPageButton setTarget:self];
  [prevPageButton setAction:@selector(prevPageAction:)];
  [prevPageButton setImage:prevPageImage];
  [prevPageButton setImagePosition:CPImageOnly];
  
  
  var normalColor  = [bottomBar valueForThemeAttribute:@"button-bezel-color" inState:CPThemeStateNormal],
  highlightedColor = [bottomBar valueForThemeAttribute:@"button-bezel-color" inState:CPThemeStateHighlighted],
  disabledColor    = [bottomBar valueForThemeAttribute:@"button-bezel-color" inState:CPThemeStateDisabled],
  textColor        = [bottomBar valueForThemeAttribute:@"button-text-color" inState:CPThemeStateNormal];

  var pageBtns = [prevPageButton, pagePrefButton, nextPageButton];
  
  for(var i=0; i<[pageBtns count]; i++) {
    var button = [pageBtns objectAtIndex:i];
    var buttonHeight = CGRectGetHeight([button bounds]) - 1;
    
    [button setFrame:CGRectMake([button frame].origin.x, 1, [button frame].size.width, buttonHeight)];
    
    [button setBordered:YES];
    [button setValue:normalColor forThemeAttribute:@"bezel-color" inState:CPThemeStateNormal | CPThemeStateBordered];
    [button setValue:highlightedColor forThemeAttribute:@"bezel-color" inState:CPThemeStateHighlighted | CPThemeStateBordered];
    [button setValue:disabledColor forThemeAttribute:@"bezel-color" inState:CPThemeStateDisabled | CPThemeStateBordered];
    [button setValue:textColor forThemeAttribute:@"text-color" inState:CPThemeStateBordered];

    [bottomBar addSubview:button];
  }
  // end next, pref & prev page buttons
  
  [bottomBar setHasResizeControl:NO];
}

- (CPInteger)totalRows
{
  return totalRows;
}

- (void)nextPageAction:(CPButton)sender
{
  var newOffset = [self offset] + [self limit];
  if (newOffset <= totalRows) {
    [self setOffset:newOffset];

    var row = [[self tableView] selectedRow];
    if (row != CPNotFound) {
      [[self tableView] deselectRow:row];
    }
    [self refreshAction:sender];
    [[self tableView] scrollRowToVisible:0];
  }
}

- (void)prevPageAction:(CPButton)sender
{
  var newOffset = [self offset] - [self limit];
  if (newOffset <= totalRows && newOffset >= 0) {
    [self setOffset:newOffset];

    var row = [[self tableView] selectedRow];
    if (row != CPNotFound) {
      [[self tableView] deselectRow:row];
    }
    [self refreshAction:sender];
    [[self tableView] scrollRowToVisible:0];
  }
}

- (void)pagePrefButtonAction:(CPButton)sender
{
  if(!prefWindow) {
    prefWindow = [[SJContentPrefWindowController alloc] initWithParentController:self];
  }
 [prefWindow willDisplayController];

  [CPApp beginSheet: [prefWindow window]
          modalForWindow: [[self contentView] window]
           modalDelegate: self
          didEndSelector: null
             contextInfo: null];  
}


- (void)addRow:(id)sender
{
  var defaultValueForName = function(aName) {
    for(var i=0; i<[columnFields count]; i++) {
      var item = [columnFields objectAtIndex:i];
      if (item['Field'] == aName) {
        return item['Default'];
      }
    }
    return null;
  };
  
  var columns = [[self tableView] tableColumns];
    
  if([columns count] > 0) {
    var newRow = {};

    for(var i=0; i<[columns count]; i++) {
      var column = [columns objectAtIndex:i];  
      var columnName = [[column headerView] stringValue];
      var columnValue = defaultValueForName(columnName);
      newRow[columnName] = columnValue;
    }

    [[self tbrows] addObject:newRow];
    [[self tableView] reloadData];
    [[self tableView] selectRowIndexes:[CPIndexSet indexSetWithIndex:([[self tbrows] count] - 1)] byExtendingSelection:NO];
    [[self tableView] editColumn:0 row:([[self tbrows] count] - 1) withEvent:nil select:YES];
    clickedAddRow = YES;
    newRowAtIndex = [[self tbrows] count] - 1;
  }
}


- (void)removeRow:(id)sender
{
  var selectedRow = [[self tableView] selectedRow];
  if (selectedRow == CPNotFound) {
    return;
  }
  
  var didEndCallback = function (returnCode, contextInfo) {
    if (returnCode == 0) {
      var rowIndex = [[self tableView] selectedRow];
      var rowData = [[self tbrows] objectAtIndex:rowIndex];

      var columns = [[self tableView] tableColumns];
      var where_fields = [CPArray array];

      for(var i=0; i<[columns count]; i++) {
        var column = [columns objectAtIndex:i];
        var columnName = [[column headerView] stringValue];
        var rowValue = rowData[columnName];
  
        var field_kv = [CPDictionary dictionaryWithObjectsAndKeys: columnName, @"name", rowValue, @"value"];
        [where_fields addObject:field_kv];
      }

      var params = [CPDictionary dictionary];
      [params setObject:where_fields forKey:@"where_fields"];
      [params setObject:[self offset] forKey:@"offset"];
      [params setObject:[self limit] forKey:@"limit"];
      [params setObject:[self deferLoadingBlobsAndText] forKey:@"defer_blob_text"];
      
      [[SJAPIRequest sharedAPIRequest] sendRemoveTableRow:[self tableName] query:params callback:function (js) {
        if (js.error =='') {
          var row = [[self tableView] selectedRow];
          if (row != CPNotFound) {
            [[self tableView] deselectRow:row];
          }
          
          [self handleTableRowsResponse:js];
        } else {
          console.log(js.error)
        }
      }];
    }
  };
  
  var alert = [CPAlert new];
  [alert addButtonWithTitle:@"Delete"];    
  [alert addButtonWithTitle:@"Cancel"];
  [alert setMessageText:@"Delete selected row?"];
  [alert setInformativeText:@"Are you sure you want to delete the selected row from this table? This action cannot be undone."];
  [alert setAlertStyle:CPWarningAlertStyle];
  [alert beginSheetModalForWindow:[[self contentView] window]
                  modalDelegate:self 
                  didEndCallback:didEndCallback
                  contextInfo:nil];
}


- (void)duplicateRowAction:(CPButton)sender
{
  var selectedRow = [[self tableView] selectedRow];
  if (selectedRow != CPNotFound) {
    [self duplicateRowAtIndex:selectedRow];
  }
}

- (void)refreshWithOffset:(CPInteger)anOffset withLimit:(CPInteger)aLimit
{
  [self setOffset:anOffset];
  [self setLimit:aLimit];
  [self refreshAction:nil];  
}

- (void)refreshAction:(CPButton)sender
{
  var params = [CPDictionary dictionary];
  [params setObject:[self offset] forKey:@"offset"];
  [params setObject:[self limit] forKey:@"limit"];
  [params setObject:[self deferLoadingBlobsAndText] forKey:@"defer_blob_text"];
  
  [[SJAPIRequest sharedAPIRequest] sendRequestTableRows:[self tableName] query:params callback:function (js) {
  	[self handleTableRowsResponse:js];
  }];
}

- (void)handleTableRowsResponse:(id)js
{
  [self setTbrows:js.rows];
  [[self tableView] reloadData];
  
  var rowscount = parseInt(js.rows.length);
  totalRows = parseInt(js.total_rows);
  
  if(totalRows > [self limit]) {
    [labelTableInfo setStringValue:"Rows "+ ([self offset] + 1) +" - "+ ([self offset] + [self limit]) +" of "+ totalRows +" from table"];
  } 
  else if (rowscount >= 0) {
    [labelTableInfo setStringValue:rowscount + " rows in table"]; 
  }
}


- (CPArray)headerNames
{
  return headerNames;
}

- (CPArray)tbrows
{
  if(!tbrows) {
    [self setTbrows:[[CPArray alloc] init]];
  }
  return tbrows;
}

- (void)setTbrows:(CPArray)trows
{
  tbrows = trows;
}

- (CPInteger)numberOfRowsInTableView:(CPTableView)aTableView
{
  return [[self tbrows] count];
}

- (BOOL)tableView:(CPTableView)aTableView shouldEditTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
  var alertEndedCallback = function(returnCode, contextInfo) {
    // we will do nothing for now... 
  };

  if ([self deferLoadingBlobsAndText]) {
    var alert = [CPAlert new];
    [alert addButtonWithTitle:@"OK"];
    [alert setInformativeText:@"You cannot edit table when blob and text are hidden."];
    [alert setMessageText:@"Error trying to edit."];
    [alert setAlertStyle:CPWarningAlertStyle];
    [alert beginSheetModalForWindow:[[self contentView] window]
                      modalDelegate:self 
                     didEndCallback:alertEndedCallback
                        contextInfo:nil];
    return NO;
  }
  return YES;
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)rowIndex
{
  var rowData = [[self tbrows] objectAtIndex:rowIndex];
  var headerName = [[aTableColumn headerView] stringValue];
  
  return rowData[headerName] > '' ? rowData[headerName].replace(/(\r\n|\n|\r)/gm,"") : rowData[headerName];
}

- (void)tableView:(CPTableView)aTableView setObjectValue:(id)anObject forTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{ 
  if(clickedAddRow == @"YES") {
    return;
  }

  var rowData = [[self tbrows] objectAtIndex:rowIndex];
  var header_name = [[aTableColumn headerView] stringValue];

  var columns = [[self tableView] tableColumns];
  var where_fields = [CPArray array];
  
  for(var i=0; i<[columns count]; i++) {
    var column = [columns objectAtIndex:i];
    var columnName = [[column headerView] stringValue];
    
    var rowValue = rowData[columnName];

    var field_kv = [CPDictionary dictionaryWithObjectsAndKeys: columnName, @"name", rowValue, @"value"];
    [where_fields addObject:field_kv];
  }
  
  var params = [CPDictionary dictionary];
  [params setObject:header_name forKey:@"field_name"];
  [params setObject:anObject forKey:@"field_value"];
  [params setObject:where_fields forKey:@"where_fields"];
  [params setObject:(clickedAddRow ? @"YES" : @"NO") forKey:@"add_row"];

  [params setObject:[self deferLoadingBlobsAndText] forKey:@"defer_blob_text"];
  [params setObject:[self offset] forKey:@"offset"];
  [params setObject:[self limit] forKey:@"limit"];
  
  rowData[header_name] = anObject;
 
  [[SJAPIRequest sharedAPIRequest] sendUpdateTable:[self tableName] query:params callback:function (js) {
    if (js.error =='') {
      [self handleTableRowsResponse:js];
    } else {
      console.log(js.error)
    }
  }];
}


- (void)tableView:(CPTableView)aTableView sortDescriptorsDidChange:(CPArray)oldDescriptors
{
    var newDescriptors = [aTableView sortDescriptors],
    	newDescriptor = [newDescriptors objectAtIndex:0];
    
    var options = [[CPDictionary alloc] initWithObjects:[[self tableName], [newDescriptor key], [newDescriptor ascending] ? @"ASC" : @"DESC"] forKeys:[@"table", @"order_by", @"order"]];
    
	[[SJTaskProgressWindowController sharedTaskProgressWindowController] showTaskProgressWindowForTitle:@"Sorting results..." withCancelCallback:function() {}];

    [[SJAPIRequest sharedAPIRequest] sendRequestToEndpoint:@"rows" withOptions:options callback:function( js ) 
  	{
		[[SJTaskProgressWindowController sharedTaskProgressWindowController] hideTaskProgressWindowForCurrentTask];
		[self handleTableRowsResponse:js];
    }];
      
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{
 return YES;
}


- (void)tableViewSelectionDidChange:(CPNotification)notification
{
  if(clickedAddRow == YES) {
    [self sendUpdatedRowAtIndex:newRowAtIndex];
  }
  
  clickedAddRow = NO;
  newRowAtIndex = -1;
}


- (void)sendUpdatedRowAtIndex:(CPInteger)rowIndex
{
  var rowData = [[self tbrows] objectAtIndex:rowIndex];
  var columns = [[self tableView] tableColumns];
  var where_fields = [CPArray array];
  
  for(var i=0; i<[columns count]; i++) {
    var column = [columns objectAtIndex:i];
    var columnName = [[column headerView] stringValue];
    var rowValue = rowData[columnName];
    
    var field_kv = [CPDictionary dictionaryWithObjectsAndKeys: columnName, @"name", rowValue, @"value"];
    [where_fields addObject:field_kv];
  }
  
  var params = [CPDictionary dictionary];
  [params setObject:@"" forKey:@"field_name"];
  [params setObject:@"" forKey:@"field_value"];
  [params setObject:[self deferLoadingBlobsAndText] forKey:@"defer_blob_text"];
  [params setObject:where_fields forKey:@"where_fields"];
  [params setObject:(clickedAddRow ? @"YES" : @"NO") forKey:@"add_row"];
  
  [params setObject:[self offset] forKey:@"offset"];
  [params setObject:[self limit] forKey:@"limit"];
  
  [[SJAPIRequest sharedAPIRequest] sendUpdateTable:[self tableName] query:params callback:function (js) {
    if (js.error =='') {
      [self handleTableRowsResponse:js];
    } else {
      console.log(js.error)
    }
  }];
}

- (void)duplicateRowAtIndex:(CPInteger)rowIndex
{
  if ([self deferLoadingBlobsAndText]) {
    return;
  }

  var rowData = [[self tbrows] objectAtIndex:rowIndex];
  var columns = [[self tableView] tableColumns];
  var where_fields = [CPArray array];

  for(var i=0; i<[columns count]; i++) {
    var column = [columns objectAtIndex:i];
    var columnName = [[column headerView] stringValue];
    var rowValue = rowData[columnName];
    
    var field_kv = [CPDictionary dictionaryWithObjectsAndKeys: columnName, @"name", rowValue, @"value"];
    [where_fields addObject:field_kv];
  }
  
  var params = [CPDictionary dictionary];
  [params setObject:[self offset] forKey:@"offset"];
  [params setObject:[self limit] forKey:@"limit"];
  [params setObject:where_fields forKey:@"where_fields"];

  [[SJAPIRequest sharedAPIRequest] sendDuplicateTableRow:[self tableName] query:params callback:function (js) {
    if (js.error == '') {
      [self handleTableRowsResponse:js];
    } else {
      console.log(js.error);
    }
  }]; 
}

@end
