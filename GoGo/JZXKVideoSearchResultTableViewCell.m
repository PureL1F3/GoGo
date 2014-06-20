//
//  JZXKVideoSearchResultTableViewCell.m
//  GoGo
//
//  Created by LazE on 6/4/14.
//  Copyright (c) 2014 BabyJeff. All rights reserved.
//

#import "JZXKVideoSearchResultTableViewCell.h"


@implementation JZXKVideoSearchResultTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect viewFrame = CGRectMake(0.0, 0.0,
                                      self.contentView.bounds.size.width,
                                      self.contentView.bounds.size.height);
        
        self.customView = [[JZXKVideoPlayerView alloc]
                            initWithFrame:viewFrame];
        
        [self.contentView addSubview:self.customView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:NO];
//    if(animated)
//    {
//        //anim code #1
//        [super setSelected:selected animated:NO];
//        //anim code #2
//    }
//    else
//    {
//        [super setSelected:selected animated:NO];
//    }
}
@end
