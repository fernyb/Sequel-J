@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"
@import "Categories/CPDictionary+Categories.j"
@import "Categories/CPArray+Categories.j"


@implementation SJContentTabController : SJTabBaseController
{
  CPScrollView scrollview;
  CPArray headerNames;
  CPArray tbrows;
  CPString cachedTableName;
  CPButtonBar bottomBar;
}

- (void)viewWillAppear
{
  if (cachedTableName != [self tableName]) {
   cachedTableName = [self tableName];
   [self databaseTableSelected];
  }
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
      var names = [js.fields collect:function (f) {
        return f['Field'];
      }];
      
      headerNames = [[CPArray alloc] initWithArray:names];
    
      scrollview = [self createTableViewForView:[self view] headerNames:[self headerNames]];
      
      var rect = [scrollview frame];
      rect.size.height -= 23.0;
      
      [scrollview setFrame:rect];
      [[self view] addSubview:scrollview];
      
      var columns = [[self tableView] tableColumns];
      for(var i=0; i<[columns count]; i++) {
        [[columns objectAtIndex:i] setEditable:YES];
      }
      
      [self addBottomBarWithRect:rect];
      
      // We need to get the rows for the table, lets do that here
      [[SJAPIRequest sharedAPIRequest] sendRequestForRowsForTable:tableName callback:function( js ) 
  	  {
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
  [bottomBar setHasResizeControl:NO];
}

- (void)addRow:(id)sender
{
  var columns = [[self tableView] tableColumns];
  var newRow = {};
  for(var i=0; i<[columns count]; i++) {
    var column = [column objectAtIndex:i];
    var columnName = [[column headerView] stringValue];
    newRow[columnName] = 'NULL';
  }
  
  if([columns count] > 0) {
    [[self tbrows] addObject:newRow];
    [[self tableView] reloadData];
    [[self tableView] selectRowIndexes:[CPIndexSet indexSetWithIndex:([[self tbrows] count] - 1)] byExtendingSelection:NO];
    [[self tableView] editColumn:0 row:([[self tbrows] count] - 1) withEvent:nil select:YES];
  }
}

- (void)removeRow:(id)sender
{
  alert('Remove Row');
}

- (void)duplicateRowAction:(CPButton)sender
{
  alert('Duplicate Row Action');
}

- (void)refreshAction:(CPButton)sender
{
  // TODO: Add Navigation paging
  var params = [CPDictionary dictionary];
  [params setObject:@"0" forKey:@"offset"];
  [params setObject:@"100" forKey:@"limit"];
  
  [[SJAPIRequest sharedAPIRequest] sendRequestTableRows:[self tableName] query:params callback:function (js) {
  	[self handleTableRowsResponse:js];
  }];
}

- (void)handleTableRowsResponse:(id)js
{
  [self setTbrows:js.rows];
  [[self tableView] reloadData];
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

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)rowIndex
{
  var rowData = [[self tbrows] objectAtIndex:rowIndex];
  var headerName = [[aTableColumn headerView] stringValue];

  return rowData[headerName] > '' ? rowData[headerName].replace(/(\r\n|\n|\r)/gm,"") : rowData[headerName];
}

- (void)tableView:(CPTableView)aTableView setObjectValue:(id)anObject forTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
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

  // TODO: replace the actual values of offset and limit when it has been implemented.
  // They will be used to return the rows that will be displayed
  [params setObject:@"0" forKey:@"offset"];
  [params setObject:@"100" forKey:@"limit"];
  
  rowData[header_name] = anObject;
 
  [[SJAPIRequest sharedAPIRequest] sendUpdateTable:[self tableName] query:params callback:function (js) {
    if (js.error =='') {
      [self setTbrows:js.rows];
      [[self tableView] reloadData];
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


@end
