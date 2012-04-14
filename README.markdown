Protocol
=========
Protocol is HTTP requests made simple. One method to call to send off a GET, POST, PUT, or DELETE. Pass in a block to that method to handle its response there you have it.
=========
* Features
	* Settings of base URL for all requests
	* Send GET, POST, PUT, and DELETE requests
	* Pass in block to get raw NSData or serialized NSArray or NSDicitionary from a JSON response
	* Map JSON responses to models
	* Add headers to be set on each request (great for sessions)
	* Easy, easy file upload
	* Manual caching of route responses (great for images)
	* Enabling of mock responses (great for when an API isn't ready yet)


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

Examples - Mock responses (for when the API isn't done but you need to test)
-----------
### Set mock responses
	// Enables mock responses
	[[ProtocolManager sharedInstance] setMockResponseOn:YES];

	// Sets a string response for a route of "/members"
	[[ProtocolManager sharedInstance] registerMockResponse:[[[NSString alloc] initWithString:@"[{\"first_name\":\"Josh\",\"last_name\":\"Holtz\"},{\"first_name\":\"Joshua\",\"last_name\":\"Holtz\"},{\"first_name\":\"Jossshhhhhh\",\"last_name\":\"Holtz\"}]"] dataUsingEncoding:NSUTF8StringEncoding] withRoute:@"/members" withMethod:kProtocolRouteGET];

	// Sets a string response for a route defined by a regex for "/members/(\\d+)?"
	[[ProtocolManager sharedInstance] registerMockResponse:[[[NSString alloc] initWithString:@"{\"first_name\":\"Josh\",\"last_name\":\"Holtz\"}"] dataUsingEncoding:NSUTF8StringEncoding] withRoute:[NSRegularExpression regularExpressionWithPattern:@"/member/(\\d+)?" options:NSRegularExpressionCaseInsensitive error:nil] withMethod:kProtocolRouteGET];

	// Gets a JSON member object
	[[ProtocolManager sharedInstance] doGet:@"/member/4" params:nil withJSONBlock:^(NSURLResponse *response, NSUInteger status, id json) {

		if ([json isKindOfClass:[NSDictionary class]]) {
			Member *member = [[Member alloc] initWithDictionary:json];
			NSLog(@"Member - %@ %@", member.firstName, member.lastName);
		}

	}];

	// Gets a JSON array of member objects
	[[ProtocolManager sharedInstance] doGet:@"/members" params:nil withJSONBlock:^(NSURLResponse *response, NSUInteger status, id json) {

		if ([json isKindOfClass:[NSArray class]]) {
			NSArray *members = [Member createWithArray:json];
			for (Member *member in members) {
				NSLog(@"Member in members - %@ %@", member.firstName, member.lastName);
			}
		}

	}];
