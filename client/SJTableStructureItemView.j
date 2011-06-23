@import <Foundation/Foundation.j>
@import "SJImageView.j"


var ICON_SIZE = CGSizeMake(14, 17);

@implementation SJTableStructureItemView : CPView
{
  CPImageView iconView;
	CPTextField	textField;
	CPArray items @accessors;
	CPString columnIdentifier @accessors;
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
  var menu = [[CPMenu alloc] initWithTitle:@"Items"];
  var menuItem;
  
  for(var i=0; i<[items count]; i++) {
    var itemName = [items objectAtIndex:i];
    if (itemName != '') {
      menuItem = [[CPMenuItem alloc] initWithTitle:itemName action:@selector(updateExtraField:) keyEquivalent:nil];
      [menuItem setRepresentedObject:columnIdentifier];
      [menuItem setTarget:self];
      [menu addItem:menuItem];
    } else {
      [menu addItem:[CPMenuItem separatorItem]];
    }
  }
  
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
    [tableViewDelegate updateFieldWithValue:title forColumnIdentifier:columnIdentifier];
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
  items = [coder decodeObjectForKey:@"items"];
  columnIdentifier = [coder decodeObjectForKey:@"columnIdentifier"];
  
	return self;
}

- (void)encodeWithCoder:(CPCoder)coder 
{
	[super encodeWithCoder:coder];
	[coder encodeObject:iconView forKey:@"iconView"];
	[coder encodeObject:textField forKey:@"textField"];
	[coder encodeObject:items forKey:@"items"];
	[coder encodeObject:columnIdentifier forKey:@"columnIdentifier"];
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