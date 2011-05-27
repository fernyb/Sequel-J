@import <Foundation/Foundation.j>
@import "SJDataManager.j"
@import "SJHTTPRequest.j"
@import "SJConstants.j"


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
  CPArray _databases;
  CPURLConnection httpConnection;
  CPArray responseData;
}


- (id)init
{
  if(self = [super init]) {
    _databases = [[CPArray alloc] init];
    responseData = [[CPArray alloc] init];
    [self setupToolbar];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(showDatabases:) name:SHOW_DATABASES_NOTIFICATION object:nil];
  }
  return self;
}

- (CPToolbar)toolbar
{
  return toolbar;
}

- (void)setupToolbar
{
  toolbar = [[CPToolbar alloc] initWithIdentifier:@"SJToolbar"];
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
	
	// Load the Items for the Popup Button
  [self loadItemsForPopupButton:selectDBButton];
  
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
  
  var dbs = [self availableDatabases];
  for(var i=0; i < [dbs count]; i++) {
    [items addObject:[dbs objectAtIndex:i]];
  }
  
  return items;
}

- (CPArray)availableDatabases
{
  return _databases;
}


- (void)loadItemsForPopupButton:(CPPopupButton)selectDBButton
{
  var items = [self itemsForPopupButton];
  
  for(var i=0; i < [items count]; i++) {
    var item = [items objectAtIndex:i];
    if([item className] == @"CPString") {
      [selectDBButton addItemWithTitle:item];
    } else if([item className] == @"CPMenuItem") {
      [[selectDBButton menu] addItem:item];
    }
  }
}


- (void)showDatabases:(CPNotification)aNotification
{
  CPLog(@"Show Databases");

  var httpRequest = [SJHTTPRequest requestWithURL:SERVER_BASE + "/databases"];
  [httpRequest setParams: [[SJDataManager sharedInstance] credentials] ];

  httpConnection = [CPURLConnection connectionWithRequest:[httpRequest toRequest] delegate:self];
}



- (void)handleBadResponse:(id)js
{
  alert(js.error);
}


- (void)handleGoodResponse:(id)js
{
  _databases = js.databases;

  var popupButton = [[self itemForIdentifier:SelectDatabaseToolbarItem] view];
  [popupButton removeAllItems];
  [self loadItemsForPopupButton:popupButton];
}



- (id)itemForIdentifier:(CPString)anIdentifier
{
  var items = [toolbar items];
  for(var i=0; i < [items count]; i++) {
    var item = [items objectAtIndex:i];
    if([item itemIdentifier] == anIdentifier) {
      return item;
    }
  }
  return nil;  
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

- (void)showViewName:(CPString)name
{
 [[CPNotificationCenter defaultCenter] postNotificationName:SWITCH_CONTENT_RIGHT_VIEW_NOTIFICATION object:name];
}

- (void)showStructureView:(id)sender
{
 [self showViewName:@"SJStructureTabController"];
}                                                

- (void)showContentView:(id)sender
{
 [self showViewName:@"SJContentTabController"];
}

- (void)showRelationsView:(id)sender
{
  [self showViewName:@"SJRelationsTabController"];
}

- (void)showTableInfoView:(id)sender
{
  [self showViewName:@"SJTableInfoTabController"];
}

- (void)showQueryView:(id)sender
{
  [self showViewName:@"SJQueryTabController"];
}

- (void)selectedDatabase:(id)sender
{
  var selectedTitle = [[sender selectedItem] title];
  if(selectedTitle == @"Refresh Databases") {
    [[CPNotificationCenter defaultCenter] postNotificationName:SHOW_DATABASES_NOTIFICATION object:nil];
  } else {
    [[CPNotificationCenter defaultCenter] postNotificationName:SHOW_DATABASE_TABLES_NOTIFICATION object:selectedTitle];
  }
}



/*
*
* CPURLConnection Methods
*
*/
- (void)connectionDidFinishLoading:(CPURLConnection)connection
{
  var json = JSON.parse([responseData componentsJoinedByString:@""]);
  response = nil;
  [responseData removeAllObjects];
    
  if(json['error'] != "") {
    [self handleBadResponse:json];
  } else {
    [self handleGoodResponse:json];
  }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
  [responseData addObject:data];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
  //This method is called if the request fails for any reason.
  alert("Connection Failed: " + error);
}

- (void)clearConnection:(CPURLConnection)aConnection
{
    //we no longer need to hold on to a reference to this connection
    if (aConnection == httpConnection)
        httpConnection = nil;
}



@end