//
//  ViewController.m
//  RestCat
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "ProtocolManager.h"
#import "ProtocolPersist.h"
#import "Member.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[ProtocolManager sharedInstance] setBaseURL:@"http://192.168.1.7"];
    
//    [[ProtocolManager sharedInstance] doGet:@"/protocol.php?example=member_1" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {
//        
//        NSLog(@"Member response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        
//        
//    }];
//    
    // Gets a JSON member object
//    [[ProtocolManager sharedInstance] doGet:@"/protocol.php?example=member_1" params:nil withJSONBlock:^(NSURLResponse *response, NSUInteger status, id json) {
//        
//        if ([json isKindOfClass:[NSDictionary class]]) {
//            NSLog(@"Member response as dictionary - %@", json);
//        }
//        
//    }];
//    
    // Gets a JSON member object
    [[ProtocolManager sharedInstance] doGet:@"/protocol.php?example=member_1" params:nil withJSONBlock:^(NSURLResponse *response, NSUInteger status, id json) {
        
        if ([json isKindOfClass:[NSDictionary class]]) {
            Member *member = [[Member alloc] initWithDictionary:json];
            NSLog(@"Member - %d %@ %@", member.memberId, member.firstName, member.lastName);
            
            [[ProtocolPersist sharedInstance] save:member];
            
            [[ProtocolPersist sharedInstance] get:[Member class]];
        }
        
    }];
    
//    Member *member = [[Member alloc] init];
//    [member setFirstName:@"Bandit"];
//    [member setLastName:@"TheCat"];
//    [[ProtocolPersist sharedInstance] save:member];
//    
//    [[ProtocolPersist sharedInstance] get:[Member class]];
    
//    
//    // Gets a JSON array of member objects
//    [[ProtocolManager sharedInstance] doGet:@"/protocol.php?example=members" params:nil withJSONBlock:^(NSURLResponse *response, NSUInteger status, id json) {
//        
//        if ([json isKindOfClass:[NSArray class]]) {
//            NSArray *members = [Member createWithArray:json];
//            for (Member *member in members) {
//                NSLog(@"Member in members - %@ %@", member.firstName, member.lastName);
//            }
//        }
//        
//    }];
    
//    [[ProtocolManager sharedInstance] setBaseURL:@"http://192.168.1.7"];
//    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"me_coding" ofType:@"jpg"];  
//    NSData *data = [NSData dataWithContentsOfFile:filePath];
//    if (data) {
//        NSLog(@"Data length - %d", [data length]);
//        
//        [[ProtocolManager sharedInstance] doMultipartPost:@"upload.php" andData:data withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {
//            if (status == 200) {
//                NSLog(@"File upload was successful");
//            }
//        }];
//    }
    
//    [[ProtocolManager sharedInstance] setNetworkActivityIndicatorVisible:NO];
//    
//    [[ProtocolManager sharedInstance] doGet:@"http://www.housecatscentral.com/cat1.jpg" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {
//       
//        if (status == 200) {
//            NSLog(@"Got it - %d", [data length]);
//            [[ProtocolManager sharedInstance] addCachedResponse:@"http://www.housecatscentral.com/cat1.jpg" withData:data];
//            
//            [[ProtocolManager sharedInstance] doGet:@"http://www.housecatscentral.com/cat1.jpg" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {
//                
//                if (status == 200) {
//                    NSLog(@"Got it again - %d", [data length]);
//                    [[ProtocolManager sharedInstance] removeCachedResponse:@"http://www.housecatscentral.com/cat1.jpg"];
//                    [[ProtocolManager sharedInstance] removeAllCachedResponses];
//                    
//                    [[ProtocolManager sharedInstance] doGet:@"http://www.housecatscentral.com/cat1.jpg" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data) {
//                        
//                        if (status == 200) {
//                            NSLog(@"Got it again again - %d", [data length]);
//                            
//                            
//                        }
//                        
//                    }];
//                    
//                }
//                
//            }];
//            
//        }
//        
//    }];
    
//    [[ProtocolManager sharedInstance] setMockResponseOn:YES];
//    
//    [[ProtocolManager sharedInstance] registerMockResponse:[[[NSString alloc] initWithString:@"[{\"first_name\":\"Josh\",\"last_name\":\"Holtz\"},{\"first_name\":\"Joshua\",\"last_name\":\"Holtz\"},{\"first_name\":\"Jossshhhhhh\",\"last_name\":\"Holtz\"}]"] dataUsingEncoding:NSUTF8StringEncoding] withRoute:@"/members" withMethod:kProtocolRouteGET];
//    
//    [[ProtocolManager sharedInstance] registerMockResponse:[[[NSString alloc] initWithString:@"{\"first_name\":\"Josh\",\"last_name\":\"Holtz\"}"] dataUsingEncoding:NSUTF8StringEncoding] withRoute:[NSRegularExpression regularExpressionWithPattern:@"/member/(\\d+)?" options:NSRegularExpressionCaseInsensitive error:nil] withMethod:kProtocolRouteGET];
//    
//    // Gets a JSON member object
//    [[ProtocolManager sharedInstance] doGet:@"/member/4" params:nil withJSONBlock:^(NSURLResponse *response, NSUInteger status, id json) {
//        
//        if ([json isKindOfClass:[NSDictionary class]]) {
//            Member *member = [[Member alloc] initWithDictionary:json];
//            NSLog(@"Member - %@ %@", member.firstName, member.lastName);
//        }
//        
//    }];
//    
//    // Gets a JSON array of member objects
//    [[ProtocolManager sharedInstance] doGet:@"/members" params:nil withJSONBlock:^(NSURLResponse *response, NSUInteger status, id json) {
//        
//        if ([json isKindOfClass:[NSArray class]]) {
//            NSArray *members = [Member createWithArray:json];
//            for (Member *member in members) {
//                NSLog(@"Member in members - %@ %@", member.firstName, member.lastName);
//            }
//        }
//        
//    }];
    
//    [[ProtocolManager sharedInstance] doGet:@"/member" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
//        
//        NSLog(@"Member response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        
//    } ];
//    
//    [[ProtocolManager sharedInstance] doGet:@"/member/5" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
//    
//        NSLog(@"Member 5 response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        
//    } ];
    
//    NSDictionary *loginDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"josh@rokkincat.com", @"email", @"test01", @"password", nil];
//    
//    [[ProtocolManager sharedInstance] doPost:@"/session" params:loginDict withJSONBlock:^(NSURLResponse *response, NSUInteger status, id jsonData){
//        
//        NSLog(@"Status - %d", status);
//        Member *member = [[Member alloc] initWithDictionary:jsonData];
//        NSLog(@"Logged in member - %@", member.firstName);
//        
//        NSString *cookie = [[((NSHTTPURLResponse*) response) allHeaderFields] objectForKey:@"Set-Cookie"];
//        [[ProtocolManager sharedInstance] addHttpHeader:cookie forKey:@"Cookie"];
//        
//        UIImage *image = [UIImage imageNamed:@"me_coding.jpg"];
//        NSData *data = UIImageJPEGRepresentation(image, .9);
//        [[ProtocolManager sharedInstance] multipartRequestWithURL:@"/file" andDataArray:[[NSArray alloc] initWithObjects:data, data, nil] withBlock:^(NSURLResponse *response, NSUInteger status, id jsonData){
//            
//            if ([jsonData isKindOfClass:[NSDictionary class]]) {
//                Member *member = [[Member alloc] initWithDictionary:jsonData];
//                NSLog(@"Logged in member (from session) - %@", [member firstName]);
//            }
//        } ];
        
//        [[ProtocolManager sharedInstance] doGetAsJSON:@"/session" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, id jsonData){
//            
//            if ([jsonData isKindOfClass:[NSDictionary class]]) {
//                Member *member = [[Member alloc] initWithDictionary:jsonData];
//                NSLog(@"Logged in member (from session) - %@", [member firstName]);
//            }
//        } ];
//
//        
//    } ];
    
//    [[RestCat sharedInstance] doGet:@"/member" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
//        
//    } ];
    
//    [[RestCat sharedInstance] doGetAsJSON:@"/member/2" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, id jsonData){
//        
//        if ([jsonData isKindOfClass:[NSDictionary class]]) {
//            Member *member = [[Member alloc] initWithDictionary:jsonData];
//            NSLog(@"First Name - %@", [member firstName]);
//        }
//    } ];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
