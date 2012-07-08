//
//  Protocol.h
//  Protocol
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kProtocolRouteGET 0
#define kProtocolRoutePOST 1
#define kProtocolRoutePUT 2
#define kProtocolRouteDELETE 3

#define kProtocolContentTypeFormData @"application/x-www-form-urlencoded"
#define kProtocolContentTypeJSON @"application/json"

#import <UIKit/UIKit.h>

@interface ProtocolManager : NSObject

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSMutableDictionary *httpHeaders;

@property (nonatomic, assign) BOOL debug;

@property (nonatomic, assign) BOOL mockResponseOn;

@property (nonatomic, assign) BOOL networkActivityIndicatorVisible;

@property (nonatomic, assign) BOOL reachabilityActive;

+ (id)sharedInstance;

- (void) addHttpHeader:(NSString*)value forKey:(NSString*)key;
- (void) removeHttpHeaderForKey:(NSString*)key;

- (void) registerMockResponse:(NSData*)response withRoute:(id)route withMethod:(NSUInteger)method;
- (void) unregisterMockResponseForRoute:(id)route withMethod:(NSUInteger)method;

- (void) addCachedResponse:(NSString*)route withData:(NSData*)data;
- (void) removeCachedResponse:(NSString*)route;
- (void) removeAllCachedResponses;

- (void) observeResponseStatus:(NSInteger)status withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) removeObserveResponseStatus:(NSInteger)status;

- (void) doMultipartPost:(NSString*)route andData:(NSData*)data withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doMultipartPost:(NSString*)route andDataArray:(NSArray*) dataArray withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doMultipartPost:(NSString*)route andDataDictionary:(NSDictionary*) dataDicts withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;

#pragma mark - Multipart requests
- (void) doMultipartPost:(NSString*)route andData:(NSData*)data withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doMultipartPost:(NSString*)route andDataArray:(NSArray*) dataArray withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doMultipartPost:(NSString*)route andDataDictionary:(NSDictionary*) dataDicts withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;

#pragma mark - Requests with JSON block
- (void) doGet:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doPost:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doPut:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doDelete:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;

#pragma mark - Requests with JSON block
- (void) doGet:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doPost:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doPut:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doDelete:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;
- (void) doRequest:(NSURLRequest*)request withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block;

#pragma mark - Requests with data block
- (void) doGet:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doPost:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doPut:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doDelete:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doRequest:(NSURLRequest*)request withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;

#pragma mark - Requests headers, params, and content type with data block
- (void) doGet:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doPost:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doPut:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;
- (void) doDelete:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentTypes withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block;

@end
