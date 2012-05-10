//
//  ProtocolPersist.h
//  Protocol
//
//  Created by Josh Holtz on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProtocolObject.h"

@protocol ProtocolPersistDelegate <NSObject>
@required
- (NSInteger)valueForPrimaryKey;
- (NSArray*)propertiesToSave;

@end

@interface ProtocolPersist : NSObject

@property (nonatomic, strong) NSString *databaseFilePath;

+ (id)sharedInstance;

- (NSArray*)getObjects:(Class)class;
- (id)getObject:(Class)class withId:(NSInteger)objectId;
- (void)saveObject:(ProtocolObject<ProtocolPersistDelegate>*)protocolObject;
- (BOOL)deleteObject:(ProtocolObject<ProtocolPersistDelegate>*)protocolObject;

@end
