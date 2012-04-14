//
//  Member.h
//  Protocol
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProtocolObject.h"

#import "ProtocolPersist.h"

@interface Member : ProtocolObject<ProtocolPersistDelegate>

@property (nonatomic, assign) NSInteger memberId;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;

@end
