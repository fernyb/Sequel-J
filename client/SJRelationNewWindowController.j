@import <Foundation/CPObject.j>

@implementation SJRelationNewWindowController : CPWindowController
{
  id controller @accessors;
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

  var columnPopBtn = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0,0, 210, 24)];
  [columnPopBtn setFrameOrigin:CGPointMake(110, 10)];
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

  var tablePopupBtn = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0,0, 210, 24)];
  [tablePopupBtn setFrameOrigin:CGPointMake(110, 10)];
  [[tableBox contentView] addSubview:tablePopupBtn];

  
  var columnLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  [columnLabel setStringValue:@"Column:"];
  [columnLabel sizeToFit];
  [columnLabel setFrame:CGRectMake(0,0, 90, CGRectGetHeight([columnLabel frame]))];
  [columnLabel setFrameOrigin:CGPointMake(10, 44)];
  [[tableBox contentView] addSubview:columnLabel];

  var columnPopBtn = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0,0, 210, 24)];
  [columnPopBtn setFrameOrigin:CGPointMake(110, 42)];
  [[tableBox contentView] addSubview:columnPopBtn];

  [contentView addSubview:tableBox];
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

  var tablePopupBtn = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0,0, 210, 24)];
  [tablePopupBtn setFrameOrigin:CGPointMake(110, 10)];
  [[tableBox contentView] addSubview:tablePopupBtn];

  
  var columnLabel = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
  [columnLabel setStringValue:@"On delete:"];
  [columnLabel sizeToFit];
  [columnLabel setFrame:CGRectMake(0,0, 90, CGRectGetHeight([columnLabel frame]))];
  [columnLabel setFrameOrigin:CGPointMake(10, 44)];
  [[tableBox contentView] addSubview:columnLabel];

  var columnPopBtn = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0,0, 210, 24)];
  [columnPopBtn setFrameOrigin:CGPointMake(110, 42)];
  [[tableBox contentView] addSubview:columnPopBtn];

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
  // Here make request for new relation
}

@end
