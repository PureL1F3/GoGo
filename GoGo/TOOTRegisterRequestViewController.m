//
//  TOOTRegisterRequestViewController.m
//  TooTaker
//
//  Created by LazE on 6/19/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import "TOOTRegisterRequestViewController.h"
#import "JZXKRecordingLoadViewController.h"

@interface TOOTRegisterRequestViewController ()

@end

@implementation TOOTRegisterRequestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.vidlit = [[TOOTVidblit alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerUser:(id)sender {
    NSLog(@"TOOTRegisterRequestViewController:registerUser");
    [self setEnabledEntry:FALSE];
    self.username = self.userTF.text;
    self.password = self.pwdTF.text;
    self.email = self.emailTF.text;
    self.resultTV.text = @"";
    
    NSMutableURLRequest *request = [self.vidlit requestForRegisterWithUsername:self.username email:self.email password:self.password];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error)
        {
            NSLog(@"Session Request Error: %@", error);
            [self showRegistrationErrorOnMainThread:@"Please check network is available"];
            return;
        }

        NSLog(@"Session Request Success");
        NSString *body = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        BOOL ok = [[json valueForKey:@"ok"] boolValue];
        if(!ok)
        {
            NSLog(@"Registration failed");
            [self showRegistrationErrorOnMainThread:(NSString *)[json valueForKey:@"result"]];
        }
        else
        {
            NSLog(@"Registration success");
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary *headers = [httpResponse allHeaderFields];
            NSString *token = [headers valueForKey:@"X-Description"];
            
            BOOL credentialResult = [self.vidlit saveCredentialsWithUsername:self.username email:self.email password:self.password];
            BOOL tokenResult = [self.vidlit saveToken: token];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:[[JZXKRecordingLoadViewController alloc] init] animated:YES];
            });
        }
    }] resume];
}

-(void)setEnabledEntry:(BOOL) enabled
{
    self.userTF.enabled = enabled;
    self.emailTF.enabled = enabled;
    self.pwdTF.enabled = enabled;
    self.registerBTN.enabled = enabled;
}

-(void)showRegistrationErrorOnMainThread:(NSString *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.resultTV.text = error;
        [self setEnabledEntry:TRUE];
    });
}

-(void)navigateBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
