@import <Foundation/Foundation.j>


var StructureToolbarItemIdentifier  = @"StructureToolbarItemIdentifier",
    ContentToolbarItemIdentifier    = @"ContentToolbarItemIdentifier",
    RelationsToolbarItemIdentifier  = @"RelationsToolbarItemIdentifier",
    TableInfoToolbarItemIdentifier  = @"TableInfoToolbarItemIdentifier",
    QueryToolbarItemIdentifier      = @"QueryToolbarItemIdentifier",
    SelectDatabaseToolbarItem       = @"SelectDatabaseToolbarItem";


@implementation SJToolbarController : CPObject
{
  CPToolbar toolbar;
  id menuItem;
}

- (id)init
{
  if(self = [super init]) {
    [self setupToolbar];
  
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(showDatabases:) name:@"kShowDatabases" object:nil];
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
   return [CPToolbarFlexibleSpaceItemIdentifier, CPToolbarSpaceItemIdentifier, 
           StructureToolbarItemIdentifier, ContentToolbarItemIdentifier, 
           RelationsToolbarItemIdentifier, TableInfoToolbarItemIdentifier, 
           QueryToolbarItemIdentifier, SelectDatabaseToolbarItem];
}


/* 
  Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar) 
*/
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [SelectDatabaseToolbarItem, CPToolbarSpaceItemIdentifier, StructureToolbarItemIdentifier, ContentToolbarItemIdentifier, RelationsToolbarItemIdentifier,
           TableInfoToolbarItemIdentifier, QueryToolbarItemIdentifier,
          CPToolbarFlexibleSpaceItemIdentifier];
}


- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
    
    switch(anItemIdentifier) {
      case SelectDatabaseToolbarItem :
        [toolbarItem setTag:200];
        [self addSelectDatabaseToolbarItemFor:toolbarItem];
      break;
      
      case StructureToolbarItemIdentifier :
        [self addStructureToolbarItemFor:toolbarItem];
      break;
      
      case ContentToolbarItemIdentifier :
        [self addContentToolbarItemFor:toolbarItem];
      break;
      
      case RelationsToolbarItemIdentifier :
        [self addRalationsToolbarItemFor:toolbarItem];
      break;
      
      case TableInfoToolbarItemIdentifier :
        [self addTableInfoToolbarItemFor:toolbarItem];
      break;
      
      case QueryToolbarItemIdentifier :
        [self addQueryToolbarItemFor:toolbarItem];
      break;  
    }
    
    return toolbarItem;
}

- (void)addSelectDatabaseToolbarItemFor:(CPToolbarItem)toolbarItem
{
  var selectDBButtonWidth = 200;
  var selectDBButtonHeight = 24;
  
	var selectDBButton = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0, 0, selectDBButtonWidth, selectDBButtonHeight)];

	[selectDBButton setTarget:self];
	[selectDBButton setAction:@selector(selectedDatabase:)];
	[selectDBButton setTitle:@"Choose Database..."];
	//[selectDBButton setPullsDown:YES];
  
  var items = [self itemsForPopupButton];
  
  for(var i=0; i < [items count]; i++) {
    var item = [items objectAtIndex:i];
    if([item className] == @"CPString") {
      [selectDBButton addItemWithTitle:item];
    } else if([item className] == @"CPMenuItem") {
      [[selectDBButton menu] addItem:item];
    }
  }
  
  [toolbarItem setView:selectDBButton];
	[toolbarItem setLabel:@"Select Database"];
	
	[toolbarItem setMinSize:CGSizeMake(selectDBButtonWidth, selectDBButtonHeight)];
  [toolbarItem setMaxSize:CGSizeMake(selectDBButtonWidth, selectDBButtonHeight)]; 
}

- (CPArray)itemsForPopupButton
{
  var items = [[CPArray alloc] init];
  [items addObject:@"Add Database"];
  [items addObject:@"Refresh Databases"];
  [items addObject:[CPMenuItem separatorItem]];
  [items addObject:@"information_schema"];
  [items addObject:[CPMenuItem separatorItem]];
  
  return items;
}

- (void)showDatabases:(CPNotification)aNotification
{
  CPLog( @"ShowDatabases" )
  CPLog( [aNotification object] );
}

- (void)addContentToolbarItemFor:(CPToolbarItem)toolbarItem
{
  [self addToolbarItemNamed:@"toolbar-switch-to-browse.tiff" 
            withToolbarItem:toolbarItem  
                  withLabel:@"Content" 
                andSelector:@selector(showContentView:)];
}

- (void)addRalationsToolbarItemFor:(CPToolbarItem)toolbarItem
{
  [self addToolbarItemNamed:@"toolbar-switch-to-table-relations.png" 
            withToolbarItem:toolbarItem
                  withLabel:@"Relations" 
                andSelector:@selector(showRelationsView:)];  
}

- (void)addTableInfoToolbarItemFor:(CPToolbarItem)toolbarItem
{
  [self addToolbarItemNamed:@"toolbar-switch-to-table-info.png" 
            withToolbarItem:toolbarItem
                  withLabel:@"Table Info" 
                andSelector:@selector(showTableInfoView:)];  
}

- (void)addQueryToolbarItemFor:(CPToolbarItem)toolbarItem
{
  [self addToolbarItemNamed:@"toolbar-switch-to-sql.tiff" 
            withToolbarItem:toolbarItem
                  withLabel:@"Query" 
                andSelector:@selector(showQueryView:)];  
}

- (void)addStructureToolbarItemFor:(CPToolbarItem)toolbarItem
{
  [self addToolbarItemNamed:@"toolbar-switch-to-structure.png" withToolbarItem:toolbarItem  withLabel:@"Structure" andSelector:@selector(showStructureView:)];
}


- (void)addToolbarItemNamed:(CPString)aToolbarImageName 
            withToolbarItem:(CPToolbarItem)toolbarItem 
                  withLabel:(CPString)aLabel 
                andSelector:(SEL)aSelector
{
  var mainBundle = [CPBundle mainBundle];
  var parts = aToolbarImageName.split(".", 2);
  var name = parts[0];
  var ext = parts[1];
  var imageName = [CPString stringWithFormat:@"%@.%@", name, ext];
  var imageNameHighlight = [CPString stringWithFormat:@"%@-pushed.%@", name, ext];
  
  var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:imageName] size:CPSizeMake(32, 32)];
  var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:imageNameHighlight] size:CPSizeMake(32, 32)];

  [toolbarItem setImage:image];
  [toolbarItem setAlternateImage:highlighted];

  [toolbarItem setTarget:self];
  [toolbarItem setAction:aSelector];
  [toolbarItem setLabel:aLabel];

  [toolbarItem setMinSize:CGSizeMake(32, 32)];
  [toolbarItem setMaxSize:CGSizeMake(32, 32)];  
}


- (void)showStructureView:(id)sender
{
  alert(@"Show The Structure View");
}

- (void)showContentView:(id)sender
{
  alert(@"Show the Content View");
}

- (void)showRelationsView:(id)sender
{
  alert(@"Show Relations View");
}

- (void)showTableInfoView:(id)sender
{
  alert(@"Show Table Info View");
}

- (void)showQueryView:(id)sender
{
  alert(@"Show Query View");
}

- (void)selectedDatabase:(id)sender
{
  var selectedTitle = [[sender selectedItem] title];
  if(selectedTitle == @"Refresh Databases") {
    [[CPNotificationCenter defaultCenter] postNotificationName:@"kShowDatabaseTables" object:nil];
  }
}

@end