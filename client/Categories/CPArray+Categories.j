
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

@end
