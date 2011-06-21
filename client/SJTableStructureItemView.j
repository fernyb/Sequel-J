@import <Foundation/Foundation.j>
@import "SJImageView.j"

var ICON_SIZE = CGSizeMake(14, 17);

@implementation SJTableStructureItemView : CPView
{
  CPImageView iconView;
	CPTextField	textField;
	CPObject mainController @accessors;
}

- (id)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
  
  var originX = (aRect.size.width - ICON_SIZE.width) - 3;
	iconView = [[SJImageView alloc] initWithFrame:CGRectMake(originX, 2, ICON_SIZE.width, ICON_SIZE.height)];
	[iconView setImage: [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"selection-dropdown.png"] size:ICON_SIZE] ];
  [iconView setDelegate:self];
	
	textField = [[CPTextField alloc] initWithFrame:CGRectMake(2, 0, aRect.size.width - (ICON_SIZE.width + 6), aRect.size.height)];
	[textField setLineBreakMode:CPLineBreakByTruncatingTail];
	[textField setFont:[CPFont systemFontOfSize:11.0]];

	[self addSubview:textField];
	[self addSubview:iconView];
	
	[iconView setAutoresizingMask:CPViewMinYMargin | CPViewMinXMargin];
	[textField setAutoresizingMask:CPViewWidthSizable];

	return self;
}


- (void)imageViewMouseDown:(CPEvent)anEvent
{
  var menu = [[CPMenu alloc] initWithTitle:@"Extra"];
  var menuItem;
  menuItem = [[CPMenuItem alloc] initWithTitle:@"none" action:@selector(updateExtraField:) keyEquivalent:nil];
  [menuItem setTarget:self];
  [menu addItem:menuItem];

  menuItem = [[CPMenuItem alloc] initWithTitle:@"auto_increment" action:@selector(updateExtraField:) keyEquivalent:nil];
  [menuItem setTarget:self];
  [menu addItem:menuItem];

  menuItem = [[CPMenuItem alloc] initWithTitle:@"on update CURRENT_TIMESTAMP" action:@selector(updateExtraField:) keyEquivalent:nil];
  [menuItem setTarget:self];
  [menu addItem:menuItem];
  
  var point = [anEvent locationInWindow];
  
  var anEvent = [CPEvent mouseEventWithType:CPLeftMouseDown 
                                   location:point 
                              modifierFlags:0 
                                  timestamp:[[CPApp currentEvent] timestamp]
                               windowNumber:[[self window] windowNumber]
                                    context:nil
                                eventNumber:1
                                 clickCount:1 
                                   pressure:0.0];

  [CPMenu popUpContextMenu:menu withEvent:anEvent forView:self];
}

- (void)updateExtraField:(CPMenuItem)menuItem
{
  var title = [menuItem title];
  
  var controller = [self superview]; /* CPTableView */
  if ([controller respondsToSelector:@selector(delegate)]) {
    var tableViewDelegate = [controller delegate];
    [tableViewDelegate extraFieldDidUpdate:title];
  }
}


- (void)setFrame:(CGRect)aFrame
{
  [super setFrame:aFrame];
  
  var originX = (aFrame.size.width - ICON_SIZE.width) - 3;
  [iconView setFrame:CGRectMake(originX, 2, ICON_SIZE.width, ICON_SIZE.height)];
}

- (id)initWithCoder:(CPCoder)coder
{
	self = [super initWithCoder:coder];
	iconView = [coder decodeObjectForKey:@"iconView"];
	[iconView setDelegate:self];
	
	textField = [coder decodeObjectForKey:@"textField"];

	return self;
}

- (void)encodeWithCoder:(CPCoder)coder 
{
	[super encodeWithCoder:coder];
	[coder encodeObject:iconView forKey:@"iconView"];
	[coder encodeObject:textField forKey:@"textField"];
}

- (void)setObjectValue:(CPString)aString
{
  [textField setStringValue:aString];
  if(aString == null || aString == '') {
    [iconView setHidden:YES];
  } else {
    [iconView setHidden:NO];
  }
}

- (void)setThemeState:(CPThemeState)aState
{
  [super setThemeState:aState];
  [textField setThemeState:aState];
}

- (void)unsetThemeState:(CPThemeState)aState
{
  [super unsetThemeState:aState];
  [textField unsetThemeState:aState];
}


@end