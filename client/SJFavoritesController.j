@import "SJFavoriteNode.j"

var sharedFavoritesController = nil;

@implementation SJFavoritesController : CPObject
{
	CPArray		favorites @accessors;
}

+ (id)sharedFavoritesController
{
	if( !sharedFavoritesController )
		sharedFavoritesController = [[SJFavoritesController alloc] init];
	
	return sharedFavoritesController;
}

- (void)init
{
	self = [super init];
	[self _loadFavorites];
	
	return self;
}

- (void)saveFavorites
{
	
}

- (void)addFavoriteWithType:(CPString)aType name:(CPString)aName host:(CPString)aHost username:(CPString)aUsername password:(CPString)aPassword database:(CPString)aDatabase port:(int)aPort
{
	var favoriteNode = [[SJFavoriteNode alloc] init];
	var nodeConnectionDetails = [[CPDictionary alloc] init];
	
	[nodeConnectionDetails setObject:aType 		forKey:@"connectionType"];
	[nodeConnectionDetails setObject:aHost 		forKey:@"connectionHost"];
	[nodeConnectionDetails setObject:aUsername 	forKey:@"connectionUsername"];
	[nodeConnectionDetails setObject:aPassword 	forKey:@"connectionPassword"];
	[nodeConnectionDetails setObject:aDatabase 	forKey:@"connectionDatabase"];
	[nodeConnectionDetails setObject:aPort 		forKey:@"connectionPort"];
	
	[favoriteNode setNodeName:aName];
	[favoriteNode setNodeConnectionDetails:nodeConnectionDetails];
	
	[favorites addObject:favoriteNode];
	
	[self saveFavorites];
	
	[[CPNotificationCenter defaultCenter] postNotificationName:@"didAddFavorite" object:favoriteNode];
}

- (void)_loadFavorites
{
	var fav1 = [[SJFavoriteNode alloc] init],
	    fav2 = [[SJFavoriteNode alloc] init],
	    fav3 = [[SJFavoriteNode alloc] init];
	
	var nodeConnectionDetails = [[CPDictionary alloc] init];
	
	[nodeConnectionDetails setObject:@"standard" 	forKey:@"connectionType"];
	[nodeConnectionDetails setObject:@"127.0.0.1" 	forKey:@"connectionHost"];
	[nodeConnectionDetails setObject:@"root"		forKey:@"connectionUsername"];
	[nodeConnectionDetails setObject:@"root"		forKey:@"connectionPassword"];
	[nodeConnectionDetails setObject:@"" 			forKey:@"connectionDatabase"];
	[nodeConnectionDetails setObject:@"" 			forKey:@"connectionPort"];
	
	
	[fav1 setNodeName:@"Localhost"];
	[fav1 setNodeConnectionDetails:nodeConnectionDetails];
	
	favorites = [fav1];
}

@end