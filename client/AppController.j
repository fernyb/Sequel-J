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
@import "SLDatabaseViewController.j"
@import "SJToolbarController.j"


@implementation AppController : CPObject
{
    @outlet CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    @outlet SLDatabaseViewController dbviewController;

    SJLeftView theLeftView;
    SJLoginViewController theLoginViewController;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:@"kLoginSuccess" object:nil];
}

- (void)didLogin:(CPNotification)aNotification
{
    if(dbviewController) {
      [theLoginViewController setHidden:YES];
      [dbviewController setHidden:NO];
    }
}

- (void)setupToolbar
{
  var toolbarController = [[SJToolbarController alloc] init];
  [theWindow setToolbar:[toolbarController toolbar]];
}


- (void)awakeFromCib
{
  [self setupToolbar];
  [self setupLeftView];
  [self setupRightView];
  
  var rightView = [[self contentSplitView] viewAtIndex:1];
  [dbviewController setContentView:rightView];
  [dbviewController setupView];
     
  [theWindow orderFront:self];
}

- (CPSplitView)contentSplitView
{
  var subviews = [[theWindow contentView] subviews];
  var splitView = [subviews objectAtIndex:0]; /* CPSplitView */
  return splitView;
}

- (void)setupLeftView
{
 var leftView = [[self contentSplitView] viewAtIndex:0];
 
 // Setup the Left View
  theLeftView = [[SJLeftView alloc] initWithSuperView:leftView];   
}

- (void)setupRightView
{  
  var rightContentView = [[self contentSplitView] viewAtIndex:1];
  theLoginViewController = [[SJLoginViewController alloc] initWithView:rightContentView];
}

@end
