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


@interface AGShootViewController ()

@end

@implementation AGShootViewController
@synthesize imageView = _imageView;
@synthesize linkButton = _linkButton;
@synthesize restClient = _restClient;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateButtons];
}


- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
		[[DBSession sharedSession] linkFromController:self];
        [self updateButtons];
    } else {
        [[DBSession sharedSession] unlinkAll];
        [[[UIAlertView alloc]
          initWithTitle:@"Account Unlinked!" message:@"Your dropbox account has been unlinked"
          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
         show];
        [self updateButtons];
    }
}

- (void)updateButtons {
    NSString* title = [[DBSession sharedSession] isLinked] ? @"Unlink Dropbox" : @"Link Dropbox";
    [self.linkButton setTitle:title forState:UIControlStateNormal];
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

-(NSString*)apiAuthorizationHeader
{
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"accessToken"];
    NSString *tokenSecret = [[NSUserDefaults standardUserDefaults] valueForKey:@"accessTokenSecret"];
    NSString *appKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"appKey"];
    NSString *appSecret = [[NSUserDefaults standardUserDefaults] valueForKey:@"appSecret"];
    return [self plainTextAuthorizationHeaderForAppKey:appKey
                                             appSecret:appSecret
                                                 token:token
                                           tokenSecret:tokenSecret];
}

- (NSString*)plainTextAuthorizationHeaderForAppKey:(NSString*)appKey appSecret:(NSString*)appSecret token:(NSString*)token tokenSecret:(NSString*)tokenSecret
{
    // version, method, and oauth_consumer_key are always present
    NSString *header = [NSString stringWithFormat:@"OAuth oauth_version=\"1.0\",oauth_signature_method=\"PLAINTEXT\",oauth_consumer_key=\"%@\"",appKey];
    
    // look for oauth_token, include if one is passed in
    if (token) {
        header = [header stringByAppendingString:[NSString stringWithFormat:@",oauth_token=\"%@\"", token]];
    }
    
    // add oauth_signature which is app_secret&token_secret , token_secret may not be there yet, just include @"" if it's not there
    if (!tokenSecret) {
        tokenSecret = @"";
    }
    header = [header stringByAppendingString:[NSString stringWithFormat:@",oauth_signature=\"%@&%@\"", appSecret, tokenSecret]];
    return header;
}

- (IBAction)share:(id)sender {
    NSLog(@"Sharing...");
    
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(self.imageView.image, 0.5)];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"tempImage.jpeg"]; //Add the file name
    [imageData writeToFile:filePath atomically:YES]; //Write the file
    
    
    // TODO create an authenticator object
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    
    // add a new auth module and the required 'base url':
    NSURL* baseURL = [NSURL URLWithString:@"https://api.dropbox.com/1/metadata/dropbox/photos/"];
    id<AGAuthenticationModule> myMod = [authenticator auth:^(id<AGAuthConfig> config) {
        [config setName:@"authMod"];
        [config setBaseURL:baseURL];
    }];
    
    // TODO Temporary hack wait until AG implement OAuth
    [myMod.authTokens addEntriesFromDictionary:@{@"Authorization": [self apiAuthorizationHeader]}];
    
    NSURL* baseURL2 = [NSURL URLWithString:@"https://api-content.dropbox.com/1/files_put/dropbox/"];
    AGPipeline* pipeline = [AGPipeline pipelineWithBaseURL:baseURL2];
    
    id<AGPipe> photos = [pipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"photos"];
        [config setBaseURL:baseURL2];
        [config setAuthModule:myMod];
    }];
    
    NSURL *file1 = [NSURL fileURLWithPath:filePath];//[[NSBundle mainBundle] URLForResource:@"jboss2" withExtension:@"jpg"];
    // construct the data to sent with the files added
    NSMutableDictionary *files = [@{@"jboss2_pano_222.jpg":file1, @"id":[NSString stringWithFormat:@"photo_%i.jpg", arc4random() % 1000]} mutableCopy];
    
    // save the 'new' project:
    [photos save:files success:^(id responseObject) {
        // LOG the JSON response, returned from the server:
        NSLog(@"CREATE RESPONSE\n%@", [responseObject description]);
        
        // get the id of the new project, from the JSON response...
        id resourceId = [responseObject valueForKey:@"id"];
        
        // and update the 'object', so that it knows its ID...
        [files setValue:[resourceId stringValue] forKey:@"id"];
        
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
