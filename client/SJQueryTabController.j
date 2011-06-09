
@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"
@import "Categories/CPTableView+Categories.j"
@import "LPMultiLineTextField.j"


@implementation SJQueryTabController : SJTabBaseController
{
  CPSplitView splitview;
  CPView topView;
  CPView bottomView;
  CPScrollView bottomScrollview;
  CPView topBar;
}

- (void)viewDidSet
{
  [[self view] setBackgroundColor:[CPColor colorWithHexString:"eeeeee"]];
  
  splitview = [[CPSplitView alloc] initWithFrame:[[self view] frame]];
  [splitview setVertical:NO];
  [splitview setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [splitview setIsPaneSplitter:NO];
  
  // Create the top view
  topView = [[CPView alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth([[self view] frame]), CGRectGetHeight([[self view] frame]) / 2)];
  [topView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [topView setBackgroundColor:[CPColor clearColor]];
  
  // Add the Query TextView
  var textview = [[LPMultiLineTextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([topView frame]), CGRectGetHeight([topView frame]))];
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
  var topBarHeight = 28.0;
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
  var runCurrentBtn = [[CPButton alloc] initWithFrame:CGRectMake(CGRectGetWidth([bar frame]) - 170, 1, 100, 23)];
  [runCurrentBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
  [runCurrentBtn setTitle:@"  Run Current "];
  [runCurrentBtn sizeToFit];
  [bar addSubview:runCurrentBtn];  
  
  var runAllBtn = [[CPButton alloc] initWithFrame:CGRectMake([runCurrentBtn frame].origin.x + CGRectGetWidth([runCurrentBtn frame]) + 10, 1, 75, 23)];
  [runAllBtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxYMargin];
  [runAllBtn setTitle:@" Run All "];
  [runAllBtn sizeToFit];
  [bar addSubview:runAllBtn];


  var queryFavBtn = [[CPButton alloc] initWithFrame:CGRectMake(4, 1, 75, 23)];
  [queryFavBtn setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
  [queryFavBtn setTitle:@"Query Favorites"];
  [queryFavBtn sizeToFit];
  [bar addSubview:queryFavBtn];

  var queryHisBtn = [[CPButton alloc] initWithFrame:CGRectMake([queryFavBtn frame].origin.x + CGRectGetWidth([queryFavBtn frame]) + 10, 1, 75, 23)];
  [queryHisBtn setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
  [queryHisBtn setTitle:@"Query History"];
  [queryHisBtn sizeToFit];
  [bar addSubview:queryHisBtn];  
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
  return [@"Name..."];
}

@end
