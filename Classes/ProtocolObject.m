//
//  ProtocolObject.m
//  Protocol
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProtocolObject.h"

@implementation ProtocolObject

+ (NSArray*)createWithArray:(NSArray*)jsonArray {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in jsonArray) {
        Class protocolObjectClass = [self class];
        NSLog(@"This class? %@", protocolObjectClass);
        [array addObject:[[protocolObjectClass alloc] initWithDictionary:dict]];
    }
    
    return array;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if (self) {
        
        // Loops through all keys to map to propertiess
        NSDictionary *map = [self mapKeysToProperties];
        for (NSString *key in [map allKeys]) {
            
            // Checks if the key to map is in the dictionary to map
            if ([dict objectForKey:key] != nil && [dict objectForKey:key] != [NSNull null]) {

                [self setValue:[dict objectForKey:key] forKey:[map objectForKey:key] ];
                
            }
            
        }
    }
    return self;
}

- (NSDictionary *)mapKeysToProperties {
    return [[NSDictionary alloc] init];
}

@end
