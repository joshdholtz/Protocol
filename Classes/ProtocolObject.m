//
//  ProtocolObject.m
//  Protocol
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProtocolObject.h"

#import "ProtocolManager.h"

@implementation ProtocolObject

@synthesize primaryId = _primaryId;

+ (NSArray*)createWithArray:(NSArray*)jsonArray {
    return [ProtocolObject createWithArray:jsonArray withClass:[self class]];
}
    
+ (NSArray*)createWithArray:(NSArray*)jsonArray withClass:(Class)protocolObjectClass {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in jsonArray) {
        [array addObject:[[protocolObjectClass alloc] initWithDictionary:dict]];
    }
    
    return array;
}

- (NSDictionary*)preInit:(NSDictionary*)dict {
    return nil;
}

- (id)initWithDictionary:(NSDictionary*)dict andPrimaryId:(NSInteger)primaryId {
    self = [self init];
    if (self) {
//        NSDictionary *newDict = [self preInit:dict];
//        if (newDict != nil) {
//            dict = newDict;
//        }
        [self setValuesForKeysWithDictionary:dict];
        _primaryId = primaryId;
    }
    return self;
}


- (id)initWithDictionary:(NSDictionary*)dict {
    self = [self init];
    if (self) {
//        NSDictionary *newDict = [self preInit:dict];
//        if (newDict != nil) {
//            dict = newDict;
//        }
        [self setWithDictionary:dict];
        _primaryId = -1;
    }
    return self;
}

- (void) setWithDictionary:(NSDictionary*)dict {
    NSDictionary *newDict = [self preInit:dict];
    if (newDict != nil) {
        dict = newDict;
    }
    
    // Loops through all keys to map to propertiess
    NSDictionary *map = [self mapKeysToProperties];
    for (NSString *key in [map allKeys]) {
        
        // Checks if the key to map is in the dictionary to map
        if ([dict objectForKey:key] != nil && [dict objectForKey:key] != [NSNull null]) {
            
//            NSLog(@"Property - %@", key);
            
            NSString *property = [map objectForKey:key];
            
            NSRange inflateRange = [property rangeOfString:@"."];
            NSRange formatRange = [property rangeOfString:@":"];
            
            if (inflateRange.location != NSNotFound) {
                NSString *object = [property substringToIndex:inflateRange.location];
                property = [property substringFromIndex:(inflateRange.location+1)];
                
                Class class = NSClassFromString(object);
                if ([[dict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
                    ProtocolObject *obj = [[class alloc] initWithDictionary:[dict objectForKey:key]];
                    
                    [self setValue:obj forKey:property];
                } else if ([[dict objectForKey:key] isKindOfClass:[NSArray class]]) {
                    NSArray *array = [ProtocolObject createWithArray:[dict objectForKey:key] withClass:class];
                                      
                    [self setValue:array forKey:property];
                }
            } else if (formatRange.location != NSNotFound) {
                NSString *formatFunction = [property substringToIndex:formatRange.location];
                property = [property substringFromIndex:(formatRange.location+1)];
                
                [self setValue:[[ProtocolManager sharedInstance] performFormatBlock:[dict objectForKey:key] withKey:formatFunction] forKey:property ];
            } else {
                [self setValue:[dict objectForKey:key] forKey:property ];
            }
            
        } else {
//            NSLog(@"CANT FIND Property - %@", key);
        }
        
    }
}

- (NSDictionary *)mapKeysToProperties {
    return [[NSDictionary alloc] init];
}

@end
