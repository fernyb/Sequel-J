
@import <Foundation/CPObject.j>
@import "CPArray+Categories.j"


@implementation CPTableView (SJTableViewAdditions)

- (void)adjustColumnsToFit
{
  var columns = [self tableColumns];
  var columnWidth = ([self frame].size.width - 15) / [columns count];
  [columns map:function(column) {
    [column setWidth:columnWidth];
  }];
}

- (CPInteger)indexForColumnIdentifier:(CPString)tableColumnIdentifier
{
  var columns = [self tableColumns];
  for(var i=0; i<[columns count]; i++) {
    if([[columns objectAtIndex:i] identifier] == tableColumnIdentifier) {
      return i;
    }
  }
  
  return -1;
}

@end