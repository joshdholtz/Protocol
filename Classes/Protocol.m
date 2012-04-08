//
//  Protocol.m
//  Protocol
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Protocol.h"

#import <Foundation/NSJSONSerialization.h> 

@implementation Protocol

@synthesize baseURL = _baseURL;
@synthesize httpHeaders = _httpHeaders;

static Protocol *sharedInstance = nil;

#pragma mark - Public Singleton

+ (Protocol *)sharedInstance {
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

- (void) doPost:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
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

- (void) doPut:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
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

- (void) doDelete:(NSString*)route params:(NSDictionary*)params withBlock:(void(^)(NSURLResponse *response, NSUInteger status, NSData* data))block {
    
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

@end
