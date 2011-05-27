
@import <Foundation/CPObject.j>
@import "SJConstants.j"

@implementation SJTabBaseController : CPObject
{
  CPView contentview;
  CPURLConnection _httpConnection;
  CPView _view;
  CPArray _responseData;
  CPTableView _tableview;
  BOOL _didAddSubview;
}

- (id)init
{
  self = [super init];
  // This doesn't work and I don't know why?
  // [self initializeViewsWithRect:CGRectMake(0, 0, 100, 100)];
  return self;
}

- (id)initWithView:(CPView)aView
{
  if (self = [super init]) {
   [self setContentView:aView];
  }
  return self;
}


- (void)initializeViewsWithRect:(CGRect)rect
{
 if(!_view) {
  _didAddSubview = NO;
  [self setResponseData:[[CPArray alloc] init]];

  var aview = [[CPView alloc] initWithFrame:rect];
  [self setView:aview];

  var acontentview = [[CPView alloc] initWithFrame:[aview frame]];
  [self setContentView:acontentview];

  [self setupView];
  [self setHidden:YES];
 }
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


- (void)setupView
{
  if (_didAddSubview == NO && [self view]) {
    var superSplitview;

    if (superSplitview = [[self contentView] superview]) {
     var superSplitLeftView = [[superSplitview subviews] objectAtIndex:0];
      
     var rect = [[self contentView] frame];
      rect.origin.x -= [superSplitLeftView frame].size.width + 10;

     [[self contentView] addSubview:[self view]];

     [[self view] setFrame:rect];
     [[self view] setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
     _didAddSubview = YES;
    }
  }
}

- (void)setView:(CPView)aView
{
  _view = aView;
}

- (CPView)view
{
  return _view;
}

- (void)setContentView:(CPView)aView
{
  [self initializeViewsWithRect:[aView frame]];
  contentview = aView;
  _didAddSubview = NO;
  [self setupView];
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
  var json = JSON.parse([responseData componentsJoinedByString:@""]);
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

- (CPScrollView)createTableViewForView:(CPView)cview headerNames:(CPArray)headerNames
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

  var widthOfHeader = ([cview frame].size.width - 15) / [headerNames count];

  for(var i=0; i<[headerNames count]; i++) {
    var columnName = [headerNames objectAtIndex:i];
    var column = [[CPTableColumn alloc] initWithIdentifier:[CPString stringWithFormat:@"SJTableColumn%@", columnName]];
    [[column headerView] setStringValue:columnName];
    [column setWidth:widthOfHeader];
    [tableView addTableColumn:column];
  }
  
  [scrollView setDocumentView:tableView];
  
  return scrollView;
}



@end