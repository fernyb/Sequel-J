
@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"
@import "SJConstants.j"
@import "Categories/CPTableView+Categories.j"


@implementation SJRelationsTabController : SJTabBaseController
{
  CPArray relations;
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
      [[self tableView] reloadData];
    }];
  }
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
