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
	var posY = 0;
	offset = (idx <= 0 ? 0 : idx - 1);
	
	if(idx > 0) {
		posY = offset + 16 * idx;
	} else {
		posY = 0;
	}
	
	if(posY === 0) {
		posY += 16;
	} else {
		posY = posY * 2 + 16;
	}

	   // Label Name for connection
	  var label = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,120,28)]; 
	  [label setStringValue:aTextFieldName]; 
	  [label setFont:[CPFont boldSystemFontOfSize:12.0]]; 
	  [label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
	  [label setFrameOrigin:CGPointMake(0, posY)]; 
	  [label setEditable:NO]; 
	  [label setBezeled: NO]; 
	  [label setVerticalAlignment:CPCenterVerticalTextAlignment];
		[label setBackgroundColor:[CPColor redColor]];
		
	  [contentView addSubview:label];

	  // Name for connection
	  var nameField = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,150,28)]; 
	  [nameField setStringValue:aLabelName]; 
	  [nameField setFont:[CPFont boldSystemFontOfSize:12.0]]; 
	  [nameField setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
	  [nameField setFrameOrigin:CGPointMake(120, posY)]; 
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
}

@end