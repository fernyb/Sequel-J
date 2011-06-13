
@import <Foundation/CPObject.j>

@implementation CPDictionary (SJDictionaryAdditions)

- (CPString)toQueryString
{
  var keys = [self allKeys];
  var params = [CPArray array];
  
  for(var i=0; i<[keys count]; i++) {
    var k = [keys objectAtIndex:i];
    var v = [self objectForKey:k];
    [params addObject:k + "=" + v];
  }
  
  return [params componentsJoinedByString:"&"];
}

@end