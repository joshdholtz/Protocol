//
//  Pet.h
//  Protocol
//
//  Created by Josh Holtz on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProtocolObject.h"

#import "ProtocolPersist.h"

@interface Pet : ProtocolObject<ProtocolPersistDelegate>

@property (nonatomic, strong) NSNumber *petId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *kind;

@end
