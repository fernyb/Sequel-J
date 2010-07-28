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

- (void)addTextField:(CPString)aTextFieldName 
					 withLabel:(CPString)aLabelName 
					atPosition:(CPInteger)idx
{
	var offset = 0;
	var posX = ([contentView frame].size.width - 300) / 2;
	var startAtY = 100;
	var posY;
	
	offset = (idx <= 0 ? 0 : idx - 1);
	posY = (idx * 30) + startAtY;

   // Label Name for connection
  var label = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,120,28)]; 
  [label setStringValue:aTextFieldName]; 
  [label setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [label setFrameOrigin:CGPointMake(posX, posY)]; 
  [label setEditable:NO]; 
  [label setBezeled: NO]; 
  [label setVerticalAlignment:CPCenterVerticalTextAlignment];
	[label setBackgroundColor:[CPColor clearColor]];
	
  [contentView addSubview:label];

  // Name for connection
  var nameField = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,150,28)]; 
  [nameField setStringValue:aLabelName]; 
  [nameField setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [nameField setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [nameField setFrameOrigin:CGPointMake(posX + 120, posY)]; 
  [nameField setEditable:YES]; 
  [nameField setBezeled: YES]; 

  [contentView addSubview:nameField];
}

- (void)setupView
{ 
	[self addTextField:@"Name" withLabel:@"Name" atPosition:0];
	[self addTextField:@"Host" withLabel:@"Host" atPosition:1];
	[self addTextField:@"Username" withLabel:@"Username" atPosition:2];
	[self addTextField:@"Password" withLabel:@"Password" atPosition:3];	
	
	// TODO: Fix the button
	var loginbtn = [[CPButton alloc] initWithFrame:CGRectMake(504, 226, 100, 24)];
	[loginbtn setBordered:YES];
	[loginbtn setTitle:@"Connect"];
	[loginbtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
	[contentView addSubview:loginbtn];
	
	[contentView setBackgroundColor:[CPColor colorWithHexString:"eeeeee"]];
}

@end