
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

@end