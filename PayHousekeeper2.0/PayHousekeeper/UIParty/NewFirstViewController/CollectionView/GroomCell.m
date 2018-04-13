//
//  GroomCell.m
//  DongDong
//
//  Created by BY on 2017/3/14.
//  Copyright © 2017年 BestLife. All rights reserved.
//

#import "GroomCell.h"
#import "GroomData.h"
#import "UIImageView+WebCache.h"

@interface GroomCell()
@property (weak, nonatomic)UIImageView *imgView;
@property (weak, nonatomic)UILabel *titleLabel;
@property (weak, nonatomic)UIView *bottomView;
@property (nonatomic, weak)UIButton *loveImgCount;
@end

@implementation GroomCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *imgView = [[UIImageView alloc] init];
        [self addSubview:imgView];
        self.imgView = imgView;
        
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = RGBACOLOR(28, 28, 28, 0.5);
        [self addSubview:bottomView];
        self.bottomView = bottomView;
        
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [bottomView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UIButton *loveImgCount = [[UIButton alloc] init];
        loveImgCount.userInteractionEnabled = NO;
        [loveImgCount setImage:[UIImage imageNamed:@"love"] forState:UIControlStateNormal];
        loveImgCount.titleLabel.font = [UIFont systemFontOfSize:15];
        loveImgCount.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 100);
        loveImgCount.titleEdgeInsets = UIEdgeInsetsMake(0, -28, 0, 30);
        loveImgCount.titleLabel.textColor = [UIColor whiteColor];
        [bottomView addSubview:loveImgCount];
        self.loveImgCount = loveImgCount;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imgView.frame = self.contentView.frame;
    
    self.bottomView.frame = CGRectMake(0, self.frame.size.height - 55, self.frame.size.width, 55);
    
    self.titleLabel.frame = CGRectMake(10, 5, self.frame.size.width - 10, 20);
    
    self.loveImgCount.frame = CGRectMake(10, CGRectGetMaxY(self.titleLabel.frame), 120, 30);
}

- (void)setData:(GroomData *)data
{
    _data = data;

    // 1.图片
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:data.img] placeholderImage:[UIImage imageNamed:@"originally"]];

    // 2.标题
    self.titleLabel.text = data.title;
    
    [self.loveImgCount setTitle:[NSString stringWithFormat:@"%d", data.loveCount] forState:UIControlStateNormal];

}
@end
