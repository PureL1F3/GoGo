//
//  JZXKVidblit.m
//  GoGo
//
//  Created by LazE on 6/9/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import "JZXKVidblit.h"

@implementation JZXKVidblit

+ (NSString *)hostname
{
    return @"167.88.34.62";
}

+ (NSString *)requestStatusURL
{
    return @"http://167.88.34.62/request_status.php";
}

+ (NSString *)requestCreateURL
{
    return @"http://167.88.34.62/request_create.php";
}

+ (NSString *)requestUploadURL
{
    return @"http://167.88.34.62/request_upload.php";
}

+ (NSMutableURLRequest *)requestForRequestStatusWithUserID:(NSString *)userID RequestID:(NSString *)requestID
{
    NSURL *requestURL = [[NSURL alloc] initWithString:[JZXKVidblit requestStatusURL]];
    NSString *postBody = [NSString stringWithFormat:@"userid=%@&requestid=%@", userID, requestID];
    NSData *requestBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: requestBody];
    [request setHTTPMethod:@"POST"];
    
    return request;
}

+ (NSMutableURLRequest *) requestForCreateRequestWithUserID:(NSString *)userID videoULR:(NSString *) videoURL
{
    NSURL *requestURL = [[NSURL alloc] initWithString:[JZXKVidblit requestCreateURL]];
    NSString *postBody = [NSString stringWithFormat:@"userid=%@&url=%@", userID, videoURL];
    NSData *requestBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: requestBody];
    [request setHTTPMethod:@"POST"];
    
    return request;
}

@end
