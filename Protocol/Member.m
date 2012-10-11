//
//  Member.m
//  Protocol
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Member.h"

@implementation Member

@synthesize memberId = _memberId;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize birthday = _birthday;

@synthesize pet = _pet;

- (NSDictionary *)mapKeysToProperties {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            @"memberId", @"id",
            @"firstName", @"first_name",
            @"lastName", @"last_name",
            @"Date:birthday", @"birthday",  // The ":" is used for calling a function
            @"Pet.pet", @"pet",             // The "." is used for inflating another model
            nil ];
}

@end
