@import "Categories/CPDictionary+Categories.j"

var sharedAPIRequest = nil;
var DownloadIFrame = null,
    DownloadSlotNext = null;

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

- (void)sendRequestAddTable:(CPString)table_name query:(CPDictionary)opts callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=add_table&table=" + table_name + "&" + [self _requestCredentialsString] + "&" + [opts toQueryString];
  url += "?" + query;
  
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];  
}

- (void)sendRequestRemoveTable:(CPString)table_name callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=remove_table&table=" + table_name + "&" + [self _requestCredentialsString];
  url += "?" + query;
  
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];
}

- (void)sendRequestTruncateTable:(CPString)table_name callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=truncate_table&table=" + table_name + "&" + [self _requestCredentialsString];
  url += "?" + query;
  
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];
}

- (void)sendRequestDuplicateTable:(CPString)table_name query:(CPDictionary)opts callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=duplicate_table&table=" + table_name + "&" + [self _requestCredentialsString] + "&" + [opts toQueryString];
  url += "?" + query;
  
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];
}

- (void)sendRequestRenameTable:(CPString)table_name query:(CPDictionary)opts callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=rename_table&table=" + table_name + "&" + [self _requestCredentialsString] + "&" + [opts toQueryString];
  url += "?" + query;
  
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];  
}

- (void)sendRequestTableRows:(CPString)table_name query:(CPDictionary)opts callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=rows&table=" + table_name + "&" + [self _requestCredentialsString] + "&" + [opts toQueryString];
  url += "?" + query;
  
  [self _sendRequestToURL:url httpMethod:@"GET" callback:callback];  
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

- (void)sendRequestToUpdateTable:(CPString)table_name options:(CPDictionary)opts callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=update_table&table=" + table_name + "&" + [self _requestCredentialsString] + "&" + [opts toQueryString];
  url += "?" + query;
  
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];
}

- (void)sendUpdateTable:(CPString)table_name query:(CPDictionary)opts callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=update_table_row&table=" + table_name + "&" + [self _requestCredentialsString] + "&" + [opts toQueryString];
  url += "?" + query;
  
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];  
}

- (void)sendRequestToEndpoint:(CPString)aURL callback:(id)aCallback
{
	[self sendRequestToEndpoint:aURL withOptions:nil callback:aCallback];
}

- (void)sendRequestForHeaderNamesForTable:(CPString)aTableName callback:(id)aCallback
{
	var options = [[CPDictionary alloc] initWithObjects:[aTableName] forKeys:[@"table"]];

	[self sendRequestToEndpoint:@"header_names" withOptions:options callback:aCallback];
}

- (void)sendRequestForRowsForTable:(CPString)aTableName callback:(id)aCallback
{
	var options = [[CPDictionary alloc] initWithObjects:[aTableName] forKeys:[@"table"]];

	[self sendRequestToEndpoint:@"rows" withOptions:options callback:aCallback];
}


- (void)sendRequestToEndpoint:(CPString)aURL withOptions:(CPDictionary)options callback:(id)aCallback
{
	var url = SERVER_BASE + @"/api.php?endpoint=" + aURL + @"&" + [self _requestCredentialsString] + "&" + [options toQueryString];
	
	[self _sendRequestToURL:url callback:aCallback];
}

- (void)sendRequestToEndpoint:(CPString)name tableName:(CPString)tableName callback:(func)callback
{
	var url = SERVER_BASE + @"/api.php?endpoint=" + name + @"&table=" + tableName + @"&" + [self _requestCredentialsString];
	[self _sendRequestToURL:url callback:callback];
}

- (void)sendUpdateRequestSchemaTable:(CPString)table_name query:(CPDictionary)opts callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=schema&table=" + table_name + "&" + [self _requestCredentialsString] + "&" + [opts toQueryString];
  url += "?" + query;
   
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];
}

- (void)sendUpdateColumnRequestTable:(CPString)table_name query:(CPDictionary)opts callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=updatecolumn&table=" + table_name + "&" + [self _requestCredentialsString] + "&" + [opts toQueryString];
  url += "?" + query;
   
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];
}

- (void)sendRemoveColumnRequestTable:(CPString)table_name query:(CPDictionary)opts callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=removecolumn&table=" + table_name + "&" + [self _requestCredentialsString] + "&" + [opts toQueryString];
  url += "?" + query;
   
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];
}

- (void)sendAddIndexRequestTable:(CPString)table_name query:(CPDictionary)opts callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=add_index&table=" + table_name + "&" + [self _requestCredentialsString] + "&" + [opts toQueryString];
  url += "?" + query;
   
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];
}

- (void)sendRemoveIndexRequestTable:(CPString)table_name query:(CPDictionary)opts callback:(func)callback
{
  var url = SERVER_BASE + "/api.php";
  var query = "endpoint=remove_index&table=" + table_name + "&" + [self _requestCredentialsString] + "&" + [opts toQueryString];
  url += "?" + query;
   
  [self _sendRequestToURL:url httpMethod:@"POST" callback:callback];
}

- (void)requestTablesForDatabase:(CPString)database_name callback:(func)callback
{
  [[self credentials] setObject:database_name forKey:@"database"];
  var url = SERVER_BASE + "/api.php?endpoint=tables&" + [self _requestCredentialsString];
  [self _sendRequestToURL:url httpMethod:@"GET" callback:callback];
}

- (void)_sendRequestToURL:(CPString)aURL httpMethod:(CPString)method callback:(id)aCallback
{
	var CFRequest = new CFHTTPRequest();
  CFRequest.open(method, aURL, true);
  CFRequest.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  
  CFRequest.oncomplete = function() {
    try {
      var data = [CFRequest.responseText() objectFromJSON];
      aCallback( data );
    } 
    catch (e) {
      console.log(e);
      alert( @"Request failed for URL: " + aURL );
    }
  };
  
  CFRequest.send();
}

- (void)_sendRequestToURL:(CPString)aURL callback:(id)aCallback
{
  [self _sendRequestToURL:aURL httpMethod:@"GET" callback:aCallback];
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


// For Now, the only thing I know to export is the query history...
// Change as needed in the future...
- (void)saveContentsToDisk:(CPString)jsContent callback:(func)callback
{  
  var exportURL = SERVER_BASE + "/api.php?endpoint=export&type=sql_history&json=" + jsContent;

  if (DownloadIFrame == null) {
    DownloadIFrame = document.createElement("iframe");
    DownloadIFrame.style.position = "absolute";
    DownloadIFrame.style.top    = "-100px";
    DownloadIFrame.style.left   = "-100px";
    DownloadIFrame.style.height = "0px";
    DownloadIFrame.style.width  = "0px";
    DownloadIFrame.onload = function() {
      callback();
    };
    document.body.appendChild(DownloadIFrame);
  }
  
  var now = new Date().getTime(),
      downloadSlot = (DownloadSlotNext && DownloadSlotNext > now)  ? DownloadSlotNext : now;
      
  DownloadSlotNext = downloadSlot + 2000;
  
  window.setTimeout(function() {
      if (DownloadIFrame != null) {
        DownloadIFrame.src = exportURL;
      }
  }, downloadSlot - now);
}

@end