
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

- (CPArray)collect:(Function)func
{
  var items = [CPArray array]; 
  for(var i=0; i<[self count]; i++) {
    [items addObject:func([self objectAtIndex:i])];
  }
  return items;
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

- (void)moveIndexes:(CPIndexSet)indexes toIndex:(int)insertIndex beforeExisting:(BOOL)beforeExisting
{
    var aboveCount = 0,
        object,
        removeIndex;
	
	var index = [indexes lastIndex];
	
    while (index != CPNotFound)
	{
		if (index >= insertIndex)
		{

			removeIndex = index + aboveCount;
			
			aboveCount ++;
		}
		else
		{
			removeIndex = index;
			
			if( beforeExisting )
				insertIndex --;
			else
				insertIndex ++;
		}

		object = [self objectAtIndex:removeIndex];
		[self removeObjectAtIndex:removeIndex];
		[self insertObject:object atIndex:insertIndex];
		
		index = [indexes indexLessThanIndex:index];
	}
}

- (CPArray)copyArrayContents
{
  var newArray = [CPArray array];
  for(var i=0; i<[self count]; i++) {
    var obj = [[self objectAtIndex:i] copy];
    [newArray addObject:obj];
  }
  return newArray;
}

- (CPString)toQueryStringWithPrefix:(CPString)prex
{
  var query = [CPArray array];
  for(var i=0; i<[self count]; i++) {
    var kv = [self objectAtIndex:i];
    var name = [kv objectForKey:@"name"];
    var value = [kv objectForKey:@"value"];
    var s = prex + "[]["+ name +"]=" + value;
    [query addObject:s];
  }
  
  return [query componentsJoinedByString:@"&"];
}

@end
