@import <Foundation/Foundation.j>
@import "Categories/CPArray+Categories.j"
@import "Categories/CPAlert+Categories.j"


@implementation SJIndexesViewController : CPObject 
{
  CPView contentView @accessors;
  CPTableView tableView;
  CGFloat viewWidth;
  CPArray fields @accessors;
  CPString tableName @accessors;
  CPWindow theWindow @accessors;
  CPWindow addIndexWindow;
  id controller @accessors;
  
  CPPopUpButton nameKeyType;
  CPTextField nameKeyName;
  CPPopUpButton nameKeyIndexedColumns;
}


- (id)initWithView:(CPView)aView  andWidth:(CGFloat)aWidth
{
  self = [self init];
  contentView = aView;
  viewWidth = aWidth;
  
  [self setupView];
  return self;
}

- (void)reloadData
{
  [tableView reloadData];
}

- (void)setupView
{
  fields = [[CPArray alloc] init];
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
	
  var refreshBtn = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
  var refreshImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"refresh-icon.png"] size:CGSizeMake(14, 15)];
  [refreshBtn setBordered:NO];
  [refreshBtn setTarget:self];
  [refreshBtn setAction:@selector(refreshAction:)];
  [refreshBtn setImage:refreshImage];
  [refreshBtn setImagePosition:CPImageOnly];
  
	[bottomButtonBar setButtons:[addButton, removeButton, refreshBtn]];
	
	[contentView addSubview:bottomButtonBar];
}

- (void)selectKeyTypeAction:(CPPopUpButton)sender
{
  // console.log(@"*** Select Key Type");
}

- (void)selectColumnToIndex:(CPPopUpButton)sender
{
  // console.log(@"**** Select Column to index");
}

- (void)addRowAction:(CPButton)btn
{
  if (!addIndexWindow) {
    addIndexWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(30,30, 360, 160) styleMask:CPDocModalWindowMask];
    var indexContentView = [addIndexWindow contentView];
    
    var labelKeyType = [[CPTextField alloc] initWithFrame:CGRectMake(20, 20, 110, 20)];
    [labelKeyType setAlignment:CPRightTextAlignment];
    [labelKeyType setStringValue:@"Key Type:"];
    [labelKeyType setFont:[CPFont boldSystemFontOfSize:12.0]];
    [indexContentView addSubview:labelKeyType];
    
    nameKeyType = [[CPPopUpButton alloc] initWithFrame:CGRectMake(135, 20 - 4, 200, 24)];
    [nameKeyType setTarget:self];
	  [nameKeyType setAction:@selector(selectKeyTypeAction:)];
    [nameKeyType setTitle:@"INDEX"];
	  [nameKeyType addItemWithTitle:@"PRIMARY KEY"];
	  [nameKeyType addItemWithTitle:@"UNIQUE"];
	  [nameKeyType addItemWithTitle:@"FULLTEXT"];
    [indexContentView addSubview:nameKeyType];
    
    // ---
    var labelKeyName = [[CPTextField alloc] initWithFrame:CGRectMake(20, (24 * 2) + 2, 110, 20)];
    [labelKeyName setAlignment:CPRightTextAlignment];
    [labelKeyName setStringValue:@"Key Name:"];
    [labelKeyName setFont:[CPFont boldSystemFontOfSize:12.0]];
    [indexContentView addSubview:labelKeyName];
    
    nameKeyName = [[CPTextField alloc] initWithFrame:CGRectMake(132, (24 * 2) - 4, 205, 28)];
    [nameKeyName setAlignment:CPLeftTextAlignment];
    [nameKeyName setStringValue:@""];  
    [nameKeyName setEditable:YES];
    [nameKeyName setEnabled:YES];
    [nameKeyName setBezeled:YES];
    [nameKeyName setFont:[CPFont boldSystemFontOfSize:12.0]];
    [indexContentView addSubview:nameKeyName];
    
    // -----
    var labelKeyIndexedColumns = [[CPTextField alloc] initWithFrame:CGRectMake(20, (26 * 3) + 2, 110, 20)];
    [labelKeyIndexedColumns setAlignment:CPRightTextAlignment];
    [labelKeyIndexedColumns setStringValue:@"Indexed Columns:"];
    [labelKeyIndexedColumns setFont:[CPFont boldSystemFontOfSize:12.0]];
    [indexContentView addSubview:labelKeyIndexedColumns];
    
    nameKeyIndexedColumns = [[CPPopUpButton alloc] initWithFrame:CGRectMake(135, (26 * 3) - 2, 200, 24)];
    [nameKeyIndexedColumns setTarget:self];
	  [nameKeyIndexedColumns setAction:@selector(selectColumnToIndex:)];
    [indexContentView addSubview:nameKeyIndexedColumns];
    
    var cancelBtn = [[CPButton alloc] initWithFrame:CGRectMake(225, (30 * 4) - 3, 0, 0)];
    [cancelBtn setTitle:@"Cancel"];
    [cancelBtn sizeToFit];
    [cancelBtn setTarget:self];
    [cancelBtn setAction:@selector(didClickCancelAction:)];
    [indexContentView addSubview:cancelBtn];
    
    var saveBtn = [[CPButton alloc] initWithFrame:CGRectMake(292, (30 * 4) - 3, 0, 0)];
    [saveBtn setTitle:@" Add "];
    [saveBtn sizeToFit];
    [saveBtn setTarget:self];
    [saveBtn setAction:@selector(didClickAddIndexAction:)];
    [indexContentView addSubview:saveBtn];
  }
  
  [nameKeyIndexedColumns removeAllItems];
  var columns = [self columns];
	for(var i=0; i<[columns count]; i++) {
	  [nameKeyIndexedColumns addItemWithTitle:[columns objectAtIndex:i]];
	}

  [CPApp beginSheet: addIndexWindow
          modalForWindow: [[self contentView] window]
           modalDelegate: self
          didEndSelector: null
             contextInfo: null];
}

- (void)didClickCancelAction:(CPButton)sender
{
  [self endAddIndexWindow];
}

- (void)didClickAddIndexAction:(CPButton)sender
{
  var params = [CPDictionary dictionary];
  [params setObject:[nameKeyType title] forKey:@"type"];
  [params setObject:[nameKeyName stringValue] forKey:@"name"];
  [params setObject:[nameKeyIndexedColumns title] forKey:@"index_column"];

  [[SJAPIRequest sharedAPIRequest] sendAddIndexRequestTable:[self tableName] query:params callback:function(js) {
    if(js.error == '') {  
      [self setFields:js.indexes];
      [tableView reloadData];
    } else {
      [self setFields:js.indexes];
      [tableView reloadData];
    }
    [self endAddIndexWindow];
  }];
}

- (void)endAddIndexWindow
{
  [CPApp endSheet:addIndexWindow returnCode:CPCancelButton];
}

- (CPArray)columns
{
  return [[self controller] columns];
}


- (void)removeRowAction:(CPButton)btn
{
  var selectedRow = [tableView selectedRow];
  if (selectedRow != -1) {
    var item = [fields objectAtIndex:selectedRow];
    
    var didEndCallback = function (returnCode, contextInfo) {
      if(returnCode == 0) {
        var params = [CPDictionary dictionary];
        [params setObject:item['Key_name'] forKey:@"name"];
        [params setObject:item['Column_name'] forKey:@"index_column"];

        [[SJAPIRequest sharedAPIRequest] sendRemoveIndexRequestTable:[self tableName] query:params callback:function (js) {
          [self setFields:js.indexes];
          [self reloadData];
        }];
      }
    };
    
    var alert = [CPAlert new];
    [alert addButtonWithTitle:@"Delete"];    
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Delete index '"+ item['Key_name'] +"'?"];
    [alert setInformativeText:@"Are you sure you want to delete the index '"+ item['Key_name'] +"'? This action cannot be undone."];
    [alert setAlertStyle:CPWarningAlertStyle];
    [alert beginSheetModalForWindow:[self theWindow]
                      modalDelegate:self 
                      didEndCallback:didEndCallback
                      contextInfo:nil];
  }
}

- (void)refreshAction:(CPButton)btn
{
  [[SJAPIRequest sharedAPIRequest] sendRequestToEndpoint:@"indexes" tableName:[self tableName] callback:function (js) {
    [self setFields:js.indexes];
    [self reloadData];
  }];
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
  return [fields count];
}


- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPNumber)row
{
  var field = [fields objectAtIndex:row];
  
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