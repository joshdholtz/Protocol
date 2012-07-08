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

- (NSDictionary *)mapKeysToProperties {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            @"memberId", @"id",
            @"firstName", @"first_name",
            @"lastName", @"last_name",
            nil ];
}

#pragma mark - Protocol Persist Delegate

- (NSInteger)valueForPrimaryKey {
    return _memberId;
}

- (NSArray *)propertiesToPersist {
    return [[NSArray alloc] initWithObjects:@"memberId", @"firstName", @"lastName", nil];
}

@end
