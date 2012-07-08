
//
//  Pet.m
//  Protocol
//
//  Created by Josh Holtz on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Pet.h"

@implementation Pet

@synthesize petId = _petId;
@synthesize name = _name;
@synthesize kind = _kind;

- (NSDictionary *)mapKeysToProperties {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            @"petId", @"id",
            @"name", @"name",
            @"kind", @"kind",
            nil ];
}

#pragma mark - Protocol Persist Delegate

- (NSInteger)valueForPrimaryKey {
    return [_petId intValue];
}

- (NSArray *)propertiesToPersist {
    return [[NSArray alloc] initWithObjects:@"petId", @"name", @"kind", nil];
}

@end
