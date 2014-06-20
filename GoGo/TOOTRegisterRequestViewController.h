//
//  TOOTRegisterRequestViewController.h
//  TooTaker
//
//  Created by LazE on 6/19/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOOTVidblit.h"

@interface TOOTRegisterRequestViewController : UIViewController

@property (nonatomic) TOOTVidblit *vidlit;

@property (nonatomic) NSString *username;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *email;



@property (weak, nonatomic) IBOutlet UIButton *registerBTN;
@property (weak, nonatomic) IBOutlet UITextField *userTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextView *resultTV;
- (IBAction)registerUser:(id)sender;
@end
