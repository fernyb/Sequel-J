@import "Categories/CPDictionary+Categories.j"

var sharedAPIRequest = nil;

@implementation SJAPIRequest : CPObject
{
	CPDictionary	credentials @accessors;
}

+ (id)sharedAPIRequest
{
	if( !sharedAPIRequest )
		sharedAPIRequest = [[SJAPIRequest alloc] init];
	
	return sharedAPIRequest;
}

- (id)init
{
	self = [super init];
	
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_databaseWasSelected:) name:SHOW_DATABASE_TABLES_NOTIFICATION object:nil];
	
	return self;
}

- (void)sendRequestToConnectWithOptions:(CPDictionary)options callback:(id)aCallback
{
  var url = SERVER_BASE + "/api.php?endpoint=connect" + "&" + [options toQueryString];  
  [self _sendRequestToURL:url callback:aCallback];
}

- (void)sendRequestToDatabasesWithOptions:(CPDictionary)options callback:(id)aCallback
{
	var url = SERVER_BASE + "/api.php?endpoint=databases&" + [self _requestCredentialsString];
	
	[self _sendRequestToURL:url callback:aCallback];
}

- (void)sendRequestToTablesWithOptions:(CPDictionary)options callback:(id)aCallback
{
	var url = SERVER_BASE + "/api.php?endpoint=tables&" + [self _requestCredentialsString];
	
	[self _sendRequestToURL:url callback:aCallback];
}

- (void)sendRequestToQueryWithOptions:(CPDictionary)options callback:(id)aCallback
{
  var url = SERVER_BASE + "/api.php?endpoint=query&" + [self _requestCredentialsString] + "&" + [options toQueryString];
	[self _sendRequestToURL:url callback:aCallback];
}

- (void)sendRequestToEndpoint:(CPString)aURL callback:(id)aCallback
{
	[self sendRequestToEndpoint:aURL withOptions:nil callback:aCallback];
}

- (void)sendRequestToEndpoint:(CPString)aURL withOptions:(CPDictionary)options callback:(id)aCallback
{
	var url = SERVER_BASE + @"/api.php?endpoint=" + aURL + @"&" + [self _requestCredentialsString] + "&" + [options toQueryString];
	
	[self _sendRequestToURL:url callback:aCallback];
}

- (void)_sendRequestToURL:(CPString)aURL callback:(id)aCallback
{
	var CFRequest = new CFHTTPRequest();

	CFRequest.open("GET", aURL, true)
    CFRequest.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    
    CFRequest.oncomplete = function() {
    	
    	try
    	{
    	  var data = [CFRequest.responseText() objectFromJSON];
		  aCallback( data );
		}
		catch (e)
		{
		 console.log(e);
		  alert( @"Request failed for URL: " + aURL );
		}
    }
    
    CFRequest.send();
}

- (CPString)_requestCredentialsString
{
	var params = [];
  	var allKeys = [credentials allKeys];
  	for(var i=0; i < [allKeys count]; i++) {
  	  	var currentKey = [allKeys objectAtIndex:i];
  	  	params.push( [CPString stringWithFormat:@"%@=%@", currentKey, [credentials objectForKey:currentKey]] );
  	}
  	params = params.join("&");
  	
  	return params;
}

- (void)_databaseWasSelected:(CPNotification)aNotification
{
	if( ![aNotification object] )
		return;

	[[self credentials] setValue:[aNotification object] forKey:@"database"];
}

@end