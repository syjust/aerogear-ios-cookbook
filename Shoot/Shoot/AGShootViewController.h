//
//  AGViewController.h
//  Shoot
//
//  Created by Corinne Krych on 11/22/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <DropboxSDK/DropboxSDK.h>

@interface AGShootViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;
- (IBAction)share:(id)sender;

// Dropbox OAuth step
- (IBAction)didPressLink;
@property (nonatomic, retain) IBOutlet UIButton* linkButton;
@property (nonatomic, retain) DBRestClient* restClient;
@end
