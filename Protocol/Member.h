//
//  Member.h
//  Protocol
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProtocolObject.h"

#import "Pet.h"

@interface Member : ProtocolObject

@property (nonatomic, strong) NSNumber *memberId;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSDate *birthday;

@property (nonatomic, strong) Pet *pet;

@end
