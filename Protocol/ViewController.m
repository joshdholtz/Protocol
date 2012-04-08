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
    
    [[ProtocolManager sharedInstance] setBaseURL:@"http://kingofti.me"];
    
    [[ProtocolManager sharedInstance] setMockResponseOn:YES];
    [[ProtocolManager sharedInstance] registerMockResponse:[[[NSString alloc] initWithString:@"Josh Holtz, Bandit"] dataUsingEncoding:NSUTF8StringEncoding] withRoute:@"/member" withMethod:kProtocolRouteGET];
    [[ProtocolManager sharedInstance] registerMockResponse:[[[NSString alloc] initWithString:@"Josh Holtz"] dataUsingEncoding:NSUTF8StringEncoding] withRoute:[NSRegularExpression regularExpressionWithPattern:@"/member/(\\d+)?" options:NSRegularExpressionCaseInsensitive error:nil] withMethod:kProtocolRouteGET];
    
    [[ProtocolManager sharedInstance] doGet:@"/member" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
        
        NSLog(@"Member response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
    } ];
    
    [[ProtocolManager sharedInstance] doGet:@"/member/5" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, NSData *data){
    
        NSLog(@"Member 5 response - %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
    } ];
    
//    NSDictionary *loginDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"josh@rokkincat.com", @"email", @"test01", @"password", nil];
//    
//    [[Protocol sharedInstance] doPostAsJSON:@"/session" params:loginDict withBlock:^(NSURLResponse *response, NSUInteger status, id jsonData){
//        
//        NSLog(@"Status - %d", status);
//        Member *member = [[Member alloc] initWithDictionary:jsonData];
//        NSLog(@"Logged in member - %@", member.firstName);
//        
//        NSString *cookie = [[((NSHTTPURLResponse*) response) allHeaderFields] objectForKey:@"Set-Cookie"];
//        [[Protocol sharedInstance] addHttpHeader:cookie forKey:@"Cookie"];
//        
//        [[Protocol sharedInstance] doGetAsJSON:@"/session" params:nil withBlock:^(NSURLResponse *response, NSUInteger status, id jsonData){
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
