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
    
    // Captures response
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:mutipartPostRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            int status = [((NSHTTPURLResponse*) response) statusCode];
            block(response, status, data);
        });
        
    }];
}

#pragma mark - 
#pragma mark Send Requests For JSON
- (void) doGet:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    // Calls doGet, parses JSON, and calls JSON block
    [self doGet:route params:params withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        block(response, status, jsonData);
        
    }];
    
}

- (void) doPost:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    // Calls doPost, parses JSON, and calls JSON block
    [self doPost:route params:params withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        block(response, status, jsonData);
        
    }];
    
}

- (void) doPut:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    // Calls doPost, parses JSON, and calls JSON block
    [self doPut:route params:params withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
        block(response, status, jsonData);
        
    }];
    
}

- (void) doDelete:(NSString*)route params:(NSDictionary*)params withJSONBlock:(void(^)(NSURLResponse *response, NSUInteger status, id jsonData))block {
    
    // Calls doDelete, parses JSON, and calls JSON block
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
    
        // Builds request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:_httpHeaders];
        [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
        [request setHTTPMethod:@"GET"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        // Captures response
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
        
        // Builds request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:_httpHeaders];
        [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
        [request addValue:contentLengthStr forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:[queryStr dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        // Captures response
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
        
        // Builds request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:_httpHeaders];
        [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
        [request setHTTPMethod:@"PUT"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
        [request addValue:contentLengthStr forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:[queryStr dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        // Captures response
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
    
        // Builds request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setAllHTTPHeaderFields:_httpHeaders];
        [request setURL:[NSURL URLWithString:[self fullRoute:route]]];
        [request setHTTPMethod:@"DELETE"];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        // Captures response
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
