//
//  AGAppDelegate.m
//  Shoot
//
//  Created by Corinne Krych on 11/22/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//
#import "AGAppDelegate.h"
#import "AGShootViewController.h"


@implementation AGAppDelegate
#warning ENTER YOUR FLICKR API_KEY
NSString* FLICKR_SAMPLE_API_KEY = @"b666b8c9c8b48098cae3bacbb135980a";
#warning ENTER YOUR FLICKR API_SHARED_SECRET
NSString* FLICKR_SAMPLE_API_SHARED_SECRET = @"ca4551d49068396b";


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.flickrClient = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.flickr.com/"] key:FLICKR_SAMPLE_API_KEY secret:FLICKR_SAMPLE_API_SHARED_SECRET];
    
    [self.flickrClient authorizeUsingOAuthWithRequestTokenPath:@"/services/oauth/request_token" userAuthorizationPath:@"/services/oauth/authorize" callbackURL:[NSURL URLWithString:@"shootnshare://auth"] accessTokenPath:@"/services/oauth/access_token" accessMethod:@"POST" scope:nil success:^(AFOAuth1Token *accessToken, id responseObject) {
        [self.flickrClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
         NSLog(@"Success: Logged");
//        [self.flickrClient getPath:@"/services/flickr.test.login" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSArray *responseArray = (NSArray *)responseObject;
//            [responseArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                NSLog(@"Success: %@", obj);
//            }];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:kAFApplicationLaunchOptionsURLKey]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    return YES;
}


@end
