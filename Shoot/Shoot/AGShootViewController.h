//
//  AGViewController.h
//  Shoot
//
//  Created by Corinne Krych on 11/22/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ObjectiveFlickr.h"

@interface AGShootViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, OFFlickrAPIRequestDelegate>

@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;
- (IBAction)share:(id)sender;

// OAuth step
- (IBAction)didPressLink;
@property (nonatomic, retain) IBOutlet UIButton* linkButton;
@property (nonatomic, retain) OFFlickrAPIRequest *flickrRequest;
@end
