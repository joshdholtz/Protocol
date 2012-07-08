//
//  ProtocolPersist.h
//  Protocol
//
//  Created by Josh Holtz on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProtocolObject.h"

typedef enum {
    ProtocolRelationshipOneToOne,
    ProtocolRelationshipOneToMany
} ProtoclRelationshipTypes;

@protocol ProtocolPersistDelegate <NSObject>
@required

- (NSInteger)valueForPrimaryKey;
- (NSArray*)propertiesToPersist;

@end

@interface ProtocolPersist : NSObject

@property (nonatomic, strong) NSString *databaseFilePath;
@property (nonatomic, strong) NSMutableDictionary *objectRelationships;

+ (id)sharedInstance;

- (void)saveRouteCache:(NSString*)route data:(NSData*)data;
- (NSData*)getRouteCache:(NSString*)route;

- (void)setRelationship:(Class)fromClass to:(Class)toClass as:(ProtoclRelationshipTypes)relationshipType;

- (NSArray*)getObjects:(Class)class;
- (id)getObject:(Class)class withId:(NSInteger)objectId;
- (void)saveObject:(ProtocolObject<ProtocolPersistDelegate>*)protocolObject;
- (BOOL)deleteObject:(ProtocolObject<ProtocolPersistDelegate>*)protocolObject;

@end
