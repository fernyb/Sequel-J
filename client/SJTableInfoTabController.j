
@import <Foundation/CPObject.j>
@import "SJTabBaseController.j"


@implementation SJTableInfoTabController : SJTabBaseController
{
}

- (void)viewDidSet
{
  [super viewDidSet];
  [self createTopView];
}

- (void)createTopView
{
/**
* TODO: Must be able to change values.
*/
  var topView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 600, 200)];
  
  var labelType = [self createLabelAndPopup:@"Type:"];
  var labelTypeFrame = [labelType frame];
  labelTypeFrame.origin.y += 0;
  [labelType setFrame:labelTypeFrame];
  [topView addSubview:labelType];
  
  var labelEncoding = [self createLabelAndPopup:@"Encoding:"];
  var labelEncodingFrame = [labelEncoding frame];
  labelEncodingFrame.origin.y = [labelType frame].size.height + 5 + [labelType frame].origin.y;
  [labelEncoding setFrame:labelEncodingFrame];
  [topView addSubview:labelEncoding];
  
  var labelCollation = [self createLabelAndPopup:@"Collation:"];
  var labelCollationFrame = [labelCollation frame];
  labelCollationFrame.origin.y = [labelEncoding frame].size.height + 5 + [labelEncoding frame].origin.y;
  [labelCollation setFrame:labelCollationFrame];
  [topView addSubview:labelCollation];
  
  // On Right Side
  var labelCreatedAt = [self labelFor:@"Created at:" withValue:@"May 30, 2011 10:16:19 AM"];
  var labelCreatedAtFrame = [labelCreatedAt frame];
  labelCreatedAtFrame.origin.x = labelCollationFrame.size.width + 20;
  [labelCreatedAt setFrame:labelCreatedAtFrame];
  [topView addSubview:labelCreatedAt];
  
  var labelUpdatedAt = [self labelFor:@"Updated at:" withValue:@"No Available"];
  var labelUpdatedAtFrame = [labelUpdatedAt frame];
  labelUpdatedAtFrame.origin.x = labelCreatedAtFrame.origin.x;
  labelUpdatedAtFrame.origin.y = labelEncodingFrame.origin.y - 1.5;
  [labelUpdatedAt setFrame:labelUpdatedAtFrame];
  [topView addSubview:labelUpdatedAt];  
  
  /*
  var lineview = [[CPBox alloc] initWithFrame:[topView frame]];
  [lineview setBorderType:CPBoxSeparator];
  [lineview setBoxType:nil];
  [topView addSubview:lineview];
  */
  
  [[self view] addSubview:topView];
}

- (CPView)createLabelAndPopup:(CPString)labelStr
{
  var itemview = [[CPView alloc] initWithFrame:CGRectMake(0,0,290, 37)];
  
  // Label Name for connection
  var label = [[CPTextField alloc] initWithFrame:CGRectMake(5,5,70,28)]; 
  [label setStringValue:labelStr]; 
  [label setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
  [label setEditable:NO]; 
  [label setBezeled: NO]; 
  [label setVerticalAlignment:CPCenterVerticalTextAlignment];
  [label setAlignment:CPRightTextAlignment];
	[label setBackgroundColor:[CPColor clearColor]];
	
	[itemview addSubview:label];
	
	var popupY = (24 - ([label frame].size.height / 2)) / 2;
	popupY += ([label frame].origin.x / 2) / 2;
	
  var popupMenu = [[CPPopUpButton alloc] initWithFrame:CGRectMake([label frame].origin.x + [label frame].size.width + 5, popupY, 200, 24)];

	[popupMenu setTarget:self];
	[popupMenu setAction:@selector(selectedDatabase:)];
	[popupMenu setTitle:@"Choose Database..."];
	[popupMenu addItemWithTitle:@"InnoDB"];
  
  [itemview addSubview:popupMenu];
  [itemview setBackgroundColor:[CPColor clearColor]];
  
  return itemview;
}

- (CPView)labelFor:(CPString)labelStr withValue:(CPString)valueStr
{
  var labelView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 300, 85)];
  
  var label = [[CPTextField alloc] initWithFrame:CGRectMake(5,5,70,28)]; 
  [label setStringValue:labelStr]; 
  [label setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
  [label setEditable:NO]; 
  [label setBezeled: NO]; 
  [label setVerticalAlignment:CPCenterVerticalTextAlignment];
  [label setAlignment:CPRightTextAlignment];
	[label setBackgroundColor:[CPColor clearColor]];
	
	[labelView addSubview:label];
	
  var labelValue = [[CPTextField alloc] initWithFrame:CGRectMake([label frame].origin.x + [label frame].size.width + 5, 5,180,28)]; 
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
