//
//  TOOTRegisterRequestViewController.m
//  TooTaker
//
//  Created by LazE on 6/19/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import "TOOTRegisterRequestViewController.h"


@interface TOOTRegisterRequestViewController ()

@end

@implementation TOOTRegisterRequestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.vidlit = [[TOOTVidblit alloc] init];
        waitingOnResult = FALSE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add nav bar back button and title to nav bar
    [self.navigationItem setTitle:@"Register"];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(navigateBack:)];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerUser:(id)sender {
    NSLog(@"TOOTRegisterRequestViewController:registerUser");
    if(waitingOnResult)
    {
        return;
    }
    
    waitingOnResult = TRUE;
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
            waitingOnResult = FALSE;
            return;
        }

        NSLog(@"Session Request Success");
        NSString *body = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        BOOL ok = [[json valueForKey:@"ok"] boolValue];
        if(!ok)
        {
            NSLog(@"Registration failed");
            self.resultTV.text = [json valueForKey:@"result"];
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
                self.resultTV.text = [NSString stringWithFormat:@"Result:\n%@", body];
            });
        }
        
        waitingOnResult = FALSE;
    }] resume];
}

-(void)navigateBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
