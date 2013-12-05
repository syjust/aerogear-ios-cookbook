//
//  AGAppDelegate.h
//  Shoot
//
//  Created by Corinne Krych on 11/22/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ObjectiveFlickr.h"

@interface AGAppDelegate : UIResponder <UIApplicationDelegate, OFFlickrAPIRequestDelegate> {
    OFFlickrAPIContext *flickrContext;
	OFFlickrAPIRequest *flickrRequest;
	NSString *flickrUserName;
}
+ (AGAppDelegate *)sharedDelegate;
- (void)setAndStoreFlickrAuthToken:(NSString *)inAuthToken secret:(NSString *)inSecret;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) OFFlickrAPIContext *flickrContext;
@property (nonatomic, retain) NSString *flickrUserName;
@end
extern NSString *SRCallbackURLBaseString;