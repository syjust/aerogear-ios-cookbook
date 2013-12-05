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
@synthesize linkButton = _linkButton;
@synthesize flickrRequest = _flickrRequest;
- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)didPressLink {
    // if there's already OAuthToken, we want to reauthorize
    if ([[AGAppDelegate sharedDelegate].flickrContext.OAuthToken length]) {
        [[AGAppDelegate sharedDelegate] setAndStoreFlickrAuthToken:nil secret:nil];
    }
    
    self.flickrRequest.sessionInfo = kFetchRequestTokenStep;
    [self.flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:SRCallbackURLBaseString]];
}


- (OFFlickrAPIRequest *)flickrRequest
{
    if (!_flickrRequest) {
        _flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:[AGAppDelegate sharedDelegate].flickrContext];
        _flickrRequest.delegate = self;
		_flickrRequest.requestTimeoutInterval = 60.0;
    }
    
    return _flickrRequest;
}

#pragma mark OFFlickrAPIRequest delegate methods

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret
{
    // these two lines are important
    [AGAppDelegate sharedDelegate].flickrContext.OAuthToken = inRequestToken;
    [AGAppDelegate sharedDelegate].flickrContext.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [[AGAppDelegate sharedDelegate].flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, inRequest.sessionInfo, inResponseDictionary);
    
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, inRequest.sessionInfo, inError);
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
    NSDictionary* inArguments = @{@"is_public":@"0"};
    
    
    OFFlickrAPIContext* context = [[AGAppDelegate sharedDelegate] flickrContext];
    NSDictionary *signedArgs = [context signedOAuthHTTPQueryArguments:(inArguments ? inArguments : [NSDictionary dictionary]) baseURL:[NSURL URLWithString:[context uploadEndpoint]] method:LFHTTPRequestPOSTMethod];
    
    
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"tempImage.jpeg"]; //Add the file name
    [imageData writeToFile:filePath atomically:YES]; //Write the file
    
    // ObjectiveFlickr upload IS successfull
    // Uncomment this line to test ObjectiveFlickr upload
    //[self.flickrRequest uploadImageStream:[NSInputStream inputStreamWithData:imageData] suggestedFilename:@"Snap and Run Demo" MIMEType:@"image/jpeg" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"is_public", nil]];
    
    // Upload with AEroGEar failing with 401
    NSURL* baseURL2 = [NSURL URLWithString:@"http://api.flickr.com/services/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithBaseURL:baseURL2];
    
    id<AGPipe> photos = [pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"upload"];
        [config setBaseURL:baseURL2];
        //[config setAuthModule:myMod];
    }];
    
    NSURL *file1 = [NSURL fileURLWithPath:filePath];
    // construct the data to sent with the files added
    NSMutableDictionary *files = [[NSMutableDictionary alloc] init];
    [files addEntriesFromDictionary:signedArgs];
    [files addEntriesFromDictionary:@{@"file":file1}];
    
    // save the 'new' project:
    [photos save:files success:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"CREATE RESPONSE\n%@", [responseObject description]);
        
        
    } failure:^(NSError *error) {
        // when an error occurs... at least log it to the console..
        NSLog(@"SAVE: An error occured! \n%@", error);
    }];
    

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
