//
//  JZXKRecordingLoadViewController.h
//  GoGo
//
//  Created by LazE on 6/5/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JZXKRecordingLoadViewController : UIViewController <NSURLSessionDelegate, NSURLSessionTaskDelegate>
{
    int MAX_STATUS_REQUESTS;
    float STATUS_REQUEST_DELAY;
    int statusRequestCount;
    dispatch_queue_t background_request_queue;
}

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *requestID;
@property (nonatomic) NSDate *timeRequestGenerated;

@property (nonatomic) NSString *requestOriginalURL;
@property (nonatomic) NSString *requestType;
@property (nonatomic) NSString *requestTitle;
@property (nonatomic) NSString *requestSrcURL;

@property (nonatomic) NSURLSessionDataTask *requestTask;

- (IBAction)recordVideo:(id)sender;

@end
