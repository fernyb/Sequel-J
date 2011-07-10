@import <Foundation/CPObject.j>
@import "CPArray+Categories.j"


@implementation CPDictionary (SJDictionaryAdditions)

- (CPString)toQueryString
{
  var keys = [self allKeys];
  var params = [CPArray array];
  
  for(var i=0; i<[keys count]; i++) {
    var k = [keys objectAtIndex:i];
    var v = [self objectForKey:k];
    
    if ([v respondsToSelector:@selector(toQueryStringWithPrefix:)]) {
      [params addObject:[v toQueryStringWithPrefix:k]];
    } else if (typeof(v) == "string" || typeof(v) == "number") {
      [params addObject:k + "=" + v];
    }
  }
  
  return [params componentsJoinedByString:"&"];
}


- (BOOL)hasKey:(CPString)aKey
{
  var allkeys = [self allKeys];
  for(var i=0; i<[allkeys count]; i++) {
    var key = [allkeys objectAtIndex:i];
    if(key == aKey) {
      return YES;
    }
  }
  return NO;
}

@end