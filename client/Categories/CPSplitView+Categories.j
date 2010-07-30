@import <Foundation/Foundation.j>

@implementation CPSplitView (SJViews)

- (CPView)viewAtIndex:(CPInteger)idx
{
  var leftview = [[self subviews] objectAtIndex:idx];
  return leftview;
}

@end