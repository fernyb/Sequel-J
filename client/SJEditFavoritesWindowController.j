
@import <Foundation/CPObject.j>
@import "SJEditFavoriteWindow.j"


@implementation SJEditFavoritesWindowController : CPWindowController
{
  func windowDidLoadCallback;
  @outlet CPSplitView splitview;
  CPArray favorites;
  LPMultiLineTextField textview;
}

- (id)init {
  self = [super initWithWindowCibName:@"SJEditFavoritesWindow" owner:self];
  return self;
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
  favorites = [CPArray array];
}

- (void)windowDidLoad
{
  [self addLeftView];
  [self addRightView];
  
  if (windowDidLoadCallback) {
    windowDidLoadCallback([self window]);
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
  var tableView = [[CPTableView alloc] initWithFrame:[scrollView bounds]];
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
  [[column headerView] setValue:[scrollView backgroundColor] forThemeAttribute:@"background-color"];
  [[column headerView] setValue:[CPColor colorWithHexString:@"626262"] forThemeAttribute:@"text-color"];
  [[column headerView] setValue:[CPFont boldSystemFontOfSize:12] forThemeAttribute:@"text-font"];
  [tableView addTableColumn:column];
  
  [scrollView setDocumentView:tableView];
  [[self contentLeftView] addSubview:scrollView];
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(CPInteger)aRow
{
  //var tablename = [filteredTableList objectAtIndex:aRow];
  //[[CPNotificationCenter defaultCenter] postNotificationName:TABLE_SELECTED_NOTIFICATION object:tablename];
 return YES;
}

- (CPNumber)numberOfRowsInTableView:(CPTableView)aTableView
{
  return [favorites count];
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)row
{
  return @"Row: "+ row;
}


- (void)addRightView
{
  [[self contentRightView] setBackgroundColor:[CPColor colorWithHexString:@"eee"]];
  
  var label = [[CPTextField alloc] initWithFrame:CGRectMake(10, 20, 85, 20)];
  [label setAlignment:CPLeftTextAlignment];
  [label setStringValue:@"Query Name:"];
  [label setFont:[CPFont boldSystemFontOfSize:12.0]];
  [[self contentRightView] addSubview:label];

  var favNameField = [[CPTextField alloc] initWithFrame:CGRectMake(5 + [label frame].origin.x + [label frame].size.width, 16, 355, 28)];
  [favNameField setAlignment:CPLeftTextAlignment];
  [favNameField setStringValue:@""];  
  [favNameField setEditable:YES];
  [favNameField setEnabled:YES];
  [favNameField setBezeled:YES];
  [favNameField setFont:[CPFont boldSystemFontOfSize:12.0]];
  [[self contentRightView] addSubview:favNameField];
    
    // Add the Query TextView
  textview = [[LPMultiLineTextField alloc] initWithFrame:CGRectMake(10, 48, CGRectGetWidth([[self contentRightView] frame]) - 20, CGRectGetHeight([[self contentRightView] frame]) - 100)];
  [textview setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [textview setEditable:YES];
  [textview setBezeled:YES];
  [textview setAlignment:CPLeftTextAlignment];
  [textview setFont:[CPFont systemFontOfSize:12.0]];
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
  [CPApp endSheet:[self window] returnCode:CPCancelButton];
}

- (void)didClickSaveBtn:(CPButton)sender
{
  [CPApp endSheet:[self window] returnCode:CPOKButton];  
}

@end
