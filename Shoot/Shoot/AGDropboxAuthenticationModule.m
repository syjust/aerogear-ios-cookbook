//
//  AGDropboxAuthenticationModule.m
//  Shoot
//
//  Created by Corinne Krych on 12/4/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGDropboxAuthenticationModule.h"

@implementation AGDropboxAuthenticationModule {
    // as all other custom auth modules, (eg. AGRestAuthentication) we
    // internally use the AGHttpClient to perform http communication. This
    // allows us to have full access to the underlying http setup.
    // (e.g. setting custom headers etc.)
    AGHttpClient* _restClient;
}

@synthesize type = _type;
@synthesize baseURL = _baseURL;
@synthesize loginEndpoint = _loginEndpoint;
@synthesize logoutEndpoint = _logoutEndpoint;
@synthesize enrollEndpoint = _enrollEndpoint;
@synthesize authTokens = _authTokens;

-(id)init {
    self = [super init];
    if (self) {
        _type = @"DROPBOX";
        _authTokens = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(NSString*) loginEndpoint {
    return [_baseURL stringByAppendingString:_loginEndpoint];
}

-(NSString*) logoutEndpoint {
    return [_baseURL stringByAppendingString:_logoutEndpoint];
}

-(NSString*) enrollEndpoint {
    return [_baseURL stringByAppendingString:_enrollEndpoint];
}

-(void) enroll:(id) userData
       success:(void (^)(id object))success
       failure:(void (^)(NSError *error))failure {
    
    @throw [NSException exceptionWithName:@"InvalidMessage"
                                   reason:@"enroll not applicable."
                                 userInfo:nil];
}

-(void) login:(NSString*) username
     password:(NSString*) password
      success:(void (^)(id object))success
      failure:(void (^)(NSError *error))failure DEPRECATED_ATTRIBUTE {
    
    [self login:@{@"user": username, @"passwd": password} success:success failure:failure];
}

-(void) login:(NSDictionary*) loginData
      success:(void (^)(id object))success
      failure:(void (^)(NSError *error))failure {
    
    [_authTokens addEntriesFromDictionary:@{@"Authorization": [self apiAuthorizationHeader]}];
    if (success) {
       success(nil);
    }
}

-(void) logout:(void (^)())success
       failure:(void (^)(NSError *error))failure {
    
    @throw [NSException exceptionWithName:@"InvalidMessage"
                                   reason:@"logout not applicable."
                                 userInfo:nil];
}

-(void) cancel {
    // cancel all running http operations
    [_restClient.operationQueue cancelAllOperations];
}

- (BOOL)isAuthenticated {
    return (nil != _authTokens);
}

- (void)deauthorize {
    _authTokens = nil;
}


//********************************************************************************
// private methods
//********************************************************************************

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

@end
