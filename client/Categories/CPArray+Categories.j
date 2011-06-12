
@import <Foundation/CPObject.j>

@implementation CPArray (SJArrayAdditions)

- (void)map:(Function)func
{
  for(var i=0; i<[self count]; i++) {
    func([self objectAtIndex:i]);
  }
}

- (void)each:(Function)func
{
  for(var i=0; i<[self count]; i++) {
    func([self objectAtIndex:i]);
  }
}

- (CPArray)compact
{
  var results = [CPArray array];
  [self each:function (item) {
    if (item && item != null && item != nil && item != 'undefined') {
      item = item.replace(/^\s+|\s+$/g, '');
      if (item != '') {
        [results addObject:item];
      }
    }
  }];
  return results;
}

@end
