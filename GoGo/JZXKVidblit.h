//
//  JZXKVidblit.h
//  GoGo
//
//  Created by LazE on 6/9/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JZXKVidblit : NSObject
+ (NSString *)hostname;
+ (NSString *)requestStatusURL;
+ (NSString *)requestCreateURL;
+ (NSString *)requestUploadURL;
+ (NSMutableURLRequest *)requestForRequestStatusWithUserID:(NSString *)userID RequestID:(NSString *)requestID;
+ (NSMutableURLRequest *) requestForCreateRequestWithUserID:(NSString *)userID videoULR:(NSString *) videoURL;

@end
