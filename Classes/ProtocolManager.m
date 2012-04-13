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

- (NSMutableURLRequest *) multipartRequestWithURL:(NSString*)route andDataDictionary:(NSData *) data
{
    // Create POST request
    NSMutableURLRequest *mutipartPostRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self fullRoute:route]]];
    [mutipartPostRequest setAllHTTPHeaderFields:_httpHeaders];
    [mutipartPostRequest setHTTPMethod:@"POST"];
    
    // Add HTTP header info
    // Note: POST boundaries are described here: http://www.vivtek.com/rfc1867.html
    // and here http://www.w3.org/TR/html4/interact/forms.html
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [mutipartPostRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@.jpg\"\r\n", @"thing"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:data]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [mutipartPostRequest setHTTPBody:postbody];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:mutipartPostRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"HERE");
        if (error == nil) {
            if (data == nil) {
                NSLog(@"Data is nil");
            } else {
                NSLog(@"Data length - %d", [data length] );
            }
            
            NSLog(@"Woot@ - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        } else {
            NSLog(@"Error - %@", error);
        }
        
    }];
    
    return mutipartPostRequest;
}

-(NSURLRequest *)doMulitpartPost:(NSString*)route params:(NSDictionary*)params withData:(NSData *)data
{
	//create the URL POST Request to tumblr
	NSURL *tumblrURL = [NSURL URLWithString:[self fullRoute:route]];
	NSMutableURLRequest *tumblrPost = [NSMutableURLRequest requestWithURL:tumblrURL];
    [tumblrPost setAllHTTPHeaderFields:_httpHeaders];
	[tumblrPost setHTTPMethod:@"POST"];
	
	//Add the header info
	NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[tumblrPost addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
//	//add key values from the NSDictionary object
//	NSEnumerator *keys = [params keyEnumerator];
//	int i;
//	for (i = 0; i < [params count]; i++) {
//		NSString *tempKey = [keys nextObject];
//		[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",tempKey] dataUsingEncoding:NSUTF8StringEncoding]];
//		[postBody appendData:[[NSString stringWithFormat:@"%@",[params objectForKey:tempKey]] dataUsingEncoding:NSUTF8StringEncoding]];
//		[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
//	}
    
	//add data field and file data
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"files\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[NSData dataWithData:data]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//add the body to the post
	[tumblrPost setHTTPBody:postBody];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:tumblrPost queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"HERE");
        if (error == nil) {
            if (data == nil) {
                NSLog(@"Data is nil");
            } else {
                NSLog(@"Data length - %d", [data length] );
            }
            
            NSLog(@"Woot@ - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        } else {
            NSLog(@"Error - %@", error);
        }
        
    }];
    
	return tumblrPost;
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
