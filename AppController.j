/*
 * AppController.j
 * Sequel-J
 *
 * Created by Fernando Barajas on July 26, 2010.
 * Copyright 2010, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "SJLeftView.j"


@implementation AppController : CPObject
{
    @outlet CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    SJLeftView theLeftView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
}

- (void)setupToolbar
{
 var toolbar = [[CPToolbar alloc] initWithIdentifier:@"SJToolbar"];
  [toolbar setVisible:YES];
  [theWindow setToolbar:toolbar];
}

- (void)awakeFromCib
{
  [self setupToolbar];
  [self setupLeftView];
  [theWindow orderFront:self];
}

- (void)setupLeftView
{
 var subviews = [[theWindow contentView] subviews];
 var splitView = [subviews objectAtIndex:0]; /* CPSplitView */
 var leftView = [[splitView subviews] objectAtIndex:0];
 
 // Setup the Left View
  theLeftView = [[SJLeftView alloc] initWithSuperView:leftView];   
}


@end
