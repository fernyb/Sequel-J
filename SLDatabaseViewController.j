
@import <Foundation/Foundation.j>

@implementation SLDatabaseViewController : CPObject
{
    @outlet CPSplitView dbSplitView;
}

- (id)init
{
    if (self = [super init])
    {
      //[CPBundle loadCibNamed:@"SJDatabaseView" owner:self loadDelegate:self];
    }
    return self;
}

- (void)awakeFromCib
{
 //alert("Cib is Loaded!");
}

- (void)didLogin
{
 window.alert("Did Login Alert!");
}

- (void)cibDidFailToLoad:(id)sender
{
  alert(@"Failed to load CIB");

}

@end
