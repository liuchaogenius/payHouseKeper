//
//  BroadcastView.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/20.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BroadcastView.h"

@implementation BroadcastView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)initViewWithBroadcast:(BroadcastModel *)model
{
    if([model.type intValue] == 0)//系统通知
    {
        [self initSysMessWithBroadcast:model];
    }
    else//礼物通知
    {
        [self initGiftWithBroadcast:model];
    }
    [self setHeight:35];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.height/2;
}

- (void)initSysMessWithBroadcast:(BroadcastModel *)model
{
    [self removeSubviews];
    UIImageView *tipImgView = [[UIImageView alloc] initWithImage:IMG(@"sysMessTip")];
    [tipImgView setX:1.5];
    [tipImgView setY:1.5];
    [self addSubview:tipImgView];
    
    float width;
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(tipImgView.right+10, 0, kMainScreenWidth, 17.5)];
    lab.text = @"系统消息";
    lab.textColor = kcolorWhite;
    lab.font = kFont13;
    [lab sizeToFit];
    [lab setHeight:17.5];
    [self addSubview:lab];
    width = lab.right;
    
    lab = [[UILabel alloc] initWithFrame:CGRectMake(tipImgView.right+10, 17.5, kMainScreenWidth, 17.5)];
    lab.text = model.content;
    lab.textColor = RGBCOLOR(38, 214, 153);
    lab.font = kFont13;
    [lab sizeToFit];
    [lab setHeight:17.5];
    [self addSubview:lab];
    width = MAX(width, lab.right);
    
    [self setWidth:width+20];
}

- (void)initGiftWithBroadcast:(BroadcastModel *)model
{
    [self removeSubviews];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(1.5, 1.5, 32, 32)];
    imgView.clipsToBounds = YES;
    imgView.layer.cornerRadius = imgView.height/2;
    [imgView sd_setImageWithURL:URL(model.receiverPic) placeholderImage:DEFAULTAVATAR];
    [self addSubview:imgView];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+2, 0, kMainScreenWidth, 35)];
    lab.text = model.receiver;
    lab.textColor = RGBCOLOR(220, 225, 53);
    lab.font = kFont12;
    [lab sizeToFit];
    [lab setHeight:35];
    [self addSubview:lab];
    
    lab = [[UILabel alloc] initWithFrame:CGRectMake(lab.right, 0, kMainScreenWidth, 35)];
    lab.text = @"收到";
    lab.textColor = kcolorWhite;
    lab.font = kFont12;
    [lab sizeToFit];
    [lab setHeight:35];
    [self addSubview:lab];
    
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(lab.right+2, 1.5, 32, 32)];
    imgView.clipsToBounds = YES;
    imgView.layer.cornerRadius = imgView.height/2;
    [imgView sd_setImageWithURL:URL(model.sendPic) placeholderImage:DEFAULTAVATAR];
    [self addSubview:imgView];
    
    lab = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+2, 0, kMainScreenWidth, 35)];
    lab.text = model.sender;
    lab.textColor = RGBCOLOR(220, 225, 53);
    lab.font = kFont12;
    [lab sizeToFit];
    [lab setHeight:35];
    [self addSubview:lab];
    
    lab = [[UILabel alloc] initWithFrame:CGRectMake(lab.right, 0, kMainScreenWidth, 35)];
    lab.text = [NSString stringWithFormat:@"送的%@", model.content];
    lab.textColor = kcolorWhite;
    lab.font = kFont14;
    [lab sizeToFit];
    [lab setHeight:35];
    [self addSubview:lab];
    
    WeakSelf(self)
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(lab.right+2, 1.5, 32, 32)];
    [imgView sd_setImageWithURL:URL(model.giftPic) placeholderImage:DEFAULTAVATAR completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(!error)
        {
            [imgView setWidth:32.0/image.size.height*image.size.width];
            [weakself setWidth:imgView.right+10];
        }
    }];
    [self addSubview:imgView];
    [self setWidth:imgView.right+10];
}
@end
