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
#import "Pet.h"

#import "Reachability.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[ProtocolManager sharedInstance] setBaseURL:@"http://joshdholtz.com"];
    
    // Using mock response just because I don't have to set up a web request
    NSString *response = @"{\"id\":1, \"first_name\":\"Josh\", \"last_name\":\"Josh\", \"birthday\":\"1989-03-01\", \"pet\": {\"id\":1, \"name\":\"Bandit\", \"kind\":\"cat\"} }";
    [[ProtocolManager sharedInstance] registerMockResponse:[response dataUsingEncoding:NSUTF8StringEncoding] withRoute:@"http://joshdholtz.com/member/1" withMethod:kProtocolRouteGET];
    [[ProtocolManager sharedInstance] setMockResponseOn:YES];
    
    // Registers a function for the model inflations to call - Ex: Look in Member.m for the Date: fuction prefix
    [[ProtocolManager sharedInstance] registerFormatBlock:^id(NSString *jsonValue) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd"];

        NSDate *date = [dateFormatter dateFromString:jsonValue];
        
        return date;
    } forKey:@"Date"];
    
    [[ProtocolManager sharedInstance] doGet:@"http://joshdholtz.com/member/1" params:nil withJSONBlock:^(NSURLResponse *response, NSUInteger status, id jsonData) {
        
        Member *member = [[Member alloc] initWithDictionary:jsonData];
        NSLog(@"%@ %@ %@ %@", [member memberId], [member firstName], [member lastName], [member birthday]);
        NSLog(@"Pet - %@ %@ %@", [[member pet] petId], [[member pet] name], [[member pet] kind]);
        
    }];
        
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
