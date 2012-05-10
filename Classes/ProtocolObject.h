//
//  ProtocolObject.h
//  Protocol
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProtocolObject : NSObject

@property (nonatomic, assign) NSInteger primaryId;

+ (NSArray*)createWithArray:(NSArray*)jsonArray;

- (id)initWithDictionary:(NSDictionary*)dict andPrimaryId:(NSInteger)primaryId;
- (id) initWithDictionary:(NSDictionary*)dict;
- (void) setWithDictionary:(NSDictionary*)dict;

- (NSDictionary*) mapKeysToProperties;

@end
