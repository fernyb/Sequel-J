
@import <Foundation/Foundation.j>
@import "Categories/CPSplitView+Categories.j"
@import "Categories/CPArray+Categories.j"
@import "Categories/CPTableView+Categories.j"
@import "SJHTTPRequest.j"
@import "SJDataManager.j"
@import "SJConstants.j"
@import "SJTableStructureItemView.j"



@implementation SJTableViewController : CPObject 
{
  CPView contentView;
  CPTableView tableView;
  CGFloat viewWidth;
  CPArray tableList;
  CPString tableName @accessors;
  CPWindow theWindow @accessors;
  CPString controllerName @accessors;
}


- (id)initWithView:(CPView)aView  andWidth:(CGFloat)aWidth
{
  self = [self init];
  contentView = aView;
  viewWidth = aWidth;
  tableList = [[CPArray alloc] init];
  responseData = [[CPArray alloc] init];
  
  [self setupView];
  return self;
}

- (CPArray)columns
{
  var columns = [CPArray array];
  for(var i=0; i<[tableList count]; i++) {
    var item = [tableList objectAtIndex:i];
    [columns addObject:item['Field']];
  }
  return columns;
}

- (void)tableViewSelectionDidChange:(CPNotification)aNotification
{
  var selectedRow = [tableView selectedRow];
  if (selectedRow == -1) return;
  
  [self validateFieldNames];
}

- (void)validateFieldNames
{
  var objectRemoved = NO;
  for(var i=0; i<[tableList count]; i++) {
    var item = [tableList objectAtIndex:i];
    if(!item['Field'].match(/[a-z0-9]/i)) {
      if ([tableView selectedRow] != i) {
        objectRemoved = YES;
        [tableList removeObjectAtIndex:i];
      }
    }
  }
  
  if(objectRemoved) [tableView reloadData];
}

- (void)addRowAction:(CPButton)btn
{
  [self addRowWithAttributes:nil];
}

- (void)addRowWithAttributes:(id)attributes
{
  if(!tableList) {
    return;
  }
  
  var columnIndex = [tableView indexForColumnIdentifier:@"SJTableColumnField"];
  
  if(columnIndex != -1) {
    if ([tableView selectedRow] != -1) {
      [tableView deselectRow:[tableView selectedRow]];
    }
    [self validateFieldNames];
    
    var default_attributes =  {
      'Field'      : '',
      'Type'       : 'int',
      'Length'     : '11',
      'Unsigned'   : false,
      'Zerofill'   : false,
      'Binary'     : false,
      'Allow Null' : true,
      'Key'        : '',
      'Default'    : 'NULL',
      'Extra'      : ''
    };
    
    if(attributes != nil || attributes != null || attributes != 'undefined') {
      for (var key in attributes) {
        var currentValue = default_attributes[key];
        if(currentValue != 'undefined') {
          default_attributes[key] = attributes[key];
        }
      }
    }
    
    tableList.push(default_attributes);
    
    var name_num = 0;
    var determine_name = function (name) {
      for(var i=0; i<[tableList count]; i++) {
        var item = [tableList objectAtIndex:i];
        var fieldName = item['Field'];
        if(fieldName == name) {
          name = name.split(" ")[0];
          name_num += 1;
          return determine_name(name +" "+ name_num);
        }
      }
      return name;
    };
    
    var itemFieldName = determine_name("Untitled");
    [self updateColumnName:@"Field" withValue:itemFieldName forRow:([tableList count] - 1) actionName:@"add"];
  }
}

- (void)addRowActionAlertDidEnd:(CPAlert)sender returnCode:(int)code contextInfo:(id)context
{
  // do nothing for now...
}


- (void)removeRowAction:(CPButton)btn
{
  var row = [tableView selectedRow];
  if (row == -1) {
    return;
  }
  
  var item = [tableList objectAtIndex:row];
  
  if(item['Field'] == '') {
    [tableList removeObjectAtIndex:row];
    [tableView reloadData];
    return;
  }
  
  var params = [CPDictionary dictionary];
  [params setObject:item['Field'] forKey:@"column_name"];
  
  [[SJAPIRequest sharedAPIRequest] sendRemoveColumnRequestTable:[self tableName] query:params callback:function( js ) {
    if (js.error != '') {
      var error_message = "An error occurred.";
      error_message += "\n\n";
      error_message += "MySQL said: " + js.error;
      error_message += "\n\n";
      error_message += js.query;
    
      var alert = [CPAlert new];
      [alert addButtonWithTitle:@"OK"];
      [alert setMessageText:@"Error removing field"];
      [alert setInformativeText:error_message];
      [alert setAlertStyle:CPCriticalAlertStyle];
      [alert beginSheetModalForWindow:[self theWindow]
                        modalDelegate:self 
                       didEndSelector:@selector(addRowActionAlertDidEnd:returnCode:contextInfo:) 
                          contextInfo:nil];
    [tableView reloadData];
    } 
    else if (js.error == '') {
      [self setFields:js.fields];
      [self reloadData];
    }
  }];
}

- (void)duplicateRowAction:(CPButton)btn
{
  var selectedRow = [tableView selectedRow];
  if( selectedRow != -1) {
    var item = [tableList objectAtIndex:selectedRow];  
    [self addRowWithAttributes:item];
  }
}


- (void)refreshAction:(CPButton)btn
{
  [[SJAPIRequest sharedAPIRequest] sendRequestToEndpoint:@"schema" tableName:[self tableName] callback:function (js) {
    [self setFields:js.fields];
    [self reloadData];
  }];
}


- (void)setupView
{
  var scrollview = [self addTableView];
  [contentView addSubview:scrollview];
  [scrollview setFrame:CGRectMake(0,0, [contentView bounds].size.width, [contentView bounds].size.height - 23)];
  [self addBottomBar];
}

- (void)addBottomBar
{
  // create the bottom button bar
	var bottomButtonBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(0, [contentView bounds].size.height - 23, [contentView bounds].size.width, 23)];
	[bottomButtonBar setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
	
	var addButton = [CPButtonBar plusButton];
	[addButton setAction:@selector(addRowAction:)];
	[addButton setTarget:self];
	[addButton setEnabled:YES];
	
	var removeButton = [CPButtonBar minusButton];
	[removeButton setAction:@selector(removeRowAction:)];
	[removeButton setTarget:self];
	[removeButton setEnabled:YES];
	
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
  
	[bottomButtonBar setButtons:[addButton, removeButton, duplicateButton, refreshBtn]];
	
	[contentView addSubview:bottomButtonBar];
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
  [tableView setDelegate:self];
  [tableView setUsesAlternatingRowBackgroundColors:YES];
  
  var widthOfHeader = (viewWidth - 15) / [[self headerNames] count];
  for(var i=0; i<[[self headerNames] count]; i++) {
    var columnName = [[self headerNames] objectAtIndex:i];
    var column = [[CPTableColumn alloc] initWithIdentifier:[CPString stringWithFormat:@"SJTableColumn%@", columnName]];
    [[column headerView] setStringValue:columnName];
    [column setWidth:widthOfHeader];
    
    switch (columnName) {
      case @"Unsigned" :
      case @"Zerofill" :
      case @"Binary" :
      case @"Allow Null" :
        var checkbox = [CPCheckBox checkBoxWithTitle:@""];
        [column setDataView:checkbox];
      break;
      
      case @"Extra" :
      case @"Type"  :
        var extraDView = [[SJTableStructureItemView alloc] initWithFrame:CGRectMake(0,0, widthOfHeader, 20)];
        [extraDView setColumnIdentifier:[column identifier]];
          
        if(columnName == @"Type") {
          [extraDView setItems:[self typeItems]];
        } else if (columnName == @"Extra") {
          [extraDView setItems:[self extraItems]];  
        }
        [column setDataView:extraDView];
      break;
      
      case @"Key" :
        [column setEditable:NO];
      break;
      
      default :
        [column setEditable:YES];
      break;
    }

    [tableView addTableColumn:column];
  }
  
  [scrollView setDocumentView:tableView];
  
  return scrollView;
}

- (CPArray)extraItems
{
  return ['none', 'auto_increment', 'on update CURRENT_TIMESTAMP'];
}

- (CPArray)typeItems
{
  return ['int', 'bigint', 'float', 'double', 'decimal', '', 
          'date', 'datetime', 'timestamp', 'time', 'year', '',
          'char', 'varchar', 'tinyblob', 'tinytext', 'blob', 'text', 'mediumblob', 'mediumtext', 'longtext', 'enum', 'set', '',
          'bit', 'binary', 'varbinary'];
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

- (void)updateFieldWithValue:(CPString)title forColumnIdentifier:(CPString)columnIdentifier
{
  if (columnIdentifier == @"SJTableColumnExtra") {
    [self extraFieldDidUpdate:title];
  } 
  else if(columnIdentifier == @"SJTableColumnType") {
    [self updateFieldType:title];
  }
}

- (void)updateFieldType:(CPString)type
{
  var selectedRow = [tableView selectedRow];
  if (selectedRow != -1) {
    [self updateColumnName:@"Type" withValue:type forRow:selectedRow actionName:@"update"];
  }
}

- (void)extraFieldDidUpdate:(CPString)title
{
  var selectedRow = [tableView selectedRow];
  if( selectedRow != -1) {
    var oldValue = [CPString string];
    [self updateFieldName:@"Extra" forIndex:selectedRow withCallback:function (item, idx) {
      oldValue = [CPString stringWithString:((item['Extra'] == '' || item['Extra'] == null) ? "None" : item['Extra'])];
      item['Extra'] = title;
      return item;
    } errorCallback:function (item, idx) {
      item['Extra'] = oldValue;
      return item;
    }];
  }
}

- (void)alertDidEnd:(CPAlert)sender returnCode:(int)code contextInfo:(id)context
{
  //console.log(@"***** Alert Did End");
}


- (void)updateFieldName:(CPString)name forIndex:(int)rowIndex withCallback:(func)aCallback errorCallback:(func)errorCallback
{
  var item = [tableList objectAtIndex:rowIndex];
  item = aCallback(item, rowIndex);
  
  var params = [CPDictionary dictionary];
  [params setObject:item['Field'] forKey:@"field"];
  [params setObject:item['Type'] forKey:@"type"];
  [params setObject:item['Length'] forKey:@"length"];
  [params setObject:(item['Unsigned'] ? @"YES" : @"NO") forKey:@"unsigned"];
  [params setObject:[name lowercaseString] forKey:@"name"];
  [params setObject:(item[name] ? @"YES" : @"NO") forKey:[name lowercaseString]];
  [params setObject:item['Extra'] forKey:@"extra"];
  [params setObject:(item['Allow Null'] ? @"YES" : @"NO") forKey:@"null"];

  [[SJAPIRequest sharedAPIRequest] sendUpdateRequestSchemaTable:[self tableName] query:params callback:function( js ) {
    if (js.error != '') {
      var error_message = "An error occurred when trying to change field '"+ item['Field'] +"' ";
      error_message += "\n\n";
      error_message += "MySQL said: " + js.error;
      error_message += "\n\n";
      error_message += js.query;
      
      item = errorCallback(item, rowIndex);
      
      var alert = [CPAlert new];
      [alert addButtonWithTitle:@"OK"];
      [alert setMessageText:@"Error changing field"];
      [alert setInformativeText:error_message];
      [alert setAlertStyle:CPCriticalAlertStyle];
      [alert beginSheetModalForWindow:[self theWindow]
                        modalDelegate:self 
                       didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                          contextInfo:nil];
    [tableView reloadData];
    } 
    else if (js.error == '') {
      [self setFields:js.fields];
      [self reloadData];
    }
  }];
}


- (BOOL)tableView:(CPTableView)aTableView shouldEditTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
  switch([aTableColumn identifier]) {
    case @"Unsigned" :
    case @"Zerofill" :
    case @"Binary" :
    case @"Allow Null" :
    case @"Extra" :
    case @"Key" :
      return NO;
    break;
    default :
      return YES;
    break;
  }
}


- (void)tableView:(CPTableView)aTableView setObjectValue:(CPControl)anObject forTableColumn:(CPTableColumn)tc row:(int)rowIndex
{
  var checkIfNeeded = function (name) {
    [self updateFieldName:name forIndex:rowIndex withCallback:function (item, idx) {
      item[name] = (item[name] == true ? false : true);
      return item;
    } errorCallback:function (item, idx) {
      item[name] = (item[name] ? false : true);
      return item;
    }];
  };
  
  switch([tc identifier]) {
    case @"SJTableColumnUnsigned" :
      checkIfNeeded('Unsigned');
    break;
    case @"SJTableColumnZerofill" :
      checkIfNeeded('Zerofill');
    break;
    case @"SJTableColumnBinary" :
      checkIfNeeded('Binary');
    break;
    case @"SJTableColumnAllow Null" :
      checkIfNeeded('Allow Null');
    break;
    case @"SJTableColumnType" :
      //
    break;
    case @"SJTableColumnExtra" :
      // Not sure what to do because it has a drop down...
    break;
    default :
      var item = [tableList objectAtIndex:rowIndex];
      var name = [[[tc identifier] componentsSeparatedByString:@"SJTableColumn"] lastObject];
      if(anObject != item[name]) {
        [self updateColumnName:name withValue:anObject forRow:rowIndex actionName:@"update"];
      }
    break;
  }
}


- (void)updateColumnName:(CPString)columnName withValue:(CPString)aValue forRow:(CPInteger)row actionName:(CPString)actName
{
  var item = [tableList objectAtIndex:row];
  var name = [columnName lowercaseString].replace(" ", "_");
  var previous_value = item[columnName];
  item[columnName] = aValue;
  [tableView reloadData];
  
  var after_column = ((row - 1) < 0) ? '' : [tableList objectAtIndex:(row - 1)];
  var after_column_name = '';
  if (after_column != '') {
    after_column_name = after_column['Field'];
  }
  
  var params = [CPDictionary dictionary];
  [params setObject:after_column_name forKey:@"after_column_name"];
  [params setObject:previous_value forKey:@"previous_value"];
  [params setObject:columnName forKey:@"update_column_name"];
  
  [params setObject:item['Field'] forKey:@"column_name"];
  [params setObject:item['Type'] forKey:@"column_type"];
  [params setObject:item['Length'] forKey:@"column_length"];
  [params setObject:(item['Unsigned'] ? @"YES" : @"NO")  forKey:@"column_unsigned"];
  [params setObject:(item['Zerofill'] ? @"YES" : @"NO")  forKey:@"column_zerofill"];
  [params setObject:(item['Binary'] ? @"YES" : @"NO")  forKey:@"column_binary"];
  [params setObject:item['Default'] forKey:@"column_default"];
  [params setObject:item['Extra'] forKey:@"column_extra"];
  [params setObject:actName forKey:@"action_name"];

  [[SJAPIRequest sharedAPIRequest] sendUpdateColumnRequestTable:[self tableName] query:params callback:function( js ) {
    if (js.error != '') {
      var error_message = "An error occurred.";
      error_message += "\n\n";
      error_message += "MySQL said: " + js.error;
      error_message += "\n\n";
      error_message += js.query;
      
      item[columnName] = previous_value;
      
      var alert = [CPAlert new];
      [alert addButtonWithTitle:@"OK"];
      [alert setMessageText:@"Error changing field"];
      [alert setInformativeText:error_message];
      [alert setAlertStyle:CPCriticalAlertStyle];
      [alert beginSheetModalForWindow:[self theWindow]
                        modalDelegate:self 
                       didEndSelector:@selector(addRowActionAlertDidEnd:returnCode:contextInfo:) 
                          contextInfo:nil];
    [tableView reloadData];
    } 
    else if (js.error == '') {
      [self setFields:js.fields];
      [self reloadData];
      setTimeout(function() {
        [tableView selectRowIndexes:[CPIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
      }, 0);
    }
  }];
}


- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPNumber)row
{
  var field = [tableList objectAtIndex:row];
  var shouldBeChecked = function(field_value) {
    return field_value == true ? CPOnState : CPOffState;
  };
  
  switch([aTableColumn identifier]) {
   case @"SJTableColumnField" :
    return field['Field'];
   break; 
  
   case @"SJTableColumnType" :
    return field['Type'];
   break;
   
   case @"SJTableColumnUnsigned" :
    return shouldBeChecked(field['Unsigned']);
   break;
   
   case @"SJTableColumnZerofill" :
    return shouldBeChecked(field['Zerofill']);
   break;

   case @"SJTableColumnBinary" :
    return shouldBeChecked(field['Binary']);
   break;
   
   case @"SJTableColumnAllow Null" :
    return shouldBeChecked(field['Allow Null']);
   break;
        
   case @"SJTableColumnLength" :
    return field['Length'];
   break;
  
   case @"SJTableColumnKey" :
    return field['Key'];
   break;
  
   case @"SJTableColumnExtra" :
     return (field['Extra'] == '' ? 'None' : field['Extra']);
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