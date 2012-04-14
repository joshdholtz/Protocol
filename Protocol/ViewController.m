//
//  ViewController.m
//  RestCat
//
//  Created by Josh Holtz on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "ProtocolManager.h"
#import "Member.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    [[ProtocolManager sharedInstance] setBaseURL:@"http://kingofti.me"];
//    [[ProtocolManager sharedInstance] setBaseURL:@"http://192.168.1.7"];
//    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"me_coding" ofType:@"jpg"];  
//    NSData *data = [NSData dataWithContentsOfFile:filePath];
//    if (data) {
//        NSLog(@"Data length - %d", [data length]);
//        
//        [[ProtocolManager sharedInstance] multipartRequestWithURL:@"/fileupload.php" andDataArray:[[NSArray alloc] initWithObjects:data, data, nil]];
//    }
    
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
//    [[ProtocolManager sharedInstance] registerMockResponse:[[[NSString alloc] initWithString:@"Josh Holtz, Bandit"] dataUsingEncoding:NSUTF8StringEncoding] withRoute:@"/member" withMethod:kProtocolRouteGET];
//    [[ProtocolManager sharedInstance] registerMockResponse:[[[NSString alloc] initWithString:@"Josh Holtz"] dataUsingEncoding:NSUTF8StringEncoding] withRoute:[NSRegularExpression regularExpressionWithPattern:@"/member/(\\d+)?" options:NSRegularExpressionCaseInsensitive error:nil] withMethod:kProtocolRouteGET];
    
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
