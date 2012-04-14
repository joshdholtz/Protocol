RestCat
=========

Examples - Basic Requests
-----------

###Set base url
	
	[[ProtocolManager sharedInstance] setBaseURL:@"http://192.168.1.7"];

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
