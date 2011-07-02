@import <Foundation/CPObject.j>
@import "SJAPIRequest.j"


@implementation SJRenameTableWindowController : CPWindowController
{
  id parentController @accessors;
  CPString tableName @accessors;
  CPTextField labelTitle;
  CPTextField labelInputName;
}
  
- (id)init {
  self = [super init];
  [self setup];
  return self;
}


- (void)setup
{
	[self setWindow:[[CPWindow alloc] initWithContentRect:CGRectMake(0,0,325,115) styleMask:CPDocModalWindowMask]];
  var contentView = [[self window] contentView];
  
  labelTitle = [[CPTextField alloc] initWithFrame:CGRectMake(20, 10, 290, 20)];
  [labelTitle setAlignment:CPLeftTextAlignment];
  [labelTitle setStringValue:@"Rename Table '"+ [self tableName] +"' to:"];
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
  
  var cancelBtn = [[CPButton alloc] initWithFrame:CGRectMake(176, 70, 100, 23)];
  [cancelBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
  [cancelBtn setTitle:@"Cancel"];
  [cancelBtn sizeToFit];
  [cancelBtn setTarget:self];
  [cancelBtn setAction:@selector(didClickCancelBtn:)];
  [contentView addSubview:cancelBtn];
  
  var renameBtn = [[CPButton alloc] initWithFrame:CGRectMake(241, 70, 100, 23)];
  [renameBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
  [renameBtn setTitle:@"Rename"];
  [renameBtn sizeToFit];
  [renameBtn setTarget:self];
  [renameBtn setAction:@selector(didClickRenameBtn:)];
  [contentView addSubview:renameBtn];
}

- (void)didClickRenameBtn:(CPButton)sender
{
  if ([labelInputName stringValue] == '') {
    return;
  }
  
  var params = [CPDictionary dictionary];
  [params setObject:[labelInputName stringValue] forKey:@"name"];
  
  [[SJAPIRequest sharedAPIRequest] sendRequestRenameTable:tableName query:params callback:function (js) {
    [parentController renameTableComplete:js];
    [CPApp endSheet:[self window]];
  }];
}

- (void)didClickCancelBtn:(CPButton)sender
{
  [CPApp endSheet:[self window]];
}

- (void)willDisplayController
{
  [labelTitle setStringValue:@"Rename Table '"+ [self tableName] +"' to:"];
  [labelInputName setStringValue:@""];
  [[self window] makeFirstResponder:labelInputName];
}

@end