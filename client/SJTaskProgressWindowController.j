@import "EKActivityIndicatorView.j"

var sharedTaskProgressWindowController = nil;

@implementation SJTaskProgressWindowController : CPWindowController
{
	CPBox					contentView;
	CPTextField				taskNameTextField;
	EKActivityIndicatorView activityIndicator;
	CPButton				cancelButton;
	id						callback;
	BOOL					isEnqueued @accessors;
}

+ (id)sharedTaskProgressWindowController
{
	if( !sharedTaskProgressWindowController )
		sharedTaskProgressWindowController = [[SJTaskProgressWindowController alloc] init];
	
	return sharedTaskProgressWindowController;
}

- (id)init
{
	self = [super init];
	
	[self setWindow:[[CPWindow alloc] initWithContentRect:CGRectMake(0,0,430,90) styleMask:CPBorderlessWindowMask]];

	[[self window] setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];   
	[[self window] center];
	[[self window] setAlphaValue:0.90];
	
	contentView = [[CPBox alloc] initWithFrame:CGRectMake(0,0,430,90)];
	[contentView setBorderColor:[CPColor whiteColor]]; 
	[contentView setFillColor:[CPColor colorWithHexString:@"444"]];
	[contentView setCornerRadius:10]; 
	[contentView setBorderType:CPLineBorder]; 
	[contentView setBorderWidth:1]; 
	
	taskNameTextField = [[CPTextField alloc] initWithFrame:CGRectMake(100, 12, 300,24)];
	[taskNameTextField setFont:[CPFont boldSystemFontOfSize:13]];
	[taskNameTextField setTextColor:[CPColor whiteColor]];
	[taskNameTextField setTextShadowColor:[CPColor colorWithHexString:@"000"]];
	[taskNameTextField setTextShadowOffset:CGSizeMake(1, 1)];
	[taskNameTextField setStringValue:@"Running query..."];
	
	activityIndicator = [[EKActivityIndicatorView alloc] initWithFrame:CGRectMake(12, 12, 65, 65)];
	[activityIndicator setColor:[CPColor whiteColor]];
	[activityIndicator startAnimating];
	
	cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(290, 60, 130, 24)];
	[cancelButton setTarget:self];
	[cancelButton setAction:@selector(cancelButtonWasPressed:)];
	[cancelButton setTitle:@"Cancel"];
	[cancelButton setTheme:[CPTheme themeNamed:@"Aristo-HUD"]];
	[cancelButton setBezelStyle:CPRoundedBezelStyle];
	
	[contentView addSubview:activityIndicator];
	[contentView addSubview:taskNameTextField];
	[contentView addSubview:cancelButton];
		
	[[self window] setContentView:contentView];
	
	return self;
}

- (void)showTaskProgressWindowForTitle:(CPString)aTitle
{
	[cancelButton setHidden:YES];
	[taskNameTextField setStringValue:aTitle];
	[self setIsEnqueued:YES];
	callback = nil;
	
	setTimeout( function() {
		if( [self isEnqueued] )
			[[self window] orderFront:self];
	
	}, 2000 );
}

- (void)showTaskProgressWindowForTitle:(CPString)aTitle withCancelCallback:(id)aCallback
{
	[cancelButton setHidden:NO];
	[self setIsEnqueued:YES];

	[taskNameTextField setStringValue:aTitle];
	
	setTimeout( function() {
		if( [self isEnqueued] )
			[[self window] orderFront:self];
	
	}, 2000 );
	
	callback = aCallback;
}

- (void)hideTaskProgressWindowForCurrentTask
{
	[self setIsEnqueued:NO];
	[[self window] orderOut:self];
}

- (void)cancelButtonWasPressed:(id)sender
{
	[self hideTaskProgressWindowForCurrentTask];
	callback();
}