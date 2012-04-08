//
//  Protocol.m
//  Protocol
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProtocolManager.h"

#import <Foundation/NSJSONSerialization.h> 

@interface ProtocolManager()

@property (nonatomic, strong) NSMutableDictionary *mockResponsesGET;
@property (nonatomic, strong) NSMutableDictionary *mockResponsesPOST;
@property (nonatomic, strong) NSMutableDictionary *mockResponsesPUT;
@property (nonatomic, strong) NSMutableDictionary *mockResponsesDELETE;

- (NSData *)findMockResponse:(NSString *)route withMockResponse:(NSDictionary*)actionMockResponses;

@end

@implementation ProtocolManager

@synthesize baseURL = _baseURL;
@synthesize httpHeaders = _httpHeaders;

@synthesize mockResponseOn = _mockResponseOn;
@synthesize mockResponsesGET = _mockResponsesGET;
@synthesize mockResponsesPOST = _mockResponsesPOST;
@synthesize mockResponsesPUT = _mockResponsesPUT;
@synthesize mockResponsesDELETE = _mockResponsesDELETE;

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
        _httpHeaders = [[NSMutableDictionary alloc] init];
        _mockResponsesGET = [[NSMutableDictionary alloc] init];
        _mockResponsesPOST = [[NSMutableDictionary alloc] init];
        _mockResponsesPUT = [[NSMutableDictionary alloc] init];
        _mockResponsesDELETE = [[NSMutableDictionary alloc] init];
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

#pragma mark - 
#pragma mark Send Requests For JSON
- (void) doGetAsJSON:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    
    [self doGet:route params:params withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        block(response, status, jsonData);
        
    }];
    
}

- (void) doPostAsJSON:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    [self doPost:route params:params withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        block(response, status, jsonData);
        
    }];
    
}

- (void) doPutAsJSON:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    [self doPut:route params:params withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        block(response, status, jsonData);
        
    }];
    
}

- (void) doDeleteAsJSON:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    [self doDelete:route params:params withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        block(response, status, jsonData);
        
    }];
    
}

#pragma mark - 

#pragma mark Send Requests
- (void) doGet:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
    if (_mockResponseOn) {
        
        NSData *mockResponse = [self findMockResponse:route withMockResponse:_mockResponsesGET];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, 200, mockResponse);
        });
        
    } else {
    
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:_httpHeaders];
        [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
        [request setHTTPMethod:@"GET"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        //Capturing server response
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                int status = [((NSHTTPURLResponse*) response) statusCode];
                block(response, status, data);
            });
            
        }];
        
    }
    
}

- (void) doPost:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
    if (_mockResponseOn) {
        
        NSData *mockResponse = [self findMockResponse:route withMockResponse:_mockResponsesPOST];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, 200, mockResponse);
        });
        
    } else {
    
        NSString *queryStr = [self dictToQueryString:params];
        NSString *contentLengthStr = [NSString stringWithFormat:@"%d", [queryStr length]];
        
        
        NSLog(@"Query - %@", queryStr);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:_httpHeaders];
        [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
        [request addValue:contentLengthStr forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:[queryStr dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        //Capturing server response
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                int status = [((NSHTTPURLResponse*) response) statusCode];
                block(response, status, data);
            });
            
        }];
        
    }
}

- (void) doPut:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
    if (_mockResponseOn) {
        
        NSData *mockResponse = [self findMockResponse:route withMockResponse:_mockResponsesPUT];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, 200, mockResponse);
        });
        
    } else {
    
        NSString *queryStr = [self dictToQueryString:params];
        NSString *contentLengthStr = [NSString stringWithFormat:@"%d", [queryStr length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:_httpHeaders];
        [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
        [request setHTTPMethod:@"PUT"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
        [request addValue:contentLengthStr forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:[queryStr dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        //Capturing server response
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                int status = [((NSHTTPURLResponse*) response) statusCode];
                block(response, status, data);
            });
            
        }];
        
    }
    
}

- (void) doDelete:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
    if (_mockResponseOn) {
        
        NSData *mockResponse = [self findMockResponse:route withMockResponse:_mockResponsesDELETE];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, 200, mockResponse);
        });
        
    } else {
    
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:_httpHeaders];
        [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
        [request setHTTPMethod:@"DELETE"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        //Capturing server response
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                int status = [((NSHTTPURLResponse*) response) statusCode];
                block(response, status, data);
            });
            
        }];
        
    }
    
}

#pragma mark - Private

- (NSString*)fullRoute:(NSString*)route {
    return [[NSString alloc] initWithFormat:@"%@%@", _baseURL, route];
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
    NSString *s = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                               (__bridge CFStringRef)string,
                                                                               NULL,
                                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                               kCFStringEncodingUTF8);
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

@end
