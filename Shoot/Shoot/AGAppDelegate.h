//
//  AGAppDelegate.h
//  Shoot
//
//  Created by Corinne Krych on 11/22/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AFOAuth1Client.h"
#import "AFJSONRequestOperation.h"

@interface AGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AFOAuth1Client *flickrClient;
@end
