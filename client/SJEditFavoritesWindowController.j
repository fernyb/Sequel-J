
@import <Foundation/CPObject.j>
@import "SJEditFavoriteWindow.j"
@import "LPMultiLineTextField.j"
@import "SJConstants.j"
@import "Categories/CPArray+Categories.j"


@implementation SJEditFavoritesWindowController : CPWindowController
{
  func windowDidLoadCallback;
  @outlet CPSplitView splitview;
  CPTextField favNameField;
  LPMultiLineTextField textview;
  CPTableView tableView;
  CPArray favoritesList;
}

- (id)init {
  self = [super initWithWindowCibName:@"SJEditFavoritesWindow" owner:self];
  favoritesList = nil;
  return self;
}

- (CPArray)favorites
{
  if(!favoritesList) {
    var tmp = [[CPUserDefaults standardUserDefaults] objectForKey:QUERY_FAVORITES];
    if(!tmp) {
      favoritesList = [CPArray array];
    } else {
      favoritesList = [tmp copyArrayContents];
    }
  }
  return favoritesList;
}


- (CPView)contentLeftView
{
  return [[splitview subviews] objectAtIndex:0];
}

- (CPView)contentRightView
{
  return [[splitview subviews] objectAtIndex:1];
}

- (void)windowWillLoad
{
}

- (void)windowDidLoad
{
  [self addLeftView];
  [self addRightView];
  
  if (windowDidLoadCallback) {
    windowDidLoadCallback([self window]);
  }
  [[self window] setDelegate:self];
}

- (void)windowDidBecomeKey:(CPNotification)aNotification
{
  favoritesList = nil;
  if(tableView) {
    [tableView reloadData];
  }
}

- (void)windowLoadWithCallback:(func)callback
{
  windowDidLoadCallback = callback;
  [self window];
}

- (void)addLeftView
{
  var width = [[self contentLeftView] frame].size.width;
  var height = [[self contentLeftView] frame].size.height;
  
  // create a CPScrollView that will contain the CPTableView
  var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0,0, width, height)];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setAutohidesScrollers:YES];
  [scrollView setHasHorizontalScroller:NO];
  [scrollView setBackgroundColor:[CPColor colorWithHexString:@"DEE4EA"]];
  
  // create the CPTableView
  tableView = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
  [tableView setDataSource:self];
  [tableView setDelegate:self];
  [tableView setColumnAutoresizingStyle:CPTableViewLastColumnOnlyAutoresizingStyle];
  [tableView setSelectionHighlightStyle:CPTableViewSelectionHighlightStyleSourceList];
  [tableView setCornerView:nil];
  [tableView setBackgroundColor:[scrollView backgroundColor]];
  [tableView setAllowsEmptySelection:NO];
  [tableView setRowHeight:20];
  
  var column = [[CPTableColumn alloc] initWithIdentifier:@"SJTableFavoritesColumn"];
  [[column headerView] setStringValue:@"Favorites"];
  [column setWidth:(width - 15)];
  [[column headerView] setValue:[CPColor colorWithHexString:@"626262"] forThemeAttribute:@"text-color"];
  [[column headerView] setValue:[CPFont boldSystemFontOfSize:12] forThemeAttribute:@"text-font"];
  
  var columnDataView = [[CPTextField alloc] initWithFrame:CGRectMake(0, 0, width - 17, 24)];
	[columnDataView setLineBreakMode:CPLineBreakByTruncatingTail];
	[column setDataView:columnDataView];
	
  [tableView addTableColumn:column];
  
  [scrollView setDocumentView:tableView];
  [[self contentLeftView] addSubview:scrollView];
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(CPInteger)row
{
  [favNameField resignFirstResponder];
  [textview resignFirstResponder];
  
  var item = [[self favorites] objectAtIndex:row];
  [favNameField setStringValue:[item objectForKey:@"name"]];
  [textview setStringValue:[item objectForKey:@"value"]];
  
  return YES;
}

- (CPNumber)numberOfRowsInTableView:(CPTableView)aTableView
{
  return [[self favorites] count];
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)row
{
  var item = [[self favorites] objectAtIndex:row];
  return [item objectForKey:@"name"];
}


- (void)addRightView
{
  [[self contentRightView] setBackgroundColor:[CPColor colorWithHexString:@"eee"]];
  
  var label = [[CPTextField alloc] initWithFrame:CGRectMake(10, 20, 85, 20)];
  [label setAlignment:CPLeftTextAlignment];
  [label setStringValue:@"Query Name:"];
  [label setFont:[CPFont boldSystemFontOfSize:12.0]];
  [[self contentRightView] addSubview:label];

  favNameField = [[CPTextField alloc] initWithFrame:CGRectMake(5 + [label frame].origin.x + [label frame].size.width, 16, 385, 28)];
  [favNameField setAlignment:CPLeftTextAlignment];
  [favNameField setStringValue:@""];  
  [favNameField setEditable:YES];
  [favNameField setEnabled:YES];
  [favNameField setBezeled:YES];
  [favNameField setFont:[CPFont systemFontOfSize:12.0]];
  [favNameField setDelegate:self];
  [[self contentRightView] addSubview:favNameField];
    
    // Add the Query TextView
  textview = [[LPMultiLineTextField alloc] initWithFrame:CGRectMake(10, 48, CGRectGetWidth([[self contentRightView] frame]) - 20, CGRectGetHeight([[self contentRightView] frame]) - 100)];
  [textview setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [textview setEditable:YES];
  [textview setBezeled:YES];
  [textview setAlignment:CPLeftTextAlignment];
  [textview setFont:[CPFont systemFontOfSize:12.0]];
  [textview setDelegate:self];
  [[self contentRightView] addSubview:textview];
  
  var cancelBtn = [[CPButton alloc] initWithFrame:CGRectMake(CGRectGetWidth([[self contentRightView] frame]) - 128, 8 + [textview frame].size.height + [textview frame].origin.y, 100, 23)];
  [cancelBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
  [cancelBtn setTitle:@"Cancel"];
  [cancelBtn sizeToFit];
  [cancelBtn setTarget:self];
  [cancelBtn setAction:@selector(didClickCancelBtn:)];
  [[self contentRightView] addSubview:cancelBtn];
  
  var saveBtn = [[CPButton alloc] initWithFrame:CGRectMake(10 + [cancelBtn frame].origin.x + [cancelBtn frame].size.width, [cancelBtn frame].origin.y, 100, 23)];
  [saveBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
  [saveBtn setTitle:@" Save "];
  [saveBtn sizeToFit];
  [saveBtn setTarget:self];
  [saveBtn setAction:@selector(didClickSaveBtn:)];
  [[self contentRightView] addSubview:saveBtn];
}

- (void)didClickCancelBtn:(CPButton)sender
{
  [self endSheet];
}

- (void)didClickSaveBtn:(CPButton)sender
{
  var row = [tableView selectedRow];
  if(row > -1) {
    var favs = [self favorites];
    var item = [favs objectAtIndex:row];
    var newKey = [favNameField stringValue];
    var newValue = [textview stringValue];
    
    [item setObject:newKey forKey:@"name"];
    [item setObject:newValue forKey:@"value"];
    
    [[CPUserDefaults standardUserDefaults] setObject:favs forKey:QUERY_FAVORITES];
    [self endSheet];
  }
}

- (void)endSheet
{
  [CPApp endSheet:[self window]];
  [tableView deselectRow:[tableView selectedRow]];
  [favNameField setStringValue:@""];
  [textview setStringValue:@""];
}

- (void)controlTextDidChange:(CPNotification)aNotification
{
  var row = [tableView selectedRow];
  if(row > -1) {
    var item = [[self favorites] objectAtIndex:row];      
    var sender = [aNotification object];
    var value = [sender stringValue];
    
    if([sender className] == @"CPTextField") {
      [item setObject:value forKey:@"name"];
      [tableView reloadData];
    }
    else if ([sender className] == @"LPMultiLineTextField") {
      [item setObject:value forKey:@"value"];
    }
  }
}

@end
