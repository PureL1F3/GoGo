//
//  BNRVideoPlayerViewController.m
//  GoGo
//
//  Created by LazE on 6/4/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import "BNRVideoPlayerViewController.h"
#import "JZXKMainVideoAdvertView.h"
#import "JZXKVideoPlayerView.h"
@interface BNRVideoPlayerViewController ()
@property (strong, nonatomic) IBOutlet UIView *innerView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation BNRVideoPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    for(int i = 0; i <5; i++)
//    {
//        UINib *nib = [UINib nibWithNibName:@"JZXKMainVideoAdvertView" bundle:nil];
//        JZXKMainVideoAdvertView *view = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
//        
//        [self.scrollView addSubview:view];
//        float topPad = 50;
//        float x = view.frame.origin.x;
//        float y = i * view.frame.size.height + topPad;
//        float w = view.frame.size.width;
//        float h = view.frame.size.height + topPad;
//        [view setFrame:CGRectMake(x, y, w, h)];
//        
//    }
//    self.scrollView.contentSize = self.innerView.bounds.size;
    
    UINib *nib = [UINib nibWithNibName:@"JZXKVideoPlayerView" bundle:nil];
    JZXKVideoPlayerView *view = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    [self.scrollView addSubview:view];
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

@end
