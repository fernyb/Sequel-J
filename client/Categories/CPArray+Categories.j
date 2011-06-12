
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

@end
