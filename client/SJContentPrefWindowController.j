@import <Foundation/CPObject.j>

@implementation SJContentPrefWindowController : CPWindowController
{
  CPTextField labelInputName;
}

- (id)init {
  self = [super initWithWindow:[[CPWindow alloc] initWithContentRect:CGRectMake(0,0, 300, 150) styleMask:CPDocModalWindowMask]];
  [self setup];
  return self;
}


- (void)setup
{
  var contentView = [[self window] contentView];
  
  var labelTitle = [[CPTextField alloc] initWithFrame:CGRectMake(10, 14, 95, 20)];
  [labelTitle setAlignment:CPRightTextAlignment];
  [labelTitle setStringValue:@"Jump to page:"];
  [contentView addSubview:labelTitle];
  
  labelInputName = [[CPTextField alloc] initWithFrame:CGRectMake(110, 10, 65, 28)];
  [labelInputName setStringValue:@"1"];
  [labelInputName setEditable:YES];
  [labelInputName setEnabled:YES];
  [labelInputName setBezeled:YES];
  [labelInputName setFont:[CPFont boldSystemFontOfSize:12.0]];   
  [contentView addSubview:labelInputName];
  
  var pageBtn = [[CPButton alloc] initWithFrame:CGRectMake(185, 12, 70, 30)];
  [pageBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
  [pageBtn setTitle:@"  Go  "];
  [pageBtn sizeToFit];
  var pageBtnFrame = [pageBtn frame];
  pageBtnFrame.size.width = 100;
  [pageBtn setFrame:pageBtnFrame];
  [pageBtn setTarget:self];
  [pageBtn setAction:@selector(goToPageAction:)];
  [contentView addSubview:pageBtn];
  
  var limitBox = [[CPCheckBox alloc] initWithFrame:CGRectMake(10, 55, 100, 30)];
  [limitBox setTitle:@"Limit result to:"];
  [limitBox sizeToFit];
  [contentView addSubview:limitBox];

  var limitRowsField = [[CPTextField alloc] initWithFrame:CGRectMake(110, 50, 65, 28)];
  [limitRowsField setStringValue:@"100"];
  [limitRowsField setEditable:YES];
  [limitRowsField setEnabled:YES];
  [limitRowsField setBezeled:YES];
  [limitRowsField setFont:[CPFont boldSystemFontOfSize:12.0]];
  [contentView addSubview:limitRowsField];
  
  var limitToRowsTxt = [[CPTextField alloc] initWithFrame:CGRectMake(175, 55, 65, 28)];
  [limitToRowsTxt setStringValue:@"rows"];
  [limitToRowsTxt sizeToFit];
  [contentView addSubview:limitToRowsTxt];
  
  var deferLoadingCheckbox = [[CPCheckBox alloc] initWithFrame:CGRectMake(10, 85, 100, 28)];
  [deferLoadingCheckbox setTitle:@"Defer loading of blobs and texts"];
  [deferLoadingCheckbox sizeToFit];
  [contentView addSubview:deferLoadingCheckbox];

  var saveBtn = [[CPButton alloc] initWithFrame:CGRectMake(185, 113, 70, 30)];
  [saveBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
  [saveBtn setTitle:@" Save "];
  [saveBtn sizeToFit];
  var saveBtnFrame = [saveBtn frame];
  saveBtnFrame.size.width = 100;
  [saveBtn setFrame:saveBtnFrame];
  [saveBtn setTarget:self];
  [saveBtn setAction:@selector(saveAction:)];
  [contentView addSubview:saveBtn];
}

- (void)goToPageAction:(CPButton)sender {
  var pageNumber = [labelInputName stringValue];
  console.log(@"Go To Page: "+ pageNumber);
}

- (void)saveAction:(CPButton)sender {
  [CPApp endSheet:[self window]];
}

- (void)willDisplayController {
  console.log(@"SJContentPrefWIndowController, will display");
}

@end
