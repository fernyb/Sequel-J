@import <Foundation/Foundation.j>

var _sharedInstance = nil;

@implementation SJDataManager : CPObject
{
  CPDictionary _credentials;
}

+ (SJDataManager)sharedInstance
{
  if(_sharedInstance) {
    return _sharedInstance;
  }
  _sharedInstance = [[[self class] alloc] init];
  return _sharedInstance;
}

- (void)setCredentials:(CPDictionary)aDict
{
  _credentials = aDict;
}

- (CPDictionary)credentials
{
  return _credentials;
}

@end