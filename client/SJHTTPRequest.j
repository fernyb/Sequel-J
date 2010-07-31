@import <Foundation/Foundation.j>

@implementation SJHTTPRequest : CPObject
{
  CPDictionary _params;
  CPString _url;
  CPString _httpMethod;
}

- (id)init
{
  if(self = [super init]) {
    _params = [[CPDictionary alloc] init];
    _httpMethod = @"GET";
  }
  return self;
}

- (void)setHTTPMethod:(CPString)aMethod
{
  _httpMethod = aMethod;
}

+ (SJHTTPRequest)requestWithURL:(CPString)aURL
{
 var anInstance = [[[self class] alloc] init];
 [anInstance setURL:aURL];
 return anInstance;
}

- (void)setURL:(CPString)aURL
{
  _url = aURL;
}

- (void)setObject:(CPString)aString forKey:(CPString)aKey
{
  [_params setObject:aString forKey:aKey];
}

- (CPDictionary)params
{
  return _params;
}

- (void)setParams:(CPDictionary)aDict
{
  _params = aDict;
}

- (id)toRequest
{
  var params = [];
  var allKeys = [_params allKeys];
  for(var i=0; i < [allKeys count]; i++) {
    var currentKey = [allKeys objectAtIndex:i];
    params.push( [CPString stringWithFormat:@"%@=%@", currentKey, [_params objectForKey:currentKey]] );
  }
  params = params.join("&");
  
  var path = [CPString stringWithFormat:@"%@?%@", _url, params];
  
  var request = [CPURLRequest requestWithURL:path];
  [request setHTTPMethod:_httpMethod];
  
  return request;
}

@end