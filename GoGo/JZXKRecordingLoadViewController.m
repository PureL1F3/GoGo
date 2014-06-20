//
//  JZXKRecordingLoadViewController.m
//  GoGo
//
//  Created by LazE on 6/5/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import "JZXKRecordingLoadViewController.h"
#import "JZXKRecordingCamViewController.h"
#import "JZXKVidblit.h"

@interface JZXKRecordingLoadViewController ()
{
    NSString *videoURL;
}

@end

@implementation JZXKRecordingLoadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        MAX_STATUS_REQUESTS = 15;
        STATUS_REQUEST_DELAY = 3.0;
        background_request_queue = dispatch_queue_create("com.vidblit.cock.block", NULL);

        self.userID = @"0";

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Select Video"];
    [self.navigationItem.backBarButtonItem setTitle:@"Back"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self hideErrorForRequest];
    self.activityIndicator.hidden = true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)recordVideo:(id)sender
{
    NSLog(@"Clicked record video with URL '%@'", self.urlTextField.text);
    self.requestOriginalURL = self.urlTextField.text;
    
    bool doTest = false;
    if(doTest)
    {
        self.requestID = @"61";
        ////    self.requestTitle = @"Crazed Woman Attacks Man for Flying Drone on Beach";
        ////    self.requestType = @"LiveLeak";
        //self.requestSrcURL = @"/vidblit/videos/requests/61/source/playlist.m3u8";
        self.requestSrcURL = @"/vidblit/videos/playlist.m3u8";
        self.requestSrcURL = [NSString stringWithFormat:@"http://%@%@", [JZXKVidblit hostname], self.requestSrcURL];
        ////
        [self showRecordVideoScreenForRequest];
    }
    else
    {
        //testing --- from create request
        //

        [self createRequest];
    }
    
    

    //testing -- just request status
//    self.requestID = @"22";
//    [self getRequestStatus];
}

- (void)showRecordVideoScreenForRequest
{
    NSLog(@"Showing record view for request:");
    self.activityIndicator.hidden = true;
    JZXKRecordingCamViewController *recordVideoController = [[JZXKRecordingCamViewController alloc] init];
    
    recordVideoController.requestID = self.requestID;
    recordVideoController.requestTitle = self.requestTitle;
    recordVideoController.requestType = self.requestType;
    recordVideoController.requestSrcURL = self.requestSrcURL;
    [self.navigationController pushViewController:recordVideoController animated:YES];
}

- (void)showErrorForRequest:(NSString *)error
{
    NSLog(@"Showing error for request: %@", error);
    self.activityIndicator.hidden = true;
    self.errorLabel.text = error;
    self.errorLabel.hidden = false;
}

- (void)hideErrorForRequest
{
    self.errorLabel.hidden = true;
}

- (void)createRequest
{
    self.activityIndicator.hidden = false;

    statusRequestCount = 0;
    NSLog(@"Creating background request for url");
    dispatch_async(background_request_queue, ^{
        NSMutableURLRequest *request = [JZXKVidblit requestForCreateRequestWithUserID:self.userID videoULR:self.requestOriginalURL];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error)
          {
              if(error)
              {
                  NSLog(@"Got response for create request with http Error - %@", error);
                  return;
              }
              
              NSString *body = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
              [self handleCreateRequestResponse:json];
          }] resume];
        
    });
}

- (void)handleCreateRequestResponse:(NSDictionary *)json
{
    NSLog(@"Processing response for request create with dictionary: %@", json);
    if([json[@"success"] boolValue])
    {
        NSLog(@"succcessfully created request!");
        self.requestID = json[@"requestid"];
        [self getRequestStatus];
    }
    else
    {
        NSLog(@"error in created request!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showErrorForRequest:json[@"error"]];
        });
    }

}

- (void)getRequestStatus
{
    NSLog(@"getting request status!");
    if(statusRequestCount++ >= MAX_STATUS_REQUESTS)
    {
        NSLog(@"We have run out of status requests so erroring out!");
        NSString *error = @"Please try again later";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showErrorForRequest:error];
            return;
        });
    }

    NSLog(@"about to run delayed request for status");
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, STATUS_REQUEST_DELAY * NSEC_PER_SEC);
    dispatch_after(popTime, background_request_queue, ^(void){
        NSMutableURLRequest *request = [JZXKVidblit requestForRequestStatusWithUserID:self.userID RequestID:self.requestID];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error)
          {
              if(error)
              {
                  NSLog(@"Received response for status with http Error - %@", error);
                  return;
              }
              
              NSString *body = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
              [self handleGetRequestStatusResponse:json];
          }] resume];
    });
}

- (void)handleGetRequestStatusResponse:(NSDictionary *)json
{
    NSLog(@"Processing response for request status with dictionary: %@", json);
    if([json objectForKey:@"error"])
    {
        NSLog(@"We got an error!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showErrorForRequest:json[@"error"]];
        });
    }
    else if([json objectForKey:@"sourceURL"])
    {
        NSLog(@"We got a sourceURL!");
        self.requestSrcURL = json[@"sourceURL"];
        self.requestSrcURL = [NSString stringWithFormat:@"http://%@%@", [JZXKVidblit hostname], self.requestSrcURL];
        self.requestTitle = json[@"title"];
        self.requestType = json[@"type"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showRecordVideoScreenForRequest];
        });
    }
    else
    {
        NSLog(@"We got nothing so trying to get another request status!");
        [self getRequestStatus];
    }
}


@end
