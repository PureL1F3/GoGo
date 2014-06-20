//
//  TOOTVidblit.h
//  TooTaker
//
//  Created by LazE on 6/19/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

static const char* TOOTKeychainPasswordIdentifier    = "com.vidblit.dts.Keychain.password\0";
static const char* TOOTKeychainEmailIdentifier    = "com.vidblit.dts.Keychain.email\0";
static const char* TOOTKeychainUsernameIdentifier    = "com.vidblit.dts.Keychain.username\0";
static const char* TOOTKeychainTokenIdentifier    = "com.vidblit.dts.Keychain.token\0";

typedef enum {
    TOOTKeychainPassword,
    TOOTKeychainEmail,
    TOOTKeychainUsername,
    TOOTKeychainToken
} TOOTKeychainKey;

@interface TOOTVidblit : NSObject

@property (nonatomic) NSString *hostname;
@property (nonatomic) NSMutableDictionary *services;

// user registration and logon
-(NSMutableURLRequest *)requestForRegisterWithUsername:(NSString *) user email:(NSString *)email password:(NSString *)pwd;
-(void)requestForLoginWithUsername:(NSString *)user password:(NSString *)pwd;
-(void)requestForResetLoginWithEmail:(NSString *)email;
-(NSMutableURLRequest *)requestForLogout;

// video request
-(NSMutableURLRequest *)requestForUserVideoUrl:(NSString *)url;
-(NSMutableURLRequest *)requestForUserVideoStatus:(NSString *)rID;
-(NSMutableURLRequest *)requestForVideoPlaylist:(NSString *)rID;

-(NSString *)userToken;

//-(BOOL) saveLoginWithEmail:(NSString *)email password:(NSString *)pwd token:(NSString *)token;
//-(BOOL) clearLogin;

-(BOOL)saveToken:(NSString *)token;
-(BOOL)saveCredentialsWithUsername:(NSString *) user email:(NSString *)email password:(NSString *)pwd;
-(BOOL) clearCredentials;

-(BOOL)deleteKeychainValue:(TOOTKeychainKey)key;
-(NSString *)getKeychainValue:(TOOTKeychainKey)key;
-(BOOL)setKeychainValue:(NSString *)value withKey:(TOOTKeychainKey)key;

@end
