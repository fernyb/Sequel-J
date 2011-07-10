
@import <Foundation/CPObject.j>
@import "SJConstants.j"

@implementation SJTabBaseController : CPObject
{
  CPView contentview;
  CPURLConnection _httpConnection;
  CPView _view;
  CPArray _responseData;
  CPTableView _tableview;
  CPString _tablename;
}

- (id)init
{
  self = [super init];
  return self;
}

- (id)initWithView:(CPView)aView
{
  if (self = [super init]) {
   //[self initializeViewsWithRect:[aView frame]];
  }
  return self;
}


- (void)initializeViewsWithRect:(CGRect)rect
{
 if(!_view) {
  [self setResponseData:[[CPArray alloc] init]];
  
  var acontentview = [[CPView alloc] initWithFrame:rect];
  [self setContentView:acontentview];
  
  var aview = [[CPView alloc] initWithFrame:rect];
  [self setView:aview];
  [self setHidden:YES];
 }
}

- (void)awakeFromCib
{
  [self initializeViewsWithRect:CGRectMake(0, 0, 0, 0)];
}


- (void)setResponseData:(CPArray)anArray
{
   _responseData = anArray;
}

- (CPArray)responseData
{
  return _responseData;
}


- (void)setHidden:(BOOL)hidden
{
  if([self view] && [[self view] isHidden] != hidden) {
    if (hidden == NO) {
      [self viewWillAppear];
    } else if (hidden == YES) {
      [self viewWillDisappear];
    }
    [[self view] setHidden:hidden];
    if (hidden == NO) {
      [self viewDidAppear];
    } else if (hidden == YES) {
      [self viewDidDisappear];
    }
  }
}

- (BOOL)isHidden
{
  return [[self view] isHidden];
}


- (void)viewWillAppear
{
  // subclass should implement this method
}

- (void)viewDidAppear
{
  // subclass should implement this method
}

- (void)viewWillDisappear
{
  // subclass should implement this method
}

- (void)viewDidDisappear
{
  // subclass should implement this method
}


- (void)contentViewWillSet
{
 // gets called before the ContentView gets set
}

- (void)contentViewDidSet
{
  if ([self view]) {
    var superSplitview;

    if (superSplitview = [[self contentView] superview]) {
     var superSplitLeftView = [[superSplitview subviews] objectAtIndex:0];
      
     var rect = [[self contentView] bounds];

     [[self view] setFrame:rect];

     [[self view] setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
     [self viewDidAdjust];

     [[self contentView] addSubview:[self view]];
    }
  }
}

- (void)viewDidAdjust
{
 // Called when the view was adjusted because the ContentView was set.
}

- (void)viewWillSet
{
 // Subclasses should implement this if needed
}

- (void)viewDidSet
{
}

- (void)setView:(CPView)aView
{
  [self viewWillSet];
  _view = aView;
  [[self view] setHidden:YES];
  [self viewDidSet];
}

- (CPView)view
{
  return _view;
}

- (void)setContentView:(CPView)aView
{
  [self contentViewWillSet];
  contentview = aView;
  [self contentViewDidSet];
}


- (CPView)contentView
{
  return contentview
}

- (void)requestDidFinish:(id)js
{
  CPLog(@"requestDidFinish, should be implemented");
}

- (void)requestDidFail:(id)js
{
  CPLog(@"requestDidFail, should be implement");
}


- (void)connectionWithRequest:(CPURLRequest)request
{
  _httpConnection = [CPURLConnection connectionWithRequest:[request toRequest] delegate:self];
}


- (void)connectionDidFinishLoading:(CPURLConnection)connection
{
  var json = JSON.parse([_responseData componentsJoinedByString:@""]);
  response = nil;
  [_responseData removeAllObjects];

  if(json['error'] == '') {
    [self requestDidFinish:json];
  } else {
    [self requestDidFail:json];
  }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
  //This method is called when a connection receives a response. in a
  //multi-part request, this method will (eventually) be called multiple times,
  //once for each part in the response.
  
  [_responseData addObject:data];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    //This method is called if the request fails for any reason.
    alert("Connection Failed: " + error);
}

- (void)clearConnection:(CPURLConnection)aConnection
{
    //we no longer need to hold on to a reference to this connection
    if (aConnection == _httpConnection)
        _httpConnection = nil;
}

// Adding tables should be easier

- (void)setTableView:(CPTableView)aTableView
{
  _tableview = aTableView;
}

- (CPTableView)tableView
{
  return _tableview;
}


- (CPScrollView)createTableViewForView:(CPView)cview headerNames:(CPArray)headerNames
{
	return [self createTableViewForView:cview headerFields:headerNames];
}

- (CPScrollView)createTableViewForView:(CPView)cview headerFields:(CPArray)headerFields
{
   // create a CPScrollView that will contain the CPTableView
  var scrollView = [[CPScrollView alloc] initWithFrame:[cview bounds]];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setAutohidesScrollers:YES];

  // create the CPTableView
  var tableView = [[CPTableView alloc] initWithFrame:[cview bounds]];
  [tableView setDataSource:self];
  [tableView setUsesAlternatingRowBackgroundColors:YES];
  [self setTableView:tableView];

  var widthOfHeader = ([cview frame].size.width - 30) / [headerFields count];

  for(var i=0; i<[headerFields count]; i++) {
    var columnName = typeof( [headerFields objectAtIndex:i].Field ) == @"string" ?  [headerFields objectAtIndex:i].Field : [headerFields objectAtIndex:i];
    var columnType = typeof( [headerFields objectAtIndex:i].Type ) == @"string" ?  [headerFields objectAtIndex:i].Type : '';

    var sortDescriptor = [CPSortDescriptor sortDescriptorWithKey:columnName ascending:YES];
    var column = [[CPTableColumn alloc] initWithIdentifier:[CPString stringWithFormat:@"SJTableColumn%@", columnName]];
    var dataView = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];  
    [dataView setLineBreakMode:CPLineBreakByTruncatingTail];
    
    //calculate the column widths based off data type
    if( columnType.indexOf('int') >=0 )
    	widthOfHeader = 45;
    
    else if( columnType.indexOf('datetime') >= 0 )
    	widthOfHeader = 130;
    
    else if( columnType.indexOf('varchar') >= 0 || columnType.indexOf('text') >= 0 )
    	widthOfHeader = 205;
    
    [[column headerView] setStringValue:columnName];
    [column setDataView: dataView];
    [column setWidth:widthOfHeader];
    [column setSortDescriptorPrototype:sortDescriptor];
    [tableView addTableColumn:column];
  }
  
  [scrollView setDocumentView:tableView];
  
  return scrollView;
}


- (void)setTableName:(CPString)aname
{
  _tablename = aname;
}

- (CPString)tableName
{
  return _tablename;
}

- (CPInteger)numberOfRowsInTableView:(CPTableView *)aTableView
{
  // subclasses should overide this method
  return 0;
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)rowIndex
{
  // Subclasses should overide this method
  return "Column:"+ [aTableColumn identifier] +", Row Index: "+ rowIndex;
}



- (void)databaseTableSelected
{
  // subclass should implement this method
}

@end