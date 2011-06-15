
@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"
@import "Categories/CPTableView+Categories.j"
@import "LPMultiLineTextField.j"
@import "SJHTTPRequest.j"
@import "Categories/CPArray+Categories.j"
@import "Categories/CPDictionary+Categories.j"
@import "SJConstants.j"
@import "SJEditFavoritesWindowController.j"


@implementation SJQueryTabController : SJTabBaseController
{
  CPSplitView splitview;
  CPView topView;
  CPView bottomView;
  CPScrollView bottomScrollview;
  CPView topBar;
  CGFloat topBarHeight;
  LPMultiLineTextField textview;
  CPArray headerNames @accessors;
  CPArray queryResults @accessors;
  CPWindow favWindow;
  CPTextField favNameField;
  SJEditFavoritesWindowController editFavWindow;
  CPWindow confirmClearHisWin;
}

- (void)viewDidSet
{
  [[self view] setBackgroundColor:[CPColor colorWithHexString:"eeeeee"]];
  [self setHeaderNames:[CPArray array]];
  
  splitview = [[CPSplitView alloc] initWithFrame:[[self view] frame]];
  [splitview setVertical:NO];
  [splitview setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [splitview setIsPaneSplitter:NO];
  
  // Create the top view
  topView = [[CPView alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth([[self view] frame]), CGRectGetHeight([[self view] frame]) / 2)];
  [topView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [topView setBackgroundColor:[CPColor clearColor]];
  
  // Add the Query TextView
  textview = [[LPMultiLineTextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([topView frame]), CGRectGetHeight([topView frame]))];
  [textview setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [textview setEditable:YES];
  [textview setBezeled:YES];
  [textview setAlignment:CPLeftTextAlignment];
  [textview setFont:[CPFont systemFontOfSize:12.0]];
  [topView addSubview:textview];
  
  [splitview addSubview:topView];
  
  
  // Create the bottom view
  bottomView = [[CPView alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth([[self view] frame]), CGRectGetHeight([[self view] frame]) / 2)];
  [bottomView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [bottomView setBackgroundColor:[CPColor clearColor]];
  [bottomView setHidden:NO];
  
  // Create Bottom Top Bar
  topBarHeight = 28.0;
  topBar = [[CPView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[self view] frame]), topBarHeight)];
  [self addBottomBarButtons:topBar];
  [topBar setAutoresizingMask:CPViewWidthSizable | CPViewMaxYMargin];
  
  var img = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"bottom-top-bar.png"]];
  [topBar setBackgroundColor:[CPColor colorWithPatternImage:img]];
  [bottomView addSubview:topBar];
  
  bottomScrollview = [self createTableViewForView:bottomView headerNames:[self bottomTableHeaderNames]];
  [bottomScrollview setFrame:CGRectMake(0, topBarHeight, CGRectGetWidth([bottomScrollview frame]), CGRectGetHeight([bottomScrollview frame]) - topBarHeight)];
  [bottomView addSubview:bottomScrollview];
  [splitview addSubview:bottomView];
  
  // Add the splitview to the view
  [[self view] addSubview:splitview];
}

- (void)addBottomBarButtons:(CPView)bar
{
  var runCurrentBtn = [[CPButton alloc] initWithFrame:CGRectMake(CGRectGetWidth([bar frame]) - 95, 1, 100, 23)];
  [runCurrentBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
  [runCurrentBtn setTitle:@"Run Current"];
  [runCurrentBtn setBezelStyle:CPRoundedBezelStyle];
  [runCurrentBtn sizeToFit];
  [runCurrentBtn setTarget:self];
  [runCurrentBtn setAction:@selector(didClickRunCurrent:)];
  [bar addSubview:runCurrentBtn];
  
  var queryFavBtn = [[CPButton alloc] initWithFrame:CGRectMake(4, 1, 75, 23)];
  [queryFavBtn setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
  [queryFavBtn setTitle:@"Query Favorites"];
  [queryFavBtn setBezelStyle:CPRoundedBezelStyle];
  [queryFavBtn sizeToFit];
  [queryFavBtn setTarget:self];
  [queryFavBtn setAction:@selector(didClickQueryFavorites:)];
  [bar addSubview:queryFavBtn];

  var queryHisBtn = [[CPButton alloc] initWithFrame:CGRectMake([queryFavBtn frame].origin.x + CGRectGetWidth([queryFavBtn frame]) + 10, 1, 75, 23)];
  [queryHisBtn setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
  [queryHisBtn setTitle:@"Query History"];
  [queryHisBtn setBezelStyle:CPRoundedBezelStyle];
  [queryHisBtn sizeToFit];
  [queryHisBtn setTarget:self];
  [queryHisBtn setAction:@selector(didClickQueryHistory:)];
  [bar addSubview:queryHisBtn];  
}

- (CPString)currentQueryString
{
  var query = [CPString string];
  if( query = [textview stringValue] ) {
    var queries = query.split(";");
    queries = [queries compact];
    query = [queries count] > 1 ? [queries lastObject] : [queries objectAtIndex:0];  
  }
  return query;
}

- (void)didClickRunCurrent:(CPButton)sender
{
  var query = [self currentQueryString];
  if([query length] < 1) {
    return;
  }
  
  var querystr = [CPDictionary dictionary];
  [querystr setObject:query forKey:@"query"];
  
  [[SJAPIRequest sharedAPIRequest] sendRequestToQueryWithOptions:querystr callback:function( js ) {
    [self setHeaderNames:js.columns];
    [self setQueryResults:js.results];

    if(bottomScrollview) {
      [bottomScrollview removeFromSuperview];
      bottomScrollview = nil;
    }

    bottomScrollview = [self createTableViewForView:bottomView headerNames:[self headerNames]];
    [bottomScrollview setFrame:CGRectMake(0, topBarHeight, CGRectGetWidth([bottomScrollview frame]), CGRectGetHeight([bottomScrollview frame]) - topBarHeight)];
    [bottomView addSubview:bottomScrollview];
    [self keepQueryInHistory:query];
  }];
}

- (void)keepQueryInHistory:(CPString)query
{
  var queryHistory = [[CPUserDefaults standardUserDefaults] objectForKey:QUERY_HISTORY];
  if(!queryHistory) {
    queryHistory = [CPArray array];
  }
  if([queryHistory count] > 20) {
   [queryHistory removeObjectAtIndex:19];
  }
  
  [queryHistory addObject:query];
  [[CPUserDefaults standardUserDefaults] setObject:queryHistory forKey:QUERY_HISTORY];
}

- (CPArray)queryHistory
{
  var queryHistory = [[CPUserDefaults standardUserDefaults] objectForKey:QUERY_HISTORY];
  if(!queryHistory) {
    queryHistory = [CPArray array];
  }
  return queryHistory;
}

- (CPInteger)numberOfRowsInTableView:(CPTableView)aTableView
{
  return [[self queryResults] count];
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)rowIndex
{
  var row = [[self queryResults] objectAtIndex:rowIndex];
  var columnName = [[aTableColumn headerView] stringValue];
  return row[columnName];
}

- (void)didClickQueryFavorites:(CPButton)sender
{
  /* CPMenu */var menu = [[CPMenu alloc] initWithTitle:@"Favorites"];
  var menuItem;
  menuItem = [[CPMenuItem alloc] initWithTitle:@"Save to Favorites" action:@selector(saveToFavoritesAction:) keyEquivalent:nil];
  [menuItem setTarget:self];
  [menu addItem:menuItem];
  
  menuItem = [[CPMenuItem alloc] initWithTitle:@"Edit Favorites..." action:@selector(editFavoritesAction:) keyEquivalent:nil];
  [menuItem setTarget:self];
  [menu addItem:menuItem];
  
  var favs = [self queryFavorites];
  if([favs count] > 0) {
    [menu addItem:[CPMenuItem separatorItem]];
  }
  
  for(var i=0; i<[favs count]; i++) {
    var item = [favs objectAtIndex:i];
    var keyName = [item objectForKey:@"name"];
    
    menuItem = [[CPMenuItem alloc] initWithTitle:keyName action:@selector(didSelectSavedQuery:) keyEquivalent:nil];
    [menuItem setRepresentedObject:@"item-" + i];
    [menuItem setTarget:self];
    [menu addItem:menuItem];
  }
  
  var locationMenuPoint = [[[self contentView] superview] convertPoint:[sender frame].origin fromView:sender];
  locationMenuPoint.y += 40 * 2;
  
  [self showContextualMenu:menu atLocation:locationMenuPoint forView:sender];
}

- (void)didClickQueryHistory:(CPButton)sender
{
  /* CPMenu */var menu = [[CPMenu alloc] initWithTitle:@"Query History"];
  var menuItem;
  menuItem = [[CPMenuItem alloc] initWithTitle:@"Save History" action:@selector(saveHistoryAction:) keyEquivalent:nil];
  [menuItem setTarget:self];
  [menu addItem:menuItem];
  
  menuItem = [[CPMenuItem alloc] initWithTitle:@"Clear Global History" action:@selector(clearGlobalHistory:) keyEquivalent:nil];
  [menuItem setTarget:self];
  [menu addItem:menuItem];
  
  var hist = [self queryHistory];
  if([hist count] > 0) {
    [menu addItem:[CPMenuItem separatorItem]];
  }
  
  for(var i=0; i<[hist count]; i++) {
    var item = [hist objectAtIndex:i];
    
    menuItem = [[CPMenuItem alloc] initWithTitle:item action:@selector(didSelectHistoryQuery:) keyEquivalent:nil];
    [menuItem setRepresentedObject:@"item-" + i];
    [menuItem setTarget:self];
    [menu addItem:menuItem];
  }
  
  var locationMenuPoint = [[[self contentView] superview] convertPoint:[sender frame].origin fromView:sender];
  locationMenuPoint.y += 40 * 2;
  locationMenuPoint.x -= 122;
  
  [self showContextualMenu:menu atLocation:locationMenuPoint forView:sender];
}

- (void)showContextualMenu:(CPMenu)aMenu atLocation:(CPPoint)point forView:(id)aview
{
  var anEvent = [CPEvent mouseEventWithType:CPLeftMouseDown 
                                   location:point 
                              modifierFlags:0 
                                  timestamp:[[CPApp currentEvent] timestamp]
                               windowNumber:[[[self view] window] windowNumber]
                                    context:nil
                                eventNumber:1
                                 clickCount:1 
                                   pressure:0.0];

  [CPMenu popUpContextMenu:aMenu withEvent:anEvent forView:aview];    
}


- (void)saveToFavoritesAction:(CPMenuItem)sender
{
  if (!favWindow) {
    favWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(30,30, 400, 130) styleMask:CPDocModalWindowMask];
    var favContentView = [favWindow contentView];
    
    var label = [[CPTextField alloc] initWithFrame:CGRectMake(20, 20, 150, 20)];
    [label setAlignment:CPLeftTextAlignment];
    [label setStringValue:@"Query Name:"];
    [label setFont:[CPFont boldSystemFontOfSize:12.0]];
    [favContentView addSubview:label];
    
    favNameField = [[CPTextField alloc] initWithFrame:CGRectMake(20, 43, 360, 28)];
    [favNameField setAlignment:CPLeftTextAlignment];
    [favNameField setStringValue:@""];  
    [favNameField setEditable:YES];
    [favNameField setEnabled:YES];
    [favNameField setBezeled:YES];
    [favNameField setFont:[CPFont boldSystemFontOfSize:12.0]];
    [favContentView addSubview:favNameField];
      
    var cancelBtn = [[CPButton alloc] initWithFrame:CGRectMake(250, 86, 0, 0)];
    [cancelBtn setTitle:@"Cancel"];
    [cancelBtn setBezelStyle:CPRoundedBezelStyle];
    [cancelBtn sizeToFit];
    [cancelBtn setTarget:self];
    [cancelBtn setAction:@selector(didClickCancelQuerySheet:)];
    [favContentView addSubview:cancelBtn];
    
    var saveBtn = [[CPButton alloc] initWithFrame:CGRectMake(320, 86, 0, 0)];
    [saveBtn setTitle:@" Save "];
    [saveBtn setBezelStyle:CPRoundedBezelStyle];
    [saveBtn sizeToFit];
    [saveBtn setTarget:self];
    [saveBtn setAction:@selector(didClickSaveQuerySheet:)];
    [favContentView addSubview:saveBtn];
  }
  [favNameField becomeFirstResponder];
  [favNameField setStringValue:@""];
  
  [CPApp beginSheet: favWindow
          modalForWindow: [[self contentView] window]
           modalDelegate: self
          didEndSelector: null
             contextInfo: null];
}

- (void)didClickCancelQuerySheet:(CPButton)sender
{
  [CPApp endSheet:favWindow returnCode:CPCancelButton];
}

- (void)didClickSaveQuerySheet:(CPButton)sender
{
  var query = [self currentQueryString];
  if([query length] < 1) {
    return;
  }
  
  var saveQueryName = [favNameField stringValue];
  if(saveQueryName && [saveQueryName length] > 1 && saveQueryName != ' ') {
   var favorites = [self queryFavorites];
   var dict = [[CPDictionary alloc] initWithObjects:[saveQueryName, query] forKeys:[@"name", @"value"]];
   [favorites addObject:dict];
   [[CPUserDefaults standardUserDefaults] setObject:favorites forKey:QUERY_FAVORITES]; 
 }
  [CPApp endSheet:favWindow returnCode:CPOKButton];
}


- (CPArray)queryFavorites
{
  var fav = [[CPUserDefaults standardUserDefaults] objectForKey:QUERY_FAVORITES];
  if(!fav) {
    fav = [CPArray array];
  }
  return fav;
}

- (void)didSelectSavedQuery:(CPMenuItem)sender
{
  var repObj = [sender representedObject];
  var idx = [repObj.split("-") lastObject];
  if (idx) idx = parseInt(idx);
  
  var item = [[self queryFavorites] objectAtIndex:idx];
  [textview setStringValue:[item objectForKey:@"value"]];
}

- (void)editFavoritesAction:(CPMenuItem)sender
{
  if(!editFavWindow) {
    editFavWindow = [[SJEditFavoritesWindowController alloc] init];
    [editFavWindow windowLoadWithCallback:function(favwindow) {
      [CPApp beginSheet: favwindow
         modalForWindow: [[self contentView] window]
          modalDelegate: self
         didEndSelector: null
            contextInfo: null];
    }];
  } else {
    [CPApp beginSheet: [editFavWindow window]
       modalForWindow: [[self contentView] window]
        modalDelegate: self
       didEndSelector: null
          contextInfo: null];
  }
}


- (void)saveHistoryAction:(CPMenuItem)sender
{
  var hist = [self queryHistory];
  if(hist && [hist count] > 0) { 
    var json = JSON.stringify(hist);
    [[SJAPIRequest sharedAPIRequest] saveContentsToDisk:json  callback:function() {
     // What do we do when iframe finished loading?
    }];
  } else {
    alert("There is nothing to save...");
  }
}

- (void)clearGlobalHistory:(CPMenuItem)sender
{
  var alert = [CPAlert new];
  [alert addButtonWithTitle:@"OK"];
  [alert addButtonWithTitle:@"Cancel"];
  [alert setMessageText:@"Are you sure you want to clear the global history list?"];
  [alert setInformativeText:@"This action cannot be undone."];
  [alert setAlertStyle:CPWarningAlertStyle];
  [alert beginSheetModalForWindow:[[self contentView] window]
                    modalDelegate:self 
                   didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
                      contextInfo:nil];
}

- (void)clearGlobalHistoryNow
{
  [[CPUserDefaults standardUserDefaults] setObject:[CPArray array] forKey:QUERY_HISTORY];
}

- (void)alertDidEnd:(CPAlert)sender returnCode:(int)code contextInfo:(id)context
{
  if (code == 1) {
    [self clearGlobalHistoryNow];
  }
}

- (void)didSelectHistoryQuery:(CPMenuItem)sender
{
  var repObj = [sender representedObject];
  var idx = [repObj.split("-") lastObject];
  if (idx) idx = parseInt(idx);
  
  var item = [[self queryHistory] objectAtIndex:idx];
  [textview setStringValue:item];
}


- (void)viewDidAdjust
{
  [splitview setFrame:[[self view] frame]];  
  [topView setFrame:CGRectMake(0,0, CGRectGetWidth([[self view] frame]), CGRectGetHeight([[self view] frame]) / 2)];
  [bottomView setFrame:CGRectMake(0, CGRectGetHeight([topBar frame]), CGRectGetWidth([[self view] frame]), (CGRectGetHeight([[self view] frame]) / 2) - 23.0)];
  [topBar setFrame:CGRectMake(0, 0, [[self view] frame].size.width, CGRectGetHeight([topBar frame]))];

  /* CPTableView */var docview = [bottomScrollview documentView];
  [docview adjustColumnsToFit];
}

- (CPArray)bottomTableHeaderNames
{
  return [self headerNames];
}

@end
