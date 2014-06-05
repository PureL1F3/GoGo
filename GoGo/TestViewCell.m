//
//  TestViewCell.m
//  GoGo
//
//  Created by LazE on 6/4/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import "TestViewCell.h"

@implementation TestViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
