@import <Foundation/CPObject.j>

@implementation SJContentPrefWindowController : CPWindowController
{
  CPTextField labelInputName;
  CPTextField limitRowsField;
  CPCheckBox deferLoadingCheckbox;
  id parentController @accessors;
}

- (id)init {
  self = [super initWithWindow:[[CPWindow alloc] initWithContentRect:CGRectMake(0,0, 300, 150) styleMask:CPDocModalWindowMask]];
  [self setup];
  return self;
}

- (id)initWithParentController:(id)aController
{
  self = [super initWithWindow:[[CPWindow alloc] initWithContentRect:CGRectMake(0,0, 300, 150) styleMask:CPDocModalWindowMask]];
  [self setParentController:aController];
  [self setup];
  return self;
}
}

- (CPInteger)limit
{
  return [parentController limit];
}

- (CPInteger)offset
{
  return [parentController offset];
}

- (CPInteger)pageNumber
{
  return ([self offset] / [self limit]) + 1;
}

- (CPInteger)totalRows
{
  return [parentController totalRows];
}

- (void)setup
{
  var contentView = [[self window] contentView];
  
  var labelTitle = [[CPTextField alloc] initWithFrame:CGRectMake(10, 14, 95, 20)];
  [labelTitle setAlignment:CPRightTextAlignment];
  [labelTitle setStringValue:@"Jump to page:"];
  [contentView addSubview:labelTitle];
  
  labelInputName = [[CPTextField alloc] initWithFrame:CGRectMake(110, 10, 65, 28)];
  [labelInputName setStringValue:[self pageNumber]];
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
  
  var limitBox = [[CPTextField alloc] initWithFrame:CGRectMake(10, 55, 100, 30)];
  [limitBox setStringValue:@"Limit result to:"];
  [limitBox setAlignment:CPRightTextAlignment];
  [contentView addSubview:limitBox];

  limitRowsField = [[CPTextField alloc] initWithFrame:CGRectMake(110, 50, 65, 28)];
  [limitRowsField setStringValue:[self limit]];
  [limitRowsField setEditable:YES];
  [limitRowsField setEnabled:YES];
  [limitRowsField setBezeled:YES];
  [limitRowsField setFont:[CPFont boldSystemFontOfSize:12.0]];
  [contentView addSubview:limitRowsField];
  
  var limitToRowsTxt = [[CPTextField alloc] initWithFrame:CGRectMake(175, 55, 65, 28)];
  [limitToRowsTxt setStringValue:@"rows"];
  [limitToRowsTxt sizeToFit];
  [contentView addSubview:limitToRowsTxt];
  
  deferLoadingCheckbox = [[CPCheckBox alloc] initWithFrame:CGRectMake(10, 85, 100, 28)];
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
  var pageNumber = parseInt([labelInputName stringValue]);
  if(pageNumber <= 0) {
    return;
  }

  var currentLimit = parseInt([limitRowsField stringValue]);
  var currentOffset = (pageNumber - 1) * currentLimit;

  if (currentOffset <= [self totalRows] && currentOffset >= 0) {
    [parentController refreshWithOffset:currentOffset withLimit:currentLimit];
  }
}

- (void)saveAction:(CPButton)sender {
  var currentLimit = parseInt([limitRowsField stringValue]);
  if(currentLimit < 0) return;
  [parentController setLimit:currentLimit]; 
  var shouldDefer = [deferLoadingCheckbox state] == CPOnState ? YES : NO;
  [parentController setDeferLoadingBlobsAndText:shouldDefer];
  [parentController refreshAction:nil];

  [CPApp endSheet:[self window]];
}

- (void)willDisplayController {
  [deferLoadingCheckbox setState:([parentController deferLoadingBlobsAndText] ? CPOnState : CPOffState)];
}

@end
