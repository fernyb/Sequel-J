
@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"
@import "LPMultiLineTextField.j"
@import "SJConstants.j"


@implementation SJTableInfoTabController : SJTabBaseController
{
  CPView topView;
  CPView topViewLine;
  CPView middleView;
  CPView middleViewLine;
  CPView bottomView;
  CPDictionary formFields;
}


- (void)viewDidSet
{
  [super viewDidSet];
  formFields = [[CPDictionary alloc] init];
  [[self view] setBackgroundColor:[CPColor colorWithHexString:@"eee"]];
  [self createTopView];
  [self createMiddleView];
  [self createBottomView];
}

// Called when selected from the left Table View
- (void)databaseTableSelected
{
  [self loadTableInfo];
}

// Called when selected from the Toolbar Tab
- (void)viewWillAppear
{
  [self loadTableInfo];
}

- (void)loadTableInfo
{
  if ([self tableName]) {
    
    var options = [[CPDictionary alloc] initWithObjects:[[self tableName]] forKeys:[@"table"]];

    [[SJAPIRequest sharedAPIRequest] sendRequestToEndpoint:@"table_info" withOptions:options callback:function( js ) 
    {
      [self handleTableInfoResponse:js];
    }];
  }
}

- (void)handleTableInfoResponse:(id)js
{
  [self setString:js.sql forKey:@"create_syntax"];
  
  var status = js.status;
  [self setString:status.create_time forKey:@"created_at"];
  [self setString:status.update_time forKey:@"updated_at"];
  [self setString:status.rows forKey:@"number_of_rows"];
  [self setString:status.row_format forKey:@"row_format"];
  [self setString:status.avg_row_length forKey:@"avg_row_length"];
  [self setString:status.auto_increment forKey:@"auto_increment"];
  
  var convertToCorrectSize = function(size) {
    var dataSize = parseInt(size) >= 0 ? parseInt(size) : 0;
    dataSize = (dataSize / 1024);
    if(dataSize > 1024) {
      dataSize = dataSize / 1024;
      if (dataSize > 1024) {
        dataSize = dataSize / 1024;
        dataSize += " GB";
      } else {
        dataSize += " MB";
      }
    } else {
      dataSize += " KB";
    }
    return dataSize;
  };

  [self setString:convertToCorrectSize(status.data_length) forKey:@"data_size"];
  [self setString:convertToCorrectSize(status.max_data_length) forKey:@"max_data_size"];
  [self setString:convertToCorrectSize(status.index_length) forKey:@"index_size"];
  [self setString:convertToCorrectSize(status.data_free) forKey:@"free_data_size"];
  
  [self setMenuItems:js.engines forKey:@"type_menu"];
  [self setMenuItems:js.encodings forKey:@"encoding_menu"];
  [self setMenuItems:js.collations forKey:@"collation_menu"];
  
  [self selectPopupButtonForKey:@"type_menu" withObject:js];
  [self selectPopupButtonForKey:@"encoding_menu" withObject:js];
  [self selectPopupButtonForKey:@"collation_menu" withObject:js];
}

- (void)setString:(CPString)str forKey:(CPString)akey
{
  var obj = [formFields objectForKey:akey];
  if(obj && [obj respondsToSelector:@selector(setStringValue:)]) {
    [obj setStringValue:str];
  }
}

- (void)selectPopupButtonForKey:(CPString)akey withObject:(id)js
{
  var popupMenu = [formFields objectForKey:akey];
  var titles = [popupMenu itemTitles];
    
  if (akey == @"type_menu") {
    [popupMenu selectItemWithTitle:js.status.engine];
  }
  else if (akey == @"encoding_menu") {
    for (var i=0; i<[js.encodings count]; i++) {
      var item = [js.encodings objectAtIndex:i];
      if (item.collate_set_name.indexOf(js.status.collation) != -1) {
        [popupMenu selectItemAtIndex:i];
        break;
      }
    }
  }
  else if (akey == @"collation_menu") {
    for (var i=0; i<[js.collations count]; i++) {
      var item = [js.collations objectAtIndex:i];
      if (item.collation_name.indexOf(js.status.collation) != -1) {
        [popupMenu selectItemAtIndex:i];
        break;
      }
    }    
  }
}

- (void)setMenuItems:(CPArray)items forKey:(CPString)akey
{
  var popupMenu = [formFields objectForKey:akey];
  
  if ([popupMenu respondsToSelector:@selector(removeAllItems)]) {
    [popupMenu removeAllItems];
  }
  
  if (akey == @"type_menu") {
    [items each:function(item) {
      [popupMenu addItemWithTitle:item];
    }];
  }
  else if (akey == @"encoding_menu") {
    [items each:function(item) {
      var title = item.description + " ("+ item.collation_name +")";
      [popupMenu addItemWithTitle:title];
    }];
  }
  else if (akey == @"collation_menu") {
    [items each:function(item) {
      [popupMenu addItemWithTitle:item.collation_name];  
    }];
  }
}

- (void)didSelectCollation:(CPPopUpButton)sender
{
  var title = [sender titleOfSelectedItem];
  alert(title);
}

- (void)didSelectEncoding:(CPPopUpButton)sender
{
  var title = [sender titleOfSelectedItem];
  alert(title);
}

- (void)didSelecType:(CPPopUpButton)sender
{
  var title = [sender titleOfSelectedItem];
  alert(title);
}


- (void)viewDidAdjust
{
  // adjust the middle view
  var topViewFrame = [topView frame];
  topViewFrame.size.width = [[self view] frame].size.width;
  [topView setFrame:topViewFrame];
  [topViewLine setBackgroundColor:[CPColor blackColor]];
  
  var middleViewFrame = [middleView frame];
  middleViewFrame.size.width = [[self view] frame].size.width;
  [middleView setFrame:middleViewFrame];
  [middleViewLine setBackgroundColor:[CPColor blackColor]];
  
  var bottomViewFrame = [bottomView frame];
  bottomViewFrame.size.width = [[self view] frame].size.width;
  [bottomView setFrame:bottomViewFrame];
}


- (CGRect)createTopView
{
  var topViewSizeWidth = [[self view] frame].size.width;
  topView = [[CPView alloc] initWithFrame:CGRectMake(0, 10, topViewSizeWidth, 115)];
  [topView setAutoresizingMask:CPViewWidthSizable];
  
  var labelType = [self createLabelAndPopup:@"Type:" withActionSelector:@selector(didSelecType:)];
  var labelTypeFrame = [labelType frame];
  labelTypeFrame.origin.y += 0;
  [labelType setFrame:labelTypeFrame];
  [topView addSubview:labelType];
  [formFields setObject:[[labelType subviews] lastObject] forKey:@"type_menu"];
    
  
  var labelEncoding = [self createLabelAndPopup:@"Encoding:" withActionSelector:@selector(didSelectEncoding:)];
  var labelEncodingFrame = [labelEncoding frame];
  labelEncodingFrame.origin.y = [labelType frame].size.height + 5 + [labelType frame].origin.y;
  [labelEncoding setFrame:labelEncodingFrame];
  [topView addSubview:labelEncoding];
  [formFields setObject:[[labelEncoding subviews] lastObject] forKey:@"encoding_menu"];
    
    
  var labelCollation = [self createLabelAndPopup:@"Collation:" withActionSelector:@selector(didSelectCollation:)];
  var labelCollationFrame = [labelCollation frame];
  labelCollationFrame.origin.y = [labelEncoding frame].size.height + 5 + [labelEncoding frame].origin.y;
  [labelCollation setFrame:labelCollationFrame];
  [topView addSubview:labelCollation];
  [formFields setObject:[[labelCollation subviews] lastObject] forKey:@"collation_menu"];
  
  
  // On Right Side
  var labelCreatedAt = [self labelFor:@"Created at:" withValue:@"May 30, 2011 10:16:19 AM"];
  var labelCreatedAtFrame = [labelCreatedAt frame];
  labelCreatedAtFrame.origin.x = labelCollationFrame.size.width + 20;
  [labelCreatedAt setFrame:labelCreatedAtFrame];
  [topView addSubview:labelCreatedAt];
  [formFields setObject:[[labelCreatedAt subviews] lastObject] forKey:@"created_at"];
  
  var labelUpdatedAt = [self labelFor:@"Updated at:" withValue:@"No Available"];
  var labelUpdatedAtFrame = [labelUpdatedAt frame];
  labelUpdatedAtFrame.origin.x = labelCreatedAtFrame.origin.x;
  labelUpdatedAtFrame.origin.y = labelEncodingFrame.origin.y - 1.5;
  [labelUpdatedAt setFrame:labelUpdatedAtFrame];
  [topView addSubview:labelUpdatedAt];  
  [formFields setObject:[[labelUpdatedAt subviews] lastObject] forKey:@"updated_at"];
  
  topViewLine = [[CPView alloc] initWithFrame:CGRectMake(10, [topView frame].size.height - 2, [topView frame].size.width - 20, 1)];
  [topViewLine setAutoresizingMask:CPViewWidthSizable];
  [topViewLine lockFocus];
  var path = [CPBezierPath bezierPathWithRect:[topViewLine frame]];
  [[CPColor colorWithHexString:@"7d7d7d"] set];
  [path fill];
  [topViewLine unlockFocus];
  
  [topView addSubview:topViewLine];
  
  [[self view] addSubview:topView];
}


- (void)createMiddleView
{
  var middleViewSizeWidth = [topView frame].size.width;
  var middleViewOriginX = [topView frame].origin.x;
  var middleViewOriginY = [topView frame].origin.y + [topView frame].size.height + 10;
  
  middleView = [[CPView alloc] initWithFrame:CGRectMake(middleViewOriginX, middleViewOriginY, middleViewSizeWidth, 110)];
  [middleView setAutoresizingMask:CPViewWidthSizable];
  
  // Left Column
  var labelNumRows = [self labelFor:@"Number of rows:" withValue:@"~85"];
  [middleView addSubview:labelNumRows];
  [formFields setObject:[[labelNumRows subviews] lastObject] forKey:@"number_of_rows"];
  
  var labelRowFormat = [self labelFor:@"Row format:" withValue:@"Compact"];
  var labelRowFormatFrame = [labelRowFormat frame];
  labelRowFormatFrame.origin.y = [labelNumRows frame].origin.y + [labelNumRows frame].size.height;
  [labelRowFormat setFrame:labelRowFormatFrame];
  [middleView addSubview:labelRowFormat];
  [formFields setObject:[[labelRowFormat subviews] lastObject] forKey:@"row_format"];
  
  var labelAvgRowLength = [self labelFor:@"Avg. row length:" withValue:@"192"];
  var labelAvgRowLengthFrame = [labelAvgRowLength frame];
  labelAvgRowLengthFrame.origin.y = labelRowFormatFrame.origin.y + labelRowFormatFrame.size.height;
  [labelAvgRowLength setFrame:labelAvgRowLengthFrame];
  [middleView addSubview:labelAvgRowLength];
  [formFields setObject:[[labelAvgRowLength subviews] lastObject] forKey:@"avg_row_length"];
  
  var labelAutoIncrement = [self labelFor:@"Auto increment:" withValue:@"86"];
  var labelAutoIncrementFrame = [labelAutoIncrement frame];
  labelAutoIncrementFrame.origin.y = labelAvgRowLengthFrame.origin.y + labelAvgRowLengthFrame.size.height;
  [labelAutoIncrement setFrame:labelAutoIncrementFrame];
  [middleView addSubview:labelAutoIncrement];
  [formFields setObject:[[labelAutoIncrement subviews] lastObject] forKey:@"auto_increment"];
  
  // Right Column
  var labelDataSize = [self labelFor:@"Data Size:" withValue:@"16.0 KB"];
  var labelDataSizeFrame = [labelDataSize frame];
  labelDataSizeFrame.origin.x = [labelNumRows frame].origin.x + [labelNumRows frame].size.width + 10;
  labelDataSizeFrame.origin.y = [labelNumRows frame].origin.y;
  [labelDataSize setFrame:labelDataSizeFrame];
  [middleView addSubview:labelDataSize];
  [formFields setObject:[[labelDataSize subviews] lastObject] forKey:@"data_size"];
    
  var labelMaxDataSize = [self labelFor:@"Max data size:" withValue:@"0 B"];
  var labelMaxDataSizeFrame = [labelMaxDataSize frame];
  labelMaxDataSizeFrame.origin.x = labelDataSizeFrame.origin.x;
  labelMaxDataSizeFrame.origin.y = labelDataSizeFrame.origin.y + labelDataSizeFrame.size.height;
  [labelMaxDataSize setFrame:labelMaxDataSizeFrame];
  [middleView addSubview:labelMaxDataSize];
  [formFields setObject:[[labelMaxDataSize subviews] lastObject] forKey:@"max_data_size"];
    
  var labelIndexSize = [self labelFor:@"Index Size:" withValue:@"96.0 KB"];
  var labelIndexSizeFrame = [labelIndexSize frame];
  labelIndexSizeFrame.origin.x = labelMaxDataSizeFrame.origin.x;
  labelIndexSizeFrame.origin.y = labelMaxDataSizeFrame.origin.y + labelMaxDataSizeFrame.size.height;
  [labelIndexSize setFrame:labelIndexSizeFrame];
  [middleView addSubview:labelIndexSize];
  [formFields setObject:[[labelIndexSize subviews] lastObject] forKey:@"index_size"];
      
  var labelFreeDataSize = [self labelFor:@"Free data size:" withValue:@"409 MB"];
  var labelFreeDataSizeFrame = [labelFreeDataSize frame];
  labelFreeDataSizeFrame.origin.x = labelIndexSizeFrame.origin.x;
  labelFreeDataSizeFrame.origin.y = labelIndexSizeFrame.origin.y + labelIndexSizeFrame.size.height;
  [labelFreeDataSize setFrame:labelFreeDataSizeFrame];
  [middleView addSubview:labelFreeDataSize];
  [formFields setObject:[[labelFreeDataSize subviews] lastObject] forKey:@"free_data_size"];
  
  middleViewLine = [[CPView alloc] initWithFrame:CGRectMake(10, [middleView frame].size.height - 1, [middleView frame].size.width - 20, 1)];
  [middleViewLine lockFocus];
  var path = [CPBezierPath bezierPathWithRect:CGRectMake(0, 0, [middleViewLine frame].size.width, [middleViewLine frame].size.height)];
  [[CPColor colorWithHexString:@"7d7d7d"] set];
  [path fill];
  [middleViewLine unlockFocus];
  [middleViewLine setAutoresizingMask:CPViewWidthSizable];
    
  [middleView addSubview:middleViewLine];
  
  [[self view] addSubview:middleView];
}


- (void)createBottomView
{
  var labelViewOriginX = [middleView frame].origin.x;
  var labelViewOriginY = [middleView frame].origin.y + [middleView frame].size.height + 10;
  var labelViewSizeWidth = [middleView frame].size.width;
  var labelVieSizeHeight = 300;
  
  bottomView = [[CPView alloc] initWithFrame:CGRectMake(labelViewOriginX, labelViewOriginY, labelViewSizeWidth, labelVieSizeHeight)];
  [bottomView setAutoresizingMask:CPViewWidthSizable];
    
  var label = [[CPTextField alloc] initWithFrame:CGRectMake(2, 2, 130, 20)];
  [label setAutoresizingMask:CPViewMaxXMargin | CPViewMaxYMargin];
  [label setStringValue:@"Create Syntax"];
  [label setFont:[CPFont boldSystemFontOfSize:12.0]];
  [label setEditable:NO]; 
  [label setBezeled: NO]; 
  [label setVerticalAlignment:CPCenterVerticalTextAlignment];
  [label setAlignment:CPRightTextAlignment];
	[label setBackgroundColor:[CPColor clearColor]];
	
	[bottomView addSubview:label];
	
	var textboxOriginX = [label frame].origin.x + [label frame].size.width + 5;
	var textboxSizeWidth = (labelViewSizeWidth - textboxOriginX) - 15;
 
  var textbox = [[LPMultiLineTextField alloc] initWithFrame:CGRectMake(textboxOriginX, 2, textboxSizeWidth - 5, labelVieSizeHeight - 4)];
  [textbox setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [textbox setEditable:YES];
  [textbox setBezeled:YES];
  [textbox setAlignment:CPLeftTextAlignment];
  [textbox setFont:[CPFont systemFontOfSize:12.0]];
  [formFields setObject:textbox forKey:@"create_syntax"];
  
  [bottomView addSubview:textbox];
  
  [[self view] addSubview:bottomView];
}


- (CPView)createLabelAndPopup:(CPString)labelStr withActionSelector:(SEL)actionSelector
{
  var itemview = [[CPView alloc] initWithFrame:CGRectMake(0,0,290, 28)];

  // Label Name for connection
  var label = [[CPTextField alloc] initWithFrame:CGRectMake(5,0,70,24)]; 
  [label setStringValue:labelStr]; 
  [label setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
  [label setEditable:NO]; 
  [label setBezeled: NO]; 
  [label setVerticalAlignment:CPCenterVerticalTextAlignment];
  [label setAlignment:CPRightTextAlignment];
	[label setBackgroundColor:[CPColor clearColor]];
	
	[itemview addSubview:label];
	
  var popupMenu = [[CPPopUpButton alloc] initWithFrame:CGRectMake([label frame].origin.x + [label frame].size.width + 5, 0, 200, 24)];
  [popupMenu setTarget:self];
	[popupMenu setAction:actionSelector];
	
  [itemview addSubview:popupMenu];
  [itemview setBackgroundColor:[CPColor clearColor]];
  
  return itemview;
}

- (CPView)labelFor:(CPString)labelStr withValue:(CPString)valueStr
{
  var labelView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 300, 24)];
  
  var label = [[CPTextField alloc] initWithFrame:CGRectMake(2, 2, 130, 20)];
  [label setStringValue:labelStr]; 
  [label setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
  [label setEditable:NO]; 
  [label setBezeled: NO]; 
  [label setVerticalAlignment:CPCenterVerticalTextAlignment];
  [label setAlignment:CPRightTextAlignment];
	[label setBackgroundColor:[CPColor clearColor]];
	
	[labelView addSubview:label];
	
  var labelValue = [[CPTextField alloc] initWithFrame:CGRectMake([label frame].origin.x + [label frame].size.width + 2, 2, 180, 20)]; 
  [labelValue setStringValue:valueStr]; 
  [labelValue setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [labelValue setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
  [labelValue setEditable:NO]; 
  [labelValue setBezeled: NO]; 
  [labelValue setVerticalAlignment:CPCenterVerticalTextAlignment];
  [labelValue setAlignment:CPLeftTextAlignment];
	[labelValue setBackgroundColor:[CPColor clearColor]];

	[labelView addSubview:labelValue];
		
	return labelView;
}

@end
