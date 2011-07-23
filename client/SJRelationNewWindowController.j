@import <Foundation/CPObject.j>

@implementation SJRelationNewWindowController : CPWindowController
{
  id controller @accessors;
  CPPopUpButton columnPopBtn;
  CPPopUpButton referenceTablesPopBtn;
  CPPopUpButton referenceColumnPopupBtn;
  CPPopUpButton onUpdatePopupBtn;
  CPDictionary fields;
}

- (id)initWithParentController:(id)aController
{
  self = [super init];
  [self setController:aController];
  [self setup];
  return self;
}

- (CPString)tableName
{
  return [controller tableName];
}

- (void)setup
{
  var rect = CGRectMake(0, 0, 350, 350);
  [self setWindow:[[CPWindow alloc] initWithContentRect:rect styleMask:CPDocModalWindowMask]];
  [self addTableBox];
  [self addReferencesBox];
  [self addActionBox];
  [self addButtons];
}

- (void)addTableBox
{
  var rect = CGRectMake(0, 0, 350, 250);
  var contentView = [[self window] contentView];

  var tableBox = [[CPBox alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(rect) - 20, 50)];
  var tableBoxName = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  [tableBoxName setStringValue:@"Table: "+ [self tableName]];
  [tableBoxName sizeToFit];
  [tableBoxName setFrameOrigin:CGPointMake(10, 10)];
  [contentView addSubview:tableBoxName];

  [tableBox setFrameOrigin:CGPointMake(10, 30)];
  var columnLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  [columnLabel setStringValue:@"Column:"];
  [columnLabel sizeToFit];
  [columnLabel setFrame:CGRectMake(0,0, 90, CGRectGetHeight([columnLabel frame]))];
  [columnLabel setFrameOrigin:CGPointMake(10, 14)];
  [[tableBox contentView] addSubview:columnLabel];

  columnPopBtn = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0,0, 210, 24)];
  [columnPopBtn setFrameOrigin:CGPointMake(110, 10)];
  [columnPopBtn setTarget:self];
  [columnPopBtn setAction:@selector(didSelectColumnAction:)];
  [[tableBox contentView] addSubview:columnPopBtn];

  [contentView addSubview:tableBox];
}

- (void)addReferencesBox
{
  var rect = CGRectMake(0, 0, 350, 250);
  var contentView = [[self window] contentView];

  var tableBox = [[CPBox alloc] initWithFrame:CGRectMake(10, 120, CGRectGetWidth(rect) - 20, 80)];
  var tableBoxName = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  [tableBoxName setStringValue:@"References "];
  [tableBoxName sizeToFit];
  [tableBoxName setFrameOrigin:CGPointMake(10, 90)];
  [contentView addSubview:tableBoxName];

  [tableBox setFrameOrigin:CGPointMake(10, 110)];

  var tableLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  [tableLabel setStringValue:@"Table:"];
  [tableLabel sizeToFit];
  [tableLabel setFrame:CGRectMake(0,0, 90, CGRectGetHeight([tableLabel frame]))];
  [tableLabel setFrameOrigin:CGPointMake(10, 14)];
  [[tableBox contentView] addSubview:tableLabel];

  referenceTablesPopBtn = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0,0, 210, 24)];
  [referenceTablesPopBtn setFrameOrigin:CGPointMake(110, 10)];
  [referenceTablesPopBtn setTarget:self];
  [referenceTablesPopBtn setAction:@selector(didSelectReferenceTableAction:)];
  [[tableBox contentView] addSubview:referenceTablesPopBtn];

  
  var columnLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  [columnLabel setStringValue:@"Column:"];
  [columnLabel sizeToFit];
  [columnLabel setFrame:CGRectMake(0,0, 90, CGRectGetHeight([columnLabel frame]))];
  [columnLabel setFrameOrigin:CGPointMake(10, 44)];
  [[tableBox contentView] addSubview:columnLabel];

  referenceColumnPopupBtn = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0,0, 210, 24)];
  [referenceColumnPopupBtn setFrameOrigin:CGPointMake(110, 42)];
  [referenceColumnPopupBtn setTarget:self];
  [referenceColumnPopupBtn setAction:@selector(didSelectReferenceColumnAction:)];
  [[tableBox contentView] addSubview:referenceColumnPopupBtn];

  [contentView addSubview:tableBox];
}

- (CPArray)actionItems
{
  return [
    @" ",
    @"Restrict",
    @"Cascade",
    @"Set NULL",
    @"No Action"
  ];
}

- (void)addActionBox
{
  var rect = CGRectMake(0, 0, 350, 250);
  var contentView = [[self window] contentView];

  var tableBox = [[CPBox alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rect) - 20, 80)];
  var tableBoxName = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  [tableBoxName setStringValue:@"Action"];
  [tableBoxName sizeToFit];
  [tableBoxName setFrameOrigin:CGPointMake(10, 200)];
  [contentView addSubview:tableBoxName];

  [tableBox setFrameOrigin:CGPointMake(10, 220)];

  var tableLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  [tableLabel setStringValue:@"On update:"];
  [tableLabel sizeToFit];
  [tableLabel setFrame:CGRectMake(0,0, 90, CGRectGetHeight([tableLabel frame]))];
  [tableLabel setFrameOrigin:CGPointMake(10, 14)];
  [[tableBox contentView] addSubview:tableLabel];

  onUpdatePopupBtn = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0,0, 210, 24)];
  [onUpdatePopupBtn setFrameOrigin:CGPointMake(110, 10)];
  [onUpdatePopupBtn setTarget:self];
  [onUpdatePopupBtn setAction:@selector(didSelectOnUpdateAction:)];
  [onUpdatePopupBtn addItemsWithTitles:[self actionItems]];
  [[tableBox contentView] addSubview:onUpdatePopupBtn];

  
  var columnLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  [columnLabel setStringValue:@"On delete:"];
  [columnLabel sizeToFit];
  [columnLabel setFrame:CGRectMake(0,0, 90, CGRectGetHeight([columnLabel frame]))];
  [columnLabel setFrameOrigin:CGPointMake(10, 44)];

  [[tableBox contentView] addSubview:columnLabel];

  var onDeletePopupBtn = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0,0, 210, 24)];
  [onDeletePopupBtn setFrameOrigin:CGPointMake(110, 42)];
  [onDeletePopupBtn addItemsWithTitles:[self actionItems]];
  [onDeletePopupBtn setTarget:self];
  [onDeletePopupBtn setAction:@selector(didSelectOnDeleteAction:)];
  [[tableBox contentView] addSubview:onDeletePopupBtn];

  [contentView addSubview:tableBox];
}

- (void)addButtons
{
  var contentView = [[self window] contentView];
  var contentViewRect = [contentView frame];

  var cancelBtn = [[CPButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(contentViewRect) - (75 * 2 + 20), 310, 75, 30)];
  [cancelBtn setTitle:@"Cancel"];
  [cancelBtn sizeToFit];
  [cancelBtn setTarget:self];
  [cancelBtn setAction:@selector(cancelBtnAction:)];

  var cancelBtnSize = [cancelBtn frame].size;
  cancelBtnSize.width = 75;
  [cancelBtn setFrameSize:cancelBtnSize];
  [contentView addSubview:cancelBtn];

  var addBtn = [[CPButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(contentViewRect) - (75 + 10), 310, 75, 30)];
  [addBtn setTitle:@"Add"];
  [addBtn sizeToFit];
  [addBtn setFrameSize:cancelBtnSize];
  [addBtn setTarget:self];
  [addBtn setAction:@selector(addBtnAction:)];
  [contentView addSubview:addBtn];
}

- (void)cancelBtnAction:(CPButton)sender
{
  [CPApp endSheet:[self window]];
}

- (void)addBtnAction:(CPButton)sender
{
  [[SJAPIRequest sharedAPIRequest] sendAddRelation:[controller tableName] query:fields callback:function (js) {
    if (js.error == '') {
      console.log(js);
      [CPApp endSheet:[self window]];
    } else {
      [CPApp endSheet:[self window]];
      [self handleErrorRequest:js];
    }
  }];  
}

- (void)handleErrorRequest:(id)js
{
  var didEndCallback = function() {
  };

  var error = js.error;
  error += "\n\n";
  error += js.query;

  var alert = [CPAlert new];
  [alert addButtonWithTitle:@"OK"];    
  [alert setMessageText:@"Error trying to add relation."];
  [alert setInformativeText:error];
  [alert setAlertStyle:CPWarningAlertStyle];
  [alert beginSheetModalForWindow:[[controller contentView] window]
                  modalDelegate:self 
                  didEndCallback:didEndCallback
                  contextInfo:nil];
}

- (void)willDisplayView
{
  fields = [CPDictionary dictionary];

  var structure = [controller structure];
  [columnPopBtn removeAllItems];
  [columnPopBtn addItemWithTitle:@" "];
  [structure each:function(item) {
    [columnPopBtn addItemWithTitle:item['Field']];
  }];

  var tables = [controller tables];
  [referenceTablesPopBtn removeAllItems];
  [referenceTablesPopBtn addItemWithTitle:@" "];
  [tables each:function(item) {
    [referenceTablesPopBtn addItemWithTitle:item];
  }];
}

- (void)didSelectColumnAction:(CPPopUpButton)sender
{
  var colname = [[sender selectedItem] title];
  [fields setObject:colname forKey:@"column"];
}

- (void)didSelectReferenceTableAction:(CPPopUpButton)sender
{
  var selectedRefTable = [[sender selectedItem] title];
  [fields setObject:selectedRefTable forKey:@"ref_table"];
  [referenceColumnPopupBtn removeAllItems];

  [[SJAPIRequest sharedAPIRequest] sendRequestToEndpoint:@"schema" tableName:selectedRefTable callback:function ( js ) {
    if (js.error == '') {
      [referenceColumnPopupBtn addItemWithTitle:@" "];
      [js.fields each:function(f) {
        [referenceColumnPopupBtn addItemWithTitle:f['Field']];
      }];
    }
  }];
}

- (void)didSelectReferenceColumnAction:(CPPopUpButton)sender
{
  var selectedTitle = [[sender selectedItem] title];
  [fields setObject:selectedTitle forKey:@"ref_column"];
}

- (void)didSelectOnUpdateAction:(CPPopUpButton)sender
{
  var onUpdateAction = [[sender selectedItem] title];
  [fields setObject:onUpdateAction forKey:@"update_action"];
}

- (void)didSelectOnDeleteAction:(CPPopUpButton)sender
{
  var onDeleteAction = [[sender selectedItem] title];
  [fields setObject:onDeleteAction forKey:@"delete_action"];
}

@end
