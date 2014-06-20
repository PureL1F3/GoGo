//
//  TOOTVidblit.m
//  TooTaker
//
//  Created by LazE on 6/19/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import "TOOTVidblit.h"

@implementation TOOTVidblit


-(id)init
{
    self = [super init];
    if(self)
    {
        [self configure];
    }
    return self;
}

// setup
-(void)configure
{
    self.hostname = @"http://107.170.154.102";
    self.services = @{
                      //user registration and logon
                      @"register" : @"/register.php",
                      @"login" : @"/login.php",           // TODO
                      @"reset_user" : @"/reset_user.php", // TODO
                      @"logout" : @"/logout.php",
                      //video request
                      @"request_create": @"/create_request.php",
                      @"request_status": @"/request_status.php",
                      @"playlist" : @"/playlist.m3u8"};
}

-(NSString *)requestURLStringForService:(NSString *)service
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.hostname, self.services[service]];
    return urlString;
}

-(NSURL *)requestURLForURLString:(NSString *)urlString
{
    NSURL *url = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    return url;
}

- (NSMutableURLRequest *)requestWithURL:(NSURL *)url body:(NSData *)body headers:(NSMutableDictionary*)headers method:(NSString *)method
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    for(NSString *field in headers)
    {
        NSString *value = headers[field];
        [request setValue:value forHTTPHeaderField:field];
    }
    if (body)
    {
        [request setHTTPBody:body];
    }
    return request;
}


// user registration and logon
-(NSMutableURLRequest *)requestForRegisterWithUsername:(NSString *) user email:(NSString *)email password:(NSString *)pwd
{
    NSLog(@"TOOTVidblit:requestForRegisterWithUsername(u=%@,e=%@,p=%@)", user, email, pwd);
    NSURL *url = [self requestURLForURLString:[self requestURLStringForService:@"register"]];
    NSString *paramString = [NSString stringWithFormat:@"user=%@&email=%@&pwd=%@", user, email, pwd];
    NSData *body = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *headers = @{@"application/x-www-form-urlencoded": @"content-type"};
    return [self requestWithURL:url body:body headers:headers method:@"POST"];
}

-(void)requestForLoginWithUsername:(NSString *)user password:(NSString *)pwd
{//TODO
    NSLog(@"TOOTVidblit:requestForLoginWithUsername(u=%@,p=%@)", user, pwd);
}

-(void)requestForResetLoginWithEmail:(NSString *)email
{//TODO
    NSLog(@"TOOTVidblit:requestForResetLoginWithEmail(e=%@)", email);
}

-(NSMutableURLRequest *)requestForLogout
{
    NSLog(@"TOOTVidblit:requestForLogout");

    NSURL *url = [self requestURLForURLString:[self requestURLStringForService:@"logout"]];
    NSString *token = @"";
    NSMutableDictionary *headers = @{
                            @"application/x-www-form-urlencoded": @"content-type",
                            @"X-Description": [self userToken]};
    return [self requestWithURL:url body:nil headers:headers method:@"POST"];
}

// video request
-(NSMutableURLRequest *)requestForUserVideoUrl:(NSString *)vURL
{
    NSLog(@"TOOTVidblit:requestForUserVideoUrl(u=%@)", vURL);
    NSURL *url = [self requestURLForURLString:[self requestURLStringForService:@"request_create"]];
    NSString *paramString = [NSString stringWithFormat:@"url=%@", vURL];
    NSData *body = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *headers = @{@"application/x-www-form-urlencoded": @"content-type",
                                     @"X-Description": [self userToken]};
    return [self requestWithURL:url body:body headers:headers method:@"POST"];
}

-(NSMutableURLRequest *)requestForUserVideoStatus:(NSString *)rID
{
    NSLog(@"TOOTVidblit:requestForUserVideoStatus(i=%@)", rID);
    NSString *rawURLString = [NSString stringWithFormat:@"%@?id=%@", [self requestURLStringForService:@"request_status"], rID];
    NSURL *url = [self requestURLForURLString:rawURLString];
    NSMutableDictionary *headers = @{@"X-Description": [self userToken]};
    return [self requestWithURL:url body:nil headers:headers method:@"GET"];
}

-(NSMutableURLRequest *)requestForVideoPlaylist:(NSString *)rID
{
    NSLog(@"TOOTVidblit:requestForVideoPlaylist(i=%@)", rID);
    NSString *rawURLString = [NSString stringWithFormat:@"%@?id=%@&t=%@", [self requestURLStringForService:@"playlist"], rID, [self userToken]];
    NSURL *url = [self requestURLForURLString:rawURLString];
    NSString *paramString = [NSString stringWithFormat:@"id=%@&t=%@", rID, [self userToken]];
    NSData *body = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *headers = @{@"application/x-www-form-urlencoded": @"content-type"};
    return [self requestWithURL:url body:body headers:headers method:@"GET"];
}

-(NSString *)userToken
{
    NSString *token = [self getKeychainValue:TOOTKeychainToken];
    if(!token)
    {
        token = @"";
    }
    return token;
}

-(BOOL)saveToken:(NSString *)token
{
    BOOL tokenKeychain = [self setKeychainValue:token withKey:TOOTKeychainToken];
    return tokenKeychain;
}

-(BOOL)saveCredentialsWithUsername:(NSString *) user email:(NSString *)email password:(NSString *)pwd
{
    BOOL userKeychain = [self setKeychainValue:user withKey:TOOTKeychainUsername];
    BOOL emailKeychain = [self setKeychainValue:email withKey:TOOTKeychainEmail];
    BOOL pwdKeychain = [self setKeychainValue:pwd withKey:TOOTKeychainPassword];
    
    return (userKeychain && emailKeychain && pwdKeychain);
}

-(BOOL) clearCredentials
{
    BOOL userKeychain = [self deleteKeychainValue:TOOTKeychainUsername];
    BOOL emailKeychain = [self deleteKeychainValue:TOOTKeychainEmail];
    BOOL pwdKeychain = [self deleteKeychainValue:TOOTKeychainPassword];
    BOOL tokenKeychain = [self deleteKeychainValue:TOOTKeychainToken];
    return (userKeychain && emailKeychain && pwdKeychain && tokenKeychain);
}

-(BOOL)deleteKeychainValue:(TOOTKeychainKey)key
{
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassInternetPassword forKey:(__bridge id)kSecClass];
    
    char *keyName = [self keyNameForKey:key];
    if(!keyName)
    {
        return FALSE;
    }
    NSData *keyID = [NSData dataWithBytes:keyName length:strlen((const char*)keyName)];
    [query setObject:keyID forKey:(__bridge id)kSecAttrLabel];
    
    OSStatus keychainErr = SecItemDelete((__bridge CFDictionaryRef)query);
    return (keychainErr == errSecSuccess);
}

-(NSString *)getKeychainValue:(TOOTKeychainKey)key
{
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassInternetPassword forKey:(__bridge id)kSecClass];
    
    char *keyName = [self keyNameForKey:key];
    if(!keyName)
    {
        return FALSE;
    }
    NSData *keyID = [NSData dataWithBytes:keyName length:strlen((const char*)keyName)];
    [query setObject:keyID forKey:(__bridge id)kSecAttrLabel];
    [query setObject:keyID forKey:(__bridge id)kSecAttrAccount];

    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    CFDataRef dataRef = nil;
    OSStatus keychainErr = SecItemCopyMatching((__bridge CFDataRef)query,
                                               (CFTypeRef *)&dataRef);
    NSString *value = nil;
    if(keychainErr == errSecSuccess)
    {
        value = [[NSString alloc] initWithData:(__bridge NSData *)(dataRef) encoding:NSUTF8StringEncoding];
    }
    
    return value;
}

-(BOOL)setKeychainValue:(NSString *)value withKey:(TOOTKeychainKey)key
{
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassInternetPassword forKey:(__bridge id)kSecClass];
    
    char *keyName = [self keyNameForKey:key];
    if(!keyName)
    {
        return FALSE;
    }
    NSData *keyID = [NSData dataWithBytes:keyName length:strlen((const char*)keyName)];
    [query setObject:keyID forKey:(__bridge id)kSecAttrLabel];
    [query setObject:keyID forKey:(__bridge id)kSecAttrAccount];
    
    OSStatus keychainErr = SecItemCopyMatching((__bridge CFDataRef)query, NULL);
    if(keychainErr == errSecSuccess)
    {
        NSMutableDictionary *attribRef = [[NSMutableDictionary alloc] init];
        [attribRef setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        
        keychainErr = SecItemUpdate((__bridge CFDictionaryRef)query,
                                             (__bridge CFDictionaryRef)attribRef);
    }
    else
    {
        [query setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        keychainErr = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    }
    
    return (keychainErr == errSecSuccess);
}

-(char *)keyNameForKey:(TOOTKeychainKey)key
{
    char *keyName = nil;
    switch (key) {
        case TOOTKeychainEmail:
            keyName = TOOTKeychainEmailIdentifier;
            break;
        case TOOTKeychainPassword:
            keyName = TOOTKeychainPasswordIdentifier;
            break;
        case TOOTKeychainToken:
            keyName = TOOTKeychainTokenIdentifier;
            break;
        case TOOTKeychainUsername:
            keyName = TOOTKeychainUsernameIdentifier;
            break;
        default:
            break;
    }
    
    return keyName;
}

@end
