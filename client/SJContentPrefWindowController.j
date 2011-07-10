@import <Foundation/CPObject.j>

@implementation SJContentPrefWindowController : CPWindowController

- (id)init {
  self = [super initWithWindow:[[CPWindow alloc] initWithContentRect:CGRectMake(0,0, 300, 150) styleMask:CPDocModalWindowMask]];
  [self setup];
  return self;
}


- (void)setup
{
  var contentView = [[self window] contentView];
  
  var labelTitle = [[CPTextField alloc] initWithFrame:CGRectMake(20, 10, 290, 20)];
  [labelTitle setAlignment:CPLeftTextAlignment];
  [labelTitle setStringValue:@"TODO: Content will go here...."];
  [labelTitle setFont:[CPFont boldSystemFontOfSize:12.0]];
  [contentView addSubview:labelTitle];
  
}

- (void)willDisplayController {
  console.log(@"SJContentPrefWIndowController, will display");
}

@end
