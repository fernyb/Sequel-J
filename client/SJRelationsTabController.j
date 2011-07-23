
@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"
@import "SJConstants.j"
@import "Categories/CPTableView+Categories.j"
@import "SJRelationNewWindowController.j"

@implementation SJRelationsTabController : SJTabBaseController
{
  CPArray relations;
  CPButtonBar bottomBar;
  SJRelationNewWindowController newRelWinController;
  CPArray column_names;
  CPArray structure;
}

// View Did Set is only called when the [self view] is set.
- (void)viewDidSet
{
  [super viewDidSet];
  [self addTableStructure];
}

- (void)addTableStructure
{
  var scrollview = [self createTableViewForView:[self view] headerNames:[self headerNames]];

  var rect = [scrollview frame];
  rect.size.height -= 23.0;

  [scrollview setFrame:rect];
  [self addBottomBarWithRect:rect];

  // After we create the TableView we add it to the view as a subview.
  [[self view] addSubview:scrollview];
}

- (CPArray)headerNames
{
  return [@"Name", @"Columns", @"FK Table", @"FK Columns", @"On Update", @"On Delete"];
}

- (void)viewDidAdjust
{
  [[self tableView] adjustColumnsToFit];
}

- (void)addBottomBarWithRect:(CGRect)rect
{
  if(bottomBar) return;
  var originY = rect.size.height;

  bottomBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(0, originY, rect.size.width, 23.0)];    
  [bottomBar setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
  
  [[self view] addSubview:bottomBar];

  var addButton = [CPButtonBar plusButton];
  [addButton setAction:@selector(addRelationAction:)];
  [addButton setTarget:self];
  [addButton setEnabled:YES];
  
  var minusButton = [CPButtonBar minusButton];
  [minusButton setAction:@selector(removeRelationAction:)];
  [minusButton setTarget:self];
  [minusButton setEnabled:YES];

  var refreshBtn = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
  var refreshImage = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"refresh-icon.png"] size:CGSizeMake(14, 15)];
  [refreshBtn setBordered:NO];
  [refreshBtn setTarget:self];
  [refreshBtn setAction:@selector(refreshAction:)];
  [refreshBtn setImage:refreshImage];
  [refreshBtn setImagePosition:CPImageOnly];

  [bottomBar setButtons:[addButton, minusButton, refreshBtn]];
}

- (void)addRelationAction:(CPButton)sender
{
  if (!newRelWinController) {
    newRelWinController = [[SJRelationNewWindowController alloc] initWithParentController:self];
  }
  [newRelWinController willDisplayView];

  [CPApp beginSheet: [newRelWinController window]
     modalForWindow: [[self contentView] window]
      modalDelegate: self
     didEndSelector: null
        contextInfo: null];
}

- (void)removeRelationAction:(CPButton)sender
{
}

- (void)refreshAction:(CPButton)sender
{
  [self retrieveRelations];
}

// Called when the tab is selected and the view will be displayed.
- (void)viewWillAppear
{
  [self retrieveRelations];
}

// Called when the Tab already in display and a different table is selected.
- (void)databaseTableSelected
{
  [self retrieveRelations];
}

- (void)retrieveRelations
{
  if ([self tableName]) 
  {
  	var options = [[CPDictionary alloc] initWithObjects:[[self tableName]] forKeys:[@"table"]];

    [[SJAPIRequest sharedAPIRequest] sendRequestToEndpoint:@"relations" withOptions:options callback:function( js ) 
    {
      relations = js.relations;
      tables = js.tables;
      structure = js.structure;
      [[self tableView] reloadData];
    }];
  }
}

- (CPArray)structure
{
  return structure;
}

- (CPArray)tables
{
  return tables;
}

- (CPInteger)numberOfRowsInTableView:(CPTableView *)aTableView
{
 return [relations count]; 
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)rowIndex
{
  var row = [relations objectAtIndex:rowIndex];

  switch([aTableColumn identifier]) {
    case @"SJTableColumnName" :
     return row.name;
    break;
    case @"SJTableColumnColumns" :
      return row.foreign_key[0];
    break;
    case @"SJTableColumnFK Table" :
      return row.reference_table;
    break;
    case @"SJTableColumnFK Columns" :
      return row.reference_key[0];
    break;
    case @"SJTableColumnOn Update" :
      return row.on_update;
    break;
    case @"SJTableColumnOn Delete" :
      return row.on_delete;
    break;
    default:
     CPLog("TableColumn Identifier: "+ [aTableColumn identifier]);
    break;
  }
  return @"";
}

@end
