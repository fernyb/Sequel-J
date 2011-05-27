/*
 * AppController.j
 * Sequel-J
 *
 * Created by Fernando Barajas on July 26, 2010.
 * Copyright 2010, Fernando Barajas All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "Categories/CPSplitView+Categories.j"
@import "SJLeftView.j"
@import "SJLoginViewController.j"

@import "SJStructureTabController.j"
@import "SJContentTabController.j"
@import "SJRelationsTabController.j"
@import "SJTableInfoTabController.j"
@import "SJQueryTabController.j"

@import "SJToolbarController.j"
@import "SJConstants.j"

@import "SLDatabaseViewController.j"


@implementation AppController : CPObject
{
    @outlet CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    @outlet SLDatabaseViewController dbviewController;

    @outlet SJStructureTabController structureTabController;
    @outlet SJContentTabController contentTabController;
    @outlet SJRelationsTabController relationsTabController;
    @outlet SJTableInfoTabController tableInfoTabController;
    @outlet SJQueryTabController queryTabController;

    SJLeftView theLeftView;
    SJLoginViewController theLoginViewController;
    CPArray viewControllers;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(switchView:) name:SWITCH_CONTENT_RIGHT_VIEW_NOTIFICATION object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:@"kLoginSuccess" object:nil];
	
	var name = [[theWindow contentView] viewWithTag:100];
	[theWindow makeFirstResponder:name];
}


- (void)switchView:(CPNotification)aNotification
{
  var name = [aNotification object];
  [self switchToView:name];
}

- (void)hideAllSubviews
{
  for(var i=0; i<[viewControllers count]; i++) {
    var controller = [viewControllers objectAtIndex:i];
    [controller setHidden:YES];
  }
}

- (void)switchToView:(CPString)name
{
  [self hideAllSubviews];

  for(var i=0; i<[viewControllers count]; i++) {
    var controller = [viewControllers objectAtIndex:i];
    if([controller respondsToSelector:@selector(className)] && [controller performSelector:@selector(className)] == name) { 
     [controller setHidden:NO];
    }
  }
}


- (void)didLogin:(CPNotification)aNotification
{
  [self switchToView:@"SJContentTabController"];
}


- (void)setupToolbar
{
  var toolbarController = [[SJToolbarController alloc] init];
  [theWindow setToolbar:[toolbarController toolbar]];
}


- (void)awakeFromCib
{
  viewControllers = [[CPArray alloc] init];

  [self setupToolbar];
  [self setupLeftView];
  [self setupRightView];

  // Add Controllers

  [structureTabController setContentView:[self contentRightView]];
  [structureTabController setupView];
  [viewControllers addObject:structureTabController];

  [contentTabController setContentView:[self contentRightView]];
  [viewControllers addObject:contentTabController];

  [relationsTabController setContentView:[self contentRightView]];
  [relationsTabController setupView];
  [viewControllers addObject:relationsTabController];

  [tableInfoTabController setContentView:[self contentRightView]];
  [tableInfoTabController setupView];
  [viewControllers addObject:tableInfoTabController];

  [queryTabController setContentView:[self contentRightView]];
  [queryTabController setupView];
  [viewControllers addObject:queryTabController];

  [theWindow orderFront:self];
}


- (CPSplitView)contentSplitView
{
  var subviews = [[theWindow contentView] subviews];
  var splitView = [subviews objectAtIndex:0]; /* CPSplitView */
  return splitView;
}

- (CPView)contentLeftView
{
  var leftView = [[self contentSplitView] viewAtIndex:0];
  return leftView;
}

- (CPView)contentRightView
{
  var rightview = [[self contentSplitView] viewAtIndex:1];
  return rightview;
}

- (void)setupLeftView
{
  theLeftView = [[SJLeftView alloc] initWithSuperView:[self contentLeftView]];   
}

- (void)setupRightView
{  
  var controller = [[SJLoginViewController alloc] initWithView:[self contentRightView]];
  [viewControllers addObject:controller];
}

@end
