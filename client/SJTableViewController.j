
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
  CPString tableName @accessors;
  CPWindow theWindow @accessors;
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
    }

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


- (void)alertDidEnd:(CPAlert)sender returnCode:(int)code contextInfo:(id)context
{
  //console.log(@"***** Alert Did End");
}

- (void)tableView:(CPTableView)aTableView setObjectValue:(CPControl)anObject forTableColumn:(CPTableColumn)tc row:(int)rowIndex
{
  var checkIfNeeded = function(name) {
    var item = [tableList objectAtIndex:rowIndex];
    item[name] = (item[name] == true ? false : true);

    var params = [CPDictionary dictionary];
    [params setObject:item['Field'] forKey:@"field"];
    [params setObject:item['Type'] forKey:@"type"];
    [params setObject:item['Length'] forKey:@"length"];
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
        
        item[name] = (item[name] ? false : true);
        
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
  }
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