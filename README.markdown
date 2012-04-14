RestCat
=========

Examples - Basic Requests
-----------

### Initializations (probably put in AppDelegate?)
	
	// Sets the base url to be used in all request (unless route in request is a full route)
	[[ProtocolManager sharedInstance] setBaseURL:@"http://joshdholtz.com"];

	// Enables the activity indicator in the status bar
	[[ProtocolManager sharedInstance] setNetworkActivityIndicatorVisible:YES];

### Make GET request
	// Gets a JSON member object
	[[ProtocolManager sharedInstance] doGet:@"/protocol.php?example=member_1" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {

		NSLog(@"Member response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

	}];

### Make GET request with JSON response
	// Gets a JSON member object
	[[ProtocolManager sharedInstance] doGet:@"/protocol.php?example=member_1" params:nil withJSONBlock:^(NSURLResponse *response, NSUInteger status, id json) {

		if ([json isKindOfClass:[NSDictionary class]]) {
			NSLog(@"Member response as dictionary - %@", json);
		}

	}];



Examples - Models
-----------
###Model - Member.h
	#import "ProtocolObject.h"

	@interface Member : ProtocolObject

	@property (nonatomic, strong) NSString* firstName;
	@property (nonatomic, strong) NSString* lastName;

	@end

###Model - Member.m
	#import "Member.h"

	@implementation Member

	@synthesize firstName = _firstName;
	@synthesize lastName = _lastName;

	- (NSDictionary *)mapKeysToProperties {
		return [[NSDictionary alloc] initWithObjectsAndKeys:
			@"firstName", @"first_name",
			@"lastName", @"last_name",
			nil ];
	}

	@end

### Make GET request with JSON response and map to Member object
	// Gets a JSON member object
	[[ProtocolManager sharedInstance] doGet:@"/protocol.php?example=member_1" params:nil withJSONBlock:^(NSURLResponse *response, NSUInteger status, id json) {

		if ([json isKindOfClass:[NSDictionary class]]) {
			Member *member = [[Member alloc] initWithDictionary:json];
			NSLog(@"Member - %@ %@", member.firstName, member.lastName);
		}

	}];

### Make GET request with JSON response and map to NSArray of Member objects
	// Gets a JSON array of member objects
	[[ProtocolManager sharedInstance] doGet:@"/protocol.php?example=members" params:nil withJSONBlock:^(NSURLResponse *response, NSUInteger status, id json) {

		if ([json isKindOfClass:[NSArray class]]) {
			NSArray *members = [Member createWithArray:json];
			for (Member *member in members) {
				NSLog(@"Member in members - %@ %@", member.firstName, member.lastName);
			}
		}

	}];

Examples - More requests!
-----------
### Persistant headers (for session perhaps?)
	NSDictionary *loginDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"joshdholtz@gmail.com", @"email", @"test01", @"password", nil];

	[[ProtocolManager sharedInstance] doPost:@"/session" params:loginDict withJSONBlock:^(NSURLResponse *response, NSUInteger status, id json){

		NSLog(@"Status - %d", status);
		Member *member = [[Member alloc] initWithDictionary:json];
		NSLog(@"Logged in member - %@", member.firstName);

		NSString *cookie = [[((NSHTTPURLResponse*) response) allHeaderFields] objectForKey:@"Set-Cookie"];
		[[ProtocolManager sharedInstance] addHttpHeader:cookie forKey:@"Cookie"];

	} ];

### File upload
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"me_coding" ofType:@"jpg"];  
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	if (data) {
		NSLog(@"Data length - %d", [data length]);

		[[ProtocolManager sharedInstance] doMultipartPost:@"upload.php" andData:data withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {
			if (status == 200) {
				NSLog(@"File upload was successful");
			}
		}];
	}

### Caching of route response (for images perhaps?)
	[[ProtocolManager sharedInstance] doGet:@"http://www.housecatscentral.com/cat1.jpg" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {

		if (status == 200) {
			NSLog(@"Got it - %d", [data length]);
			[[ProtocolManager sharedInstance] addCachedResponse:@"http://www.housecatscentral.com/cat1.jpg" withData:data];
		}

	}];

	// Need to explicitly remove cached route response when done
	[[ProtocolManager sharedInstance] removeCachedResponse:@"httAp://www.housecatscentral.com/cat1.jpg"]; // Removes single cached route
	[[ProtocolManager sharedInstance] removeAllCachedResponses]; // Removes all cached routes
