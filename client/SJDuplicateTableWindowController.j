@import <Foundation/CPObject.j>
@import "SJAPIRequest.j"


@implementation SJDuplicateTableWindowController : CPWindowController
{
  id parentController @accessors;
  CPString tableName @accessors;
  CPTextField labelTitle;
  CPTextField labelInputName;
  CPCheckBox checkbox;
}
  
- (id)init {
  self = [super init];
  [self setup];
  return self;
}


- (void)setup
{
	[self setWindow:[[CPWindow alloc] initWithContentRect:CGRectMake(0,0,325,137) styleMask:CPDocModalWindowMask]];
  var contentView = [[self window] contentView];
  
  labelTitle = [[CPTextField alloc] initWithFrame:CGRectMake(20, 10, 290, 20)];
  [labelTitle setAlignment:CPLeftTextAlignment];
  [labelTitle setStringValue:@"Duplicate Table '"+ [self tableName] +"' to:"];
  [labelTitle setFont:[CPFont boldSystemFontOfSize:12.0]];
  [contentView addSubview:labelTitle];
  
  labelInputName = [[CPTextField alloc] initWithFrame:CGRectMake(18, 32, 290, 28)];
  [labelInputName setAlignment:CPLeftTextAlignment];
  [labelInputName setStringValue:@""];
  [labelInputName setEditable:YES];
  [labelInputName setEnabled:YES];
  [labelInputName setBezeled:YES];
  [labelInputName setFont:[CPFont boldSystemFontOfSize:12.0]];
  [contentView addSubview:labelInputName];
  
  checkbox = [CPCheckBox checkBoxWithTitle:@"Duplicate table content?"];
  var checkboxFrame = [checkbox frame];
  checkboxFrame.origin.x = 23;
  checkboxFrame.origin.y = 66;
  [checkbox setFrame:checkboxFrame];
  [contentView addSubview:checkbox];
  
  var cancelBtn = [[CPButton alloc] initWithFrame:CGRectMake(170, 95, 100, 23)];
  [cancelBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
  [cancelBtn setTitle:@"Cancel"];
  [cancelBtn sizeToFit];
  [cancelBtn setTarget:self];
  [cancelBtn setAction:@selector(didClickCancelBtn:)];
  [contentView addSubview:cancelBtn];
  
  var dupBtn = [[CPButton alloc] initWithFrame:CGRectMake(235, 95, 100, 23)];
  [dupBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
  [dupBtn setTitle:@"Duplicate"];
  [dupBtn sizeToFit];
  [dupBtn setTarget:self];
  [dupBtn setAction:@selector(didClickDuplicateBtn:)];
  [contentView addSubview:dupBtn];
}

- (void)didClickDuplicateBtn:(CPButton)sender
{
  var params = [CPDictionary dictionary];
  [params setObject:([checkbox state] == CPOnState ? @"YES" : @"NO") forKey:@"duplicate_content"];
  [params setObject:[labelInputName stringValue] forKey:@"name"];
  
  [[SJAPIRequest sharedAPIRequest] sendRequestDuplicateTable:tableName query:params callback:function (js) {
    [parentController duplicateTableComplete:js];
    [CPApp endSheet:[self window]];
  }];
}

- (void)didClickCancelBtn:(CPButton)sender
{
  [CPApp endSheet:[self window]];
}

- (void)willDisplayController
{
  [labelTitle setStringValue:@"Duplicate Table '"+ [self tableName] +"' to:"];
  [labelInputName setStringValue:[self tableName] + "_copy"];
  [[self window] makeFirstResponder:labelInputName];  
}

@end