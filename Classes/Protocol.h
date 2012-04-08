//
//  Protocol.h
//  Protocol
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Protocol : NSObject

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSMutableDictionary *httpHeaders;

+ (id)sharedInstance;

- (void) addHttpHeader:(NSString*)value forKey:(NSString*)key;
- (void) removeHttpHeaderForKey:(NSString*)key;

- (void) doGetAsJSON:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doPostAsJSON:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doPutAsJSON:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doDeleteAsJSON:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;

- (void) doGet:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doPost:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doPut:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doDelete:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;

@end
