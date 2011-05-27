
@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"

@implementation SJContentTabController : SJTabBaseController
{
  CPScrollView scrollview;
}


- (void)viewWillAppear
{
  if (!scrollview) {
    scrollview = [self createTableViewForView:[self view] headerNames:[self headerNames]];
    [[self view] addSubview:scrollview];
  }
}


- (CPArray)headerNames
{
  return [@"id", @"user_id", @"name", @"description", @"latitude", @"longitude", @"created_at", @"updated_at"];
}

- (CPInteger)numberOfRowsInTableView:(CPTableView)aTableView
{
  return 1;
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)rowIndex
{
  return "Row: "+ rowIndex;
}

- (BOOL)tableView:(CPTableView)aTableView shouldSelectRow:(int)rowIndex
{
 return YES;
}


@end
