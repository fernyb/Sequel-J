@import <Foundation/Foundation.j>

@implementation SJLoginViewController : CPObject
{
  CPView contentView;
}

- (id)initWithView:(CPView)aView
{
  if (self = [super init]) {
    contentView = aView;
    [self setupView];
  }
  return self;
}

- (void)setupView
{ 
    // Label Name for connection
  var nameFieldLabel = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,120,28)]; 
  [nameFieldLabel setStringValue:@"Name"]; 
  [nameFieldLabel setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [nameFieldLabel setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [nameFieldLabel setFrameOrigin:CGPointMake(0,16)]; 
  [nameFieldLabel setEditable:NO]; 
  [nameFieldLabel setBezeled: NO]; 
  [nameFieldLabel setVerticalAlignment:CPCenterVerticalTextAlignment];
  [contentView addSubview:nameFieldLabel];
     
  // Name for connection
  var nameField = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,150,28)]; 
  [nameField setStringValue:@"Name"]; 
  [nameField setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [nameField setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [nameField setFrameOrigin:CGPointMake(120,16)]; 
  [nameField setEditable:YES]; 
  [nameField setBezeled: YES]; 
  [contentView addSubview:nameField];

    // Label Host Label
  var hostFieldLabel = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,120,28)]; 
  [hostFieldLabel setStringValue:@"Host"]; 
  [hostFieldLabel setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [hostFieldLabel setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [hostFieldLabel setFrameOrigin:CGPointMake(0, (16 * 1) + (16 * 2))]; 
  [hostFieldLabel setEditable:NO]; 
  [hostFieldLabel setBezeled: NO]; 
  [hostFieldLabel setVerticalAlignment:CPCenterVerticalTextAlignment];
  [contentView addSubview:hostFieldLabel];  
  
  // Host
  var hostField = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,150,28)]; 
  [hostField setStringValue:@"Host"]; 
  [hostField setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [hostField setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [hostField setFrameOrigin:CGPointMake(120, (16 * 1) + (16 * 2))]; 
  [hostField setEditable:YES]; 
  [hostField setBezeled: YES]; 
  
  [contentView addSubview:hostField];

  // Username
  var usernameField = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,150,28)]; 
  [usernameField setStringValue:@"Username"]; 
  [usernameField setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [usernameField setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [usernameField setFrameOrigin:CGPointMake(0, (16 * 2) + (16 * 3) )]; 
  [usernameField setEditable:YES]; 
  [usernameField setBezeled: YES]; 
  
  [contentView addSubview:usernameField];

  // Password
  var passwordField = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,150,28)]; 
  [passwordField setStringValue:@"Password"]; 
  [passwordField setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [passwordField setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [passwordField setFrameOrigin:CGPointMake(0, (16 * 3) + (16 * 4) )]; 
  [passwordField setEditable:YES]; 
  [passwordField setBezeled: YES]; 
  
  [contentView addSubview:passwordField];     
}

@end