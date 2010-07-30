@import <Foundation/Foundation.j>


var StructureToolbarItemIdentifier  = @"StructureToolbarItemIdentifier",
    ContentToolbarItemIdentifier    = @"ContentToolbarItemIdentifier",
    RelationsToolbarItemIdentifier  = @"RelationsToolbarItemIdentifier",
    TableInfoToolbarItemIdentifier  = @"TableInfoToolbarItemIdentifier",
    QueryInfoToolbarItemIdentifier  = @"QueryInfoToolbarItemIdentifier";


@implementation SJToolbarController : CPObject
{
  CPToolbar toolbar;
}

- (id)init
{
  if(self = [super init]) {
    [self setupToolbar];
  }
  return self;
}

- (CPToolbar)toolbar
{
  return toolbar;
}

- (void)setupToolbar
{
  var toolbar = [[CPToolbar alloc] initWithIdentifier:@"SJToolbar"];
  [toolbar setVisible:YES];
  [toolbar setDelegate:self];
}


/*
  Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
*/
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [CPToolbarFlexibleSpaceItemIdentifier, StructureToolbarItemIdentifier];
}


/* 
  Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar) 
*/
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [StructureToolbarItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier];
}


- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
    
    switch(anItemIdentifier) {
      case StructureToolbarItemIdentifier :
        [self addStructureToolbarItemFor:toolbarItem];
      break;
      
      case ContentToolbarItemIdentifier :
      break;
      
      case RelationsToolbarItemIdentifier :
      break;
      
      case TableInfoToolbarItemIdentifier :
      break;
      
      case QueryInfoToolbarItemIdentifier :
      break;  
    }
    
    return toolbarItem;
}


- (void)addStructureToolbarItemFor:(CPToolbarItem)toolbarItem
{
  var mainBundle = [CPBundle mainBundle];
  var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"toolbar-switch-to-structure.png"] size:CPSizeMake(32, 32)];
  var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:@"toolbar-switch-to-structure-pushed.png"] size:CPSizeMake(32, 32)];

  [toolbarItem setImage:image];
  [toolbarItem setAlternateImage:highlighted];

  [toolbarItem setTarget:self];
  [toolbarItem setAction:@selector(showStructureView:)];
  [toolbarItem setLabel:"Structure"];

  [toolbarItem setMinSize:CGSizeMake(32, 32)];
  [toolbarItem setMaxSize:CGSizeMake(32, 32)];
}


- (void)showStructureView:(id)sender
{
  // TODO: Show the Structure View
  alert(@"Show The Structure View");
}

@end