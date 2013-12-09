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
