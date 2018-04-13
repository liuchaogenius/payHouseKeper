//
//  OvalButton.m
//  PayHousekeeper
//
//  Created by BY on 2017/3/6.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "OvalButton.h"

@implementation OvalButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.titleLabel.font=[UIFont systemFontOfSize:10];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.frame.size.height / 2;
        
        UILabel *LvLabel = [[UILabel alloc] init];
        LvLabel.textColor = [UIColor whiteColor];
        // 粗体
        LvLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.f];
        
        LvLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:LvLabel];
        self.LvLabel = LvLabel;
        
        self.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 20);
        self.titleEdgeInsets = UIEdgeInsetsMake(-2, 0, 10, 0);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.LvLabel.frame = CGRectMake(35, 13, 40, 25);
}



@end
