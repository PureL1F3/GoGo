//
//  JZXKVideoSearchViewController.m
//  GoGo
//
//  Created by LazE on 6/4/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import "JZXKVideoSearchViewController.h"
#import "JZXKVideoSearchResultTableViewCell.h"
#import "TestViewCell.h"
@implementation JZXKVideoSearchViewController



- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self)
    {
        nRows = 1000;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"TestViewCell" bundle:nil] forCellReuseIdentifier:@"UITableViewCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return nRows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"IndexPath:%@", indexPath);
    TestViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 509.0;
}


@end
