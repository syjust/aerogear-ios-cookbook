//
//  AGViewController.m
//  Shoot
//
//  Created by Corinne Krych on 11/22/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGShootViewController.h"
#import "AeroGear.h"
#import "AGAuthenticationModule.h"
#import "AGAppDelegate.h"

NSString *kFetchRequestTokenStep = @"kFetchRequestTokenStep";
NSString *kGetUserInfoStep = @"kGetUserInfoStep";

@interface AGShootViewController ()

@end

@implementation AGShootViewController
@synthesize imageView = _imageView;
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) useCamera:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia = YES;
    }
}

- (void) useCameraRoll:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia = NO;
    }
}

- (IBAction)share:(id)sender {
    NSLog(@"Sharing...");
   
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"tempImage.jpeg"]; //Add the file name
    [imageData writeToFile:filePath atomically:YES]; //Write the file
    
    // ObjectiveFlickr upload IS successfull
    // Uncomment this line to test ObjectiveFlickr upload
    //[self.flickrRequest uploadImageStream:[NSInputStream inputStreamWithData:imageData] suggestedFilename:@"Snap and Run Demo" MIMEType:@"image/jpeg" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"is_public", nil]];
    
    // Upload with AEroGEar failing with 401
//    NSURL* baseURL2 = [NSURL URLWithString:@"http://api.flickr.com/services/"];
//    AGPipeline* pipeline = [AGPipeline pipelineWithBaseURL:baseURL2];
//    
//    id<AGPipe> photos = [pipeline pipe:^(id<AGPipeConfig> config) {
//        [config setName:@"upload/"];
//        [config setBaseURL:baseURL2];
//        //[config setAuthModule:myMod];
//    }];
//    
//    NSURL *file1 = [NSURL fileURLWithPath:filePath];
//    // construct the data to sent with the files added
//    NSMutableDictionary *files = [[NSMutableDictionary alloc] init];
//    [files addEntriesFromDictionary:signedArgs];
//    [files addEntriesFromDictionary:@{@"photo":file1}];
//    
//    // save the 'new' project:
//    [photos save:files success:^(id responseObject) {
//        // LOG the JSON response, returned from the server:
//        NSLog(@"CREATE RESPONSE\n%@", [responseObject description]);
//        
//        
//    } failure:^(NSError *error) {
//        // when an error occurs... at least log it to the console..
//        NSLog(@"SAVE: An error occured! \n%@", error);
//    }];
//    

}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        _imageView.image = image;
        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
