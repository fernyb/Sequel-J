@implementation SJTableListItemDataView : CPView
{
	CPImageView		tableIconView;
	CPTextField		tableNameLabel;
	CPString		tableName @accessors;
}

- (id)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	
	tableNameLabel = [[CPTextField alloc] initWithFrame:CGRectMake(40,0,aRect.size.width - 40,aRect.size.height)];
	tableIconView = [[CPImageView alloc] initWithFrame:CGRectMake(20,3,17,15)];

	[tableIconView setImage:
		[[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"table-small.png"] size:CPSizeMake(17, 15)]];
		
	[tableNameLabel setLineBreakMode:CPLineBreakByTruncatingTail];
	[tableNameLabel setFont:[CPFont systemFontOfSize: 11.5]];
	
	[self addSubview:tableNameLabel];
	[self addSubview:tableIconView];
	[tableNameLabel setAutoresizingMask:CPViewWidthSizable];

	return self;
}

- (id)initWithCoder:(CPCoder)coder
{
	self = [super initWithCoder:coder];
	
	tableIconView = [coder decodeObjectForKey:@"tableIconView"];
	tableNameLabel = [coder decodeObjectForKey:@"tableNameLabel"];
	tableName = [coder decodeObjectForKey:@"tableName"];
	
	[tableNameLabel bind:@"stringValue" toObject:self withKeyPath:@"tableName" options:nil];
		
	return self;
}

- (void)encodeWithCoder:(CPCoder)coder 
{
	[super encodeWithCoder:coder];
	[coder encodeObject:tableIconView forKey:@"tableIconView"];
	[coder encodeObject:tableNameLabel forKey:@"tableNameLabel"];
	[coder encodeObject:tableName forKey:@"tableName"];
}

- (void)setObjectValue:(CPString)aTableName
{
	[self setTableName:aTableName];
}

- (void)setThemeState:(CPThemeState)aState
{
    [super setThemeState:aState];
    [tableNameLabel setThemeState:aState];
}

- (void)unsetThemeState:(CPThemeState)aState
{
    [super unsetThemeState:aState];
    [tableNameLabel unsetThemeState:aState];
}


- (BOOL)respondsToSelector:(SEL)aSelector
{
  var b = [super respondsToSelector:aSelector];
  CPLog(aSelector);
  return b;
}

@end