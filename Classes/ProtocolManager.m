//
//  Protocol.m
//  Protocol
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProtocolManager.h"

#import "ProtocolPersist.h"

#import <Foundation/NSJSONSerialization.h> 

@interface ProtocolManager()

@property (nonatomic, assign) int numberOfActiveRequsts;

@property (nonatomic, strong) NSMutableDictionary *mockResponsesGET;
@property (nonatomic, strong) NSMutableDictionary *mockResponsesPOST;
@property (nonatomic, strong) NSMutableDictionary *mockResponsesPUT;
@property (nonatomic, strong) NSMutableDictionary *mockResponsesDELETE;

@property (nonatomic, strong) NSMutableArray *cacheResponsesGET;
@property (nonatomic, strong) NSMutableArray *cacheResponsesPOST;
@property (nonatomic, strong) NSMutableArray *cacheResponsesPUT;
@property (nonatomic, strong) NSMutableArray *cacheResponsesDELETE;

@property (nonatomic, strong) NSMutableDictionary *cachedResponsesGET;

@property (nonatomic, strong) NSMutableDictionary *observedStatuses;

@property (nonatomic, strong) NSMutableDictionary *formatBlocks;

- (NSData *)findMockResponse:(NSString *)route withMockResponse:(NSDictionary*)actionMockResponses;

@end

@implementation ProtocolManager

@synthesize baseURL = _baseURL;
@synthesize httpHeaders = _httpHeaders;
@synthesize debug = _debug;

@synthesize networkActivityIndicatorVisible = _networkActivityIndicatorVisible;
@synthesize numberOfActiveRequsts = _numberOfRequsts;

@synthesize mockResponseOn = _mockResponseOn;
@synthesize mockResponsesGET = _mockResponsesGET;
@synthesize mockResponsesPOST = _mockResponsesPOST;
@synthesize mockResponsesPUT = _mockResponsesPUT;
@synthesize mockResponsesDELETE = _mockResponsesDELETE;

@synthesize cacheResponsesGET = _cacheResponsesGET;
@synthesize cacheResponsesPOST = _cacheResponsesPOST;
@synthesize cacheResponsesPUT = _cacheResponsesPUT;
@synthesize cacheResponsesDELETE = _cacheResponsesDELETE;

@synthesize cachedResponsesGET = _cachedResponsesGET;

@synthesize observedStatuses = _observedStatuses;

@synthesize formatBlocks = _formatBlocks;

@synthesize reachabilityActive = _reachabilityActive;

static ProtocolManager *sharedInstance = nil;

#pragma mark - Public Singleton

+ (ProtocolManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

#pragma mark - Private Singleton

- (id)init
{
    self = [super init];
    
    if (self) {
        
        _networkActivityIndicatorVisible = NO;
        _numberOfRequsts = 0;
        
        _httpHeaders = [[NSMutableDictionary alloc] init];
        _mockResponsesGET = [[NSMutableDictionary alloc] init];
        _mockResponsesPOST = [[NSMutableDictionary alloc] init];
        _mockResponsesPUT = [[NSMutableDictionary alloc] init];
        _mockResponsesDELETE = [[NSMutableDictionary alloc] init];
        
        _cachedResponsesGET = [[NSMutableDictionary alloc] init];
        
        _cacheResponsesGET = [NSMutableArray array];
        _cacheResponsesPOST = [NSMutableArray array];
        _cacheResponsesPUT = [NSMutableArray array];
        _cacheResponsesDELETE = [NSMutableArray array];
        
        _observedStatuses = [NSMutableDictionary dictionary];
        
        _formatBlocks = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - Headers

- (void)addHttpHeader:(NSString *)value forKey:(NSString *)key {
    if (value != nil && key != nil) {
        [_httpHeaders setObject:value forKey:key];
    }
}

- (void)removeHttpHeaderForKey:(NSString *)key {
    [_httpHeaders removeObjectForKey:key];
}

#pragma mark - Mock Responses

- (void)registerMockResponse:(NSData *)response withRoute:(id)route withMethod:(NSUInteger)method {
    
    switch (method) {
        case kProtocolRouteGET:
            [_mockResponsesGET setObject:response forKey:route];
            break;
        case kProtocolRoutePOST:
            [_mockResponsesPOST setObject:response forKey:route];
            break;
        case kProtocolRoutePUT:
            [_mockResponsesPUT setObject:response forKey:route];
            break;
        case kProtocolRouteDELETE:
            [_mockResponsesDELETE setObject:response forKey:route];
            break;
            
        default:
            break;
    }
    
}

- (void)unregisterMockResponseForRoute:(id)route withMethod:(NSUInteger)method {
    
    switch (method) {
        case kProtocolRouteGET:
            [_mockResponsesGET removeObjectForKey:route];
            break;
        case kProtocolRoutePOST:
            [_mockResponsesPOST removeObjectForKey:route];
            break;
        case kProtocolRoutePUT:
            [_mockResponsesPUT removeObjectForKey:route];
            break;
        case kProtocolRouteDELETE:
            [_mockResponsesDELETE removeObjectForKey:route];
            break;
            
        default:
            break;
    }

}

#pragma mark - Mock Responses

- (void)registerCacheResponse:(id)route withMethod:(NSUInteger)method {
    
    switch (method) {
        case kProtocolRouteGET:
            [_cacheResponsesGET addObject:route];
            break;
        case kProtocolRoutePOST:
            [_cacheResponsesPOST addObject:route];
            break;
        case kProtocolRoutePUT:
            [_cacheResponsesPUT addObject:route];
            break;
        case kProtocolRouteDELETE:
            [_cacheResponsesDELETE addObject:route];
            break;
            
        default:
            break;
    }
    
}

- (void)unregisterCacheResponseForRoute:(id)route withMethod:(NSUInteger)method {
    
    switch (method) {
        case kProtocolRouteGET:
            [_cacheResponsesGET removeObject:route];
            break;
        case kProtocolRoutePOST:
            [_cacheResponsesPOST removeObject:route];
            break;
        case kProtocolRoutePUT:
            [_cacheResponsesPUT removeObject:route];
            break;
        case kProtocolRouteDELETE:
            [_cacheResponsesDELETE removeObject:route];
            break;
            
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark Cached Responses

- (void) addCachedResponse:(NSString*)route withData:(NSData*)data {
    [_cachedResponsesGET setObject:data forKey:route];
}

- (void) removeCachedResponse:(NSString*)route {
    [_cachedResponsesGET removeObjectForKey:route];
}

- (void) removeAllCachedResponses {
    [_cachedResponsesGET removeAllObjects];
}

#pragma mark -
#pragma mark Observe Status

- (void) observeResponseStatus:(NSInteger)status withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    [_observedStatuses setObject:[block copy] forKey:[[NSNumber alloc] initWithInt:status]];
}

- (void) removeObserveResponseStatus:(NSInteger)status {
    [_observedStatuses removeObjectForKey:[[NSNumber alloc] initWithInt:status]];
}

#pragma mark -
#pragma mark Format Block

- (void)registerFormatBlock:(id (^)(NSString *))block forKey:(NSString *)key {
    [_formatBlocks setObject:[block copy] forKey:key];
}

- (id) performFormatBlock:(NSString*)value withKey:(NSString*)key {
    id(^block)(NSString *);
    block = [_formatBlocks objectForKey:key];
    if (block != nil) {
        return block(value);
    } else {
        return nil;
    }
}

#pragma mark -
#pragma mark Send Multipart Requests For JSON

- (void) doMultipartPost:(NSString*)route andData:(NSData*)data withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id json))block {
    
    // Calls doMultipartPost, parses JSON, and calls JSON block
    [self doMultipartPost:route andData:data withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        block(response, status, jsonData);
    } ];
    
}

- (void) doMultipartPost:(NSString*)route andDataArray:(NSArray*)dataArray withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id json))block {
    
    // Calls doMultipartPost, parses JSON, and calls JSON block
    [self doMultipartPost:route andDataArray:dataArray withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        block(response, status, jsonData);
    } ];
    
}

- (void) doMultipartPost:(NSString*)route andDataDictionary:(NSDictionary*) dataDicts withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id json))block {
    
    // Calls doMultipartPost, parses JSON, and calls JSON block
    [self doMultipartPost:route andDataDictionary:dataDicts withJSONBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        block(response, status, jsonData);
    } ];
    
}

#pragma mark - 
#pragma mark Send Multipart Requests

- (void) doMultipartPost:(NSString*)route andData:(NSData*)data withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    // Puts a data into an array
    [self doMultipartPost:route andDataArray:[[NSArray alloc] initWithObjects:data, nil] withBlock:block];
}

- (void) doMultipartPost:(NSString*)route andDataArray:(NSArray*)dataArray withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
    // Puts an array of data into a dictionary
    NSMutableArray *dataNames = [[NSMutableArray alloc] initWithCapacity:[dataArray count]];
    for(int i = 0; i < [dataArray count]; i++) {
        [dataNames addObject:[[NSString alloc] initWithFormat:@"file%d", i]];
    }
 
    [self doMultipartPost:route andDataDictionary:[[NSDictionary alloc] initWithObjects:dataArray forKeys:dataNames]  withBlock:block];
}

- (void) doMultipartPost:(NSString*)route andDataDictionary:(NSDictionary*) dataDicts withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
    // Builds request
    NSMutableURLRequest *mutipartPostRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self fullRoute:route]]];
    [mutipartPostRequest setAllHTTPHeaderFields:_httpHeaders];
    [mutipartPostRequest setHTTPMethod:@"POST"];
    
    /*
     * Sets post boundaries
     */
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [mutipartPostRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSArray *keys = [dataDicts allKeys];
    for(int i = 0; i < [keys count]; i++) {
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file%d\"; filename=\"%@\"\r\n", i, [keys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[dataDicts objectForKey:[keys objectAtIndex:i]]];
        
        if (i != ([keys count] - 1)) {
            [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
    }
    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [mutipartPostRequest setHTTPBody:postbody];
    
    // Sends request asynchronous
    [self sendAsynchronousRequest:mutipartPostRequest withBlock:block];
}

#pragma mark - 
#pragma mark Send Requests For JSON

- (void) doGet:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    [self doGet:route headers:nil params:params contentType:kProtocolContentTypeFormData withJSONBlock:block];
}

- (void) doPost:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    [self doPost:route headers:nil params:params contentType:kProtocolContentTypeFormData withJSONBlock:block];
}

- (void) doPut:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    [self doPut:route headers:nil params:params contentType:kProtocolContentTypeFormData withJSONBlock:block];
}

- (void) doDelete:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    [self doDelete:route headers:nil params:params contentType:kProtocolContentTypeFormData withJSONBlock:block];
}


#pragma mark - 
#pragma mark Send Requests For JSON - headers, params, content type
- (void) doGet:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    // Calls doGet, parses JSON, and calls JSON block
    [self doGet:route headers:headers params:params contentType:contentType withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        id jsonData = nil;
        if (data != nil) {
            jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        
        block(response, status, jsonData);
        
    }];
    
}

- (void) doPost:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    // Calls doPost, parses JSON, and calls JSON block
    [self doPost:route  headers:headers params:params contentType:contentType withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        id jsonData = nil;
        if (data != nil) {
            jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        
        block(response, status, jsonData);
        
    }];
    
}

- (void) doPut:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    // Calls doPost, parses JSON, and calls JSON block
    [self doPut:route  headers:headers params:params contentType:contentType withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        id jsonData = nil;
        if (data != nil) {
            jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        
        block(response, status, jsonData);
        
    }];
    
}

- (void) doDelete:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    // Calls doDelete, parses JSON, and calls JSON block
    [self doDelete:route  headers:headers params:params contentType:contentType withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        id jsonData = nil;
        if (data != nil) {
            jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        
        block(response, status, jsonData);
        
    }];
    
}

- (void) doRequest:(NSURLRequest*)request withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    [self doRequest:request withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {
        
        id jsonData = nil;
        if (data != nil) {
            jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        
        block(response, status, jsonData);
        
    }];
    
}

#pragma mark - 

#pragma mark Send Requests

- (void) doGet:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    [self doGet:route headers:nil params:params contentType:kProtocolContentTypeFormData withBlock:block];
}

- (void) doPost:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    [self doPost:route headers:nil params:params contentType:kProtocolContentTypeFormData withBlock:block];
}

- (void) doPut:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    [self doPut:route headers:nil params:params contentType:kProtocolContentTypeFormData withBlock:block];
}

- (void) doDelete:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    [self doDelete:route headers:nil params:params contentType:kProtocolContentTypeFormData withBlock:block];
}


#pragma mark - 

#pragma mark Send Requests - headers, params, content type

- (void) doGet:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
    if (_mockResponseOn) {
        
        NSData *mockResponse = [self findMockResponse:route withMockResponse:_mockResponsesGET];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, 200, mockResponse);
        });
        
    } else {
        
        if ([_cachedResponsesGET objectForKey:route]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil, 200, [_cachedResponsesGET objectForKey:route]);
            });
            
        } else {
            
            // Add query params to url
            if (params != nil && [params count] > 0) {
                route = [NSString stringWithFormat:@"%@?%@", route, [self dictToQueryString:params]];
            }
            
            NSData *cachedResponse = [self findCachedResponse:route withMockResponse:_cacheResponsesGET];
            if (cachedResponse != nil) {
                block(nil, 200, cachedResponse);
            }
            
            // Organizes headers
            NSMutableDictionary *allHeaders = [[NSMutableDictionary alloc] init];
            [allHeaders addEntriesFromDictionary:_httpHeaders];
            [allHeaders addEntriesFromDictionary:headers];
    
            // Builds request
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setAllHTTPHeaderFields:allHeaders];
            [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
            [request setHTTPMethod:@"GET"];
            [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            // Sends request asynchronous
            [self sendAsynchronousRequest:request withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {
                
                NSLog(@"STATUS THAT WE GOT - %d", status);
                
                if ([data length] > 0 && [self shouldCacheResponse:route withMockResponse:_cacheResponsesGET]) {
                    [[ProtocolPersist sharedInstance] saveRouteCache:route data:data];
                }
                
                block(response, status, data);
            }];
            
        }
        
    }
    
}

- (void) doPost:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
    if (_mockResponseOn) {
        
        NSData *mockResponse = [self findMockResponse:route withMockResponse:_mockResponsesPOST];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, 200, mockResponse);
        });
        
    } else {
        
        // Organizes headers
        NSMutableDictionary *allHeaders = [[NSMutableDictionary alloc] init];
        [allHeaders addEntriesFromDictionary:_httpHeaders];
        [allHeaders addEntriesFromDictionary:headers];
    
        // Creates body
        NSData *body = nil;
        if ([kProtocolContentTypeFormData isEqualToString:contentType]) {
            body = [[self dictToQueryString:params] dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            body = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        }
        
        // Gets body length
        NSString *contentLengthStr = [NSString stringWithFormat:@"%d", [body length]];
        
        NSLog(@"Route - %@", route);
        NSLog(@"Full Route - %@", [self fullRoute:route]);
        
        // Builds request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:allHeaders];
        [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        [request addValue:contentLengthStr forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:body];
        
        // Sends request asynchronous
        [self sendAsynchronousRequest:request withBlock:block];
        
    }
}

- (void) doPut:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
    if (_mockResponseOn) {
        
        NSData *mockResponse = [self findMockResponse:route withMockResponse:_mockResponsesPUT];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, 200, mockResponse);
        });
        
    } else {
        
        // Organizes headers
        NSMutableDictionary *allHeaders = [[NSMutableDictionary alloc] init];
        [allHeaders addEntriesFromDictionary:_httpHeaders];
        [allHeaders addEntriesFromDictionary:headers];
        
        // Creates body
        NSData *body = nil;
        if ([kProtocolContentTypeFormData isEqualToString:contentType]) {
            body = [[self dictToQueryString:params] dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            body = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        }
        
        // Gets body length
        NSString *contentLengthStr = [NSString stringWithFormat:@"%d", [body length]];
        
        // Builds request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:allHeaders];
        [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
        [request setHTTPMethod:@"PUT"];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        [request addValue:contentLengthStr forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:body];
        
        // Sends request asynchronous
        [self sendAsynchronousRequest:request withBlock:block];
        
    }
    
}

- (void) doDelete:(NSString*)route headers:(NSDictionary*)headers params:(NSDictionary*)params contentType:(NSString*)contentType withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
    if (_mockResponseOn) {
        
        NSData *mockResponse = [self findMockResponse:route withMockResponse:_mockResponsesDELETE];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, 200, mockResponse);
        });
        
    } else {
        
        // Add query params to url
        if (params != nil && [params count] > 0) {
            route = [NSString stringWithFormat:@"%@?%@", route, [self dictToQueryString:params]];
        }
        
        // Organizes headers
        NSMutableDictionary *allHeaders = [[NSMutableDictionary alloc] init];
        [allHeaders addEntriesFromDictionary:_httpHeaders];
        [allHeaders addEntriesFromDictionary:headers];
    
        // Builds request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:allHeaders];
        [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
        [request setHTTPMethod:@"DELETE"];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        // Sends request asynchronous
        [self sendAsynchronousRequest:request withBlock:block];
        
    }
    
}

- (void) doRequest:(NSURLRequest*)request withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {

    // Sends request asynchronous
    [self sendAsynchronousRequest:request withBlock:block];
    
}

#pragma mark - Private

- (void) sendAsynchronousRequest:(NSURLRequest*)request withBlock: (void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    [self requestNetworkActivityIndicator];
    
    if (_debug) {
        NSLog(@"%@ - %@", [request HTTPMethod], [[request URL] absoluteString]);
    }
    
    // Captures response
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [self releaseNetworkActivityIndicator];
        
        NSLog(@"Response object - %@", response);
        NSLog(@"Eror - %@", error);
        
        int status = [((NSHTTPURLResponse*) response) statusCode];
        if (NSURLErrorUserCancelledAuthentication == [error code]) {
            status = 401;
        }
        
        if (_debug) {
            NSLog(@"%d - %@", status, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([_observedStatuses objectForKey:[[NSNumber alloc] initWithInt:status]]) {
                
                void(^statusBlock)(NSURLResponse *response, NSUInteger status, NSData* data);
                statusBlock = [_observedStatuses objectForKey:[[NSNumber alloc] initWithInt:status]];
                statusBlock(response, status, data);
                
                block(response, status, data);
            } else {
                block(response, status, data);
            }
            
        });
        
        
    }];
    
}

- (NSString*)fullRoute:(NSString*)route {
    if (_baseURL == nil || [route hasPrefix:@"http"]) {
        return route;
    } else {
        return [[NSString alloc] initWithFormat:@"%@%@", _baseURL, route];
    }
}

- (NSString *)dictToQueryString:(NSDictionary*)dict {
    NSMutableString *queryString = nil;
    NSArray *keys = [dict allKeys];
    
    if ([keys count] > 0) {
        for (id key in keys) {
            id value = [dict objectForKey:key];
            if (nil == queryString) {
                queryString = [[NSMutableString alloc] init];
            } else {
                [queryString appendFormat:@"&"];
            }
            
            if (nil != key && nil != value) {
                [queryString appendFormat:@"%@=%@", [self escapeString:key], [self escapeString:value]];
            } else if (nil != key) {
                [queryString appendFormat:@"%@", [self escapeString:key]];
            }
        }
    }
    
    return queryString;
}

- (NSString*) escapeString:(NSString*)string 
{
    NSString *s = string;
    if ([string isKindOfClass:[NSString class]]) {
        s = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                               (__bridge CFStringRef)string,
                                                                               NULL,
                                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                               kCFStringEncodingUTF8);
    }
    return s;
}

- (NSData *)findMockResponse:(NSString *)route withMockResponse:(NSDictionary*)actionMockResponses {
    
    if ([actionMockResponses objectForKey:route]) {
        
        return [actionMockResponses objectForKey:route];
        
    } else {
    
        for (id key in [actionMockResponses allKeys]) {
            
            if ([key isKindOfClass:[NSRegularExpression class]]) {
                NSRange rangeOfFirstMatch = [key rangeOfFirstMatchInString:route options:0 range:NSMakeRange(0, [route length])];
                if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                    return [actionMockResponses objectForKey:key];
                }
            }
            
        }
        
    }
    
    return nil;
    
}

- (BOOL)shouldCacheResponse:(NSString *)route withMockResponse:(NSArray*)actionCacheResponses {
    
    for (id key in actionCacheResponses) {
        
        NSLog(@"Key - %@, Route - %@", key, route);
        
        if ([key isKindOfClass:[NSRegularExpression class]]) {
            NSRange rangeOfFirstMatch = [key rangeOfFirstMatchInString:route options:0 range:NSMakeRange(0, [route length])];
            if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                NSLog(@"We found a registered route");
                return YES;
            }
        } else if ([key isKindOfClass:[NSString class]]) {
            if ([((NSString*)key) isEqualToString:route]) {
                NSLog(@"We found a registered route");
                return YES;
            }
        }
        
    }
    
    return NO;
}

- (NSData*)findCachedResponse:(NSString *)route withMockResponse:(NSArray*)actionCacheResponses {
        
    if ([self shouldCacheResponse:route withMockResponse:actionCacheResponses]) {
        return [[ProtocolPersist sharedInstance] getRouteCache:route];
    }
    
    return nil;
}

- (void)requestNetworkActivityIndicator {
    if ([self networkActivityIndicatorVisible]) {
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
    }
    
    self.numberOfActiveRequsts++;
}

- (void)releaseNetworkActivityIndicator {
    self.numberOfActiveRequsts--;
	if(self.numberOfActiveRequsts <= 0) {
		UIApplication* app = [UIApplication sharedApplication];
		app.networkActivityIndicatorVisible = NO;
	}
    
	if (self.numberOfActiveRequsts < 0) {
		self.numberOfActiveRequsts = 0;
    }
}

@end
