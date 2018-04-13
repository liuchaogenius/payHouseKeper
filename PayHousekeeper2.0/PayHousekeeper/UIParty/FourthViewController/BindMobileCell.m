//
//  BindMobileCell.m
//  PayHousekeeper
//
//  Created by 1 on 2016/12/29.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BindMobileCell.h"

@interface BindMobileCell()
{
    UIImage *iconImg;
    NSString *title;
    int index;
}

@property (nonatomic, copy)void(^buttonClickBlock)(int index);
@end

@implementation BindMobileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setCellDataIcon:(UIImage *)aIconImg
                  title:(NSString *)aTitle
                 isBind:(BOOL)aIsBind
                  index:(int)aIndex
             clickBlock:(void(^)(int index))aBlock
{
    self.buttonClickBlock = nil;
    self.buttonClickBlock = aBlock;
    iconImg = aIconImg;
    title = aTitle;
    _isBind = aIsBind;
    index = aIndex;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self removeSubviews];
    [self createCell];
}

- (void)createCell
{
    [self removeSubviews];
    UIImageView *iconImgview = [[UIImageView alloc] initWithFrame:CGRectMake(15, (self.height-iconImg.size.height)/2, iconImg.size.width, iconImg.size.height)];
    [iconImgview setImage:iconImg];
    [self addSubview:iconImgview];
    
    CGSize size = [title sizeWithFont:kFont14];
    self.tLabel = [self labelWithFrame:CGRectMake(iconImgview.right+10, 0, size.width+2, self.height) text:title textFont:kFont14 textColor:RGBCOLOR(102, 102, 102)];
    [self addSubview:self.tLabel];
    
    UIButton *bindButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width-15-61, (self.height-29)/2, 61, 29)];
    bindButton.layer.cornerRadius = 5.0f;
    bindButton.titleLabel.font = kFont14;
    [bindButton addTarget:self action:@selector(buttonItem) forControlEvents:UIControlEventTouchUpInside];
    if(_isBind)
    {
        bindButton.backgroundColor = kcolorWhite;
        bindButton.layer.borderWidth = kLineWidth;
        bindButton.layer.borderColor = RGBCOLOR(33, 235, 190).CGColor;
        [bindButton setTitle:@"解绑" forState:UIControlStateNormal];
        [bindButton setTitleColor:RGBCOLOR(33, 235, 190) forState:UIControlStateNormal];
    }
    else
    {
        bindButton.backgroundColor = RGBCOLOR(33, 235, 190);
        bindButton.layer.borderWidth = kLineWidth;
        bindButton.layer.borderColor = RGBCOLOR(33, 235, 190).CGColor;
        [bindButton setTitle:@"绑定" forState:UIControlStateNormal];
        [bindButton setTitleColor:kcolorWhite forState:UIControlStateNormal];
    }
    [self addSubview:bindButton];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, kMainScreenWidth, 1)];
    line.backgroundColor = kViewBackgroundHexColor;
    [self addSubview:line];
    self.line = line;
}

- (void)buttonItem
{
    if(self.buttonClickBlock)
    {
        self.buttonClickBlock(index);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
