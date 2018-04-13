//
//  PersonHeaderView.m
//  PayHousekeeper
//
//  Created by sp on 2016/12/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonHeaderView.h"
#import "UIViewAdditions.h"
#import "UIButton+WebCache.h"
#import "AppDelegate.h"

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#define TopViewHeight    50
#define BottomViewHeight 25
#define SmallBtnWidth    34
#define SmallBtnHeight   15

@interface PersonHeaderView ()

@property (nonatomic, strong) UIView        *topView;

@property (nonatomic, strong) UIImageView   *cornerImage;

@property (nonatomic, strong) UIButton      *starBtn;
@property (nonatomic, strong) UIButton      *likeBtn;

@property (nonatomic, strong) UIImageView   *feelingImage;
@property (nonatomic, strong) UILabel       *feelingLabel;


@end

@implementation PersonHeaderView

- (instancetype)initWithHeaderModel:(PersonHeaderModel*)headerModel
{
    self = [super init];
    if (self)
    {
        self.headerModel = headerModel;
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame headerModel:(PersonHeaderModel*)headerModel
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.headerModel = headerModel;
//        self.backgroundColor = [UIColor grayColor];
        [self initSubViewFrame];
        
    }
    return self;
}

- (void)initSubViewFrame
{
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, TopViewHeight)];
    self.topView.backgroundColor = RGBACOLOR(0, 0, 0, 0.2);
    self.topView.layer.masksToBounds = YES;
    self.topView.layer.cornerRadius = self.topView.height/2;
 
    [self addSubview:self.topView];
    [self addSubViewsOnTopView];
    
    self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.topView.bottom+10, self.width, BottomViewHeight)];
    self.bottomView.layer.masksToBounds = YES;
    self.bottomView.layer.cornerRadius = self.bottomView.height/2;
    self.bottomView.backgroundColor = RGBACOLOR(0, 0, 0, 0.2);
    [self addSubview:self.bottomView];
    [self addSubViewsOnBottomView];
    
}
- (void)addSubViewsOnTopView
{
    self.headerBtn = [self buttonWithFrame:CGRectMake(0, 0, self.topView.height, self.topView.height) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    self.headerBtn.layer.masksToBounds = YES;
    self.headerBtn.layer.cornerRadius = self.headerBtn.height/2;
    [self.headerBtn sd_setBackgroundImageWithURL:URL(self.headerModel.headerImage) forState:UIControlStateNormal placeholderImage:DEFAULTAVATAR];
//    WeakSelf(self);
    [self.headerBtn sd_setBackgroundImageWithURL:URL(self.headerModel.headerImage) forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
        del.headUserImg = image;
        [self.headerBtn setBackgroundImage:image forState:UIControlStateNormal];
    }];
    [self.topView addSubview:self.headerBtn];
    
    if([self.headerModel.cornerImage length]>0)
    {
        UIImageView *cornerView = [[UIImageView alloc]initWithFrame:CGRectMake(self.headerBtn.right-self.headerBtn.width*0.28, self.headerBtn.bottom-self.headerBtn.height*0.28, 13, 13)];
        [cornerView setImage:[UIImage imageNamed:self.headerModel.cornerImage]];
        [self.topView addSubview:cornerView];
    }
    self.nameLabel = [self labelWithFrame:CGRectMake(self.headerBtn.right+5, (TopViewHeight-SmallBtnHeight-15-5)/2, self.width-2*TopViewHeight-10, 15) text:self.headerModel.name textFont:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor]];
    [self.topView addSubview:self.nameLabel];
    
    if ([self.headerModel.status isEqualToString:@"1"])//主人态
    {
        self.attentionBtn = [self buttonWithFrame:CGRectMake(self.nameLabel.right+5, 0, self.topView.height, self.topView.height) titleFont:[UIFont systemFontOfSize:13] titleStateNorColor:kFcolorFontGreen titleStateNor:nil];
        [self.attentionBtn setImage:[UIImage imageNamed:@"personalCenterIcon_normal"] forState:UIControlStateNormal];
//        [self.attentionBtn setImage:[UIImage imageNamed:@"personalCenterIcon_pressed"] forState:UIControlStateHighlighted];
        [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@"personalCenterIcon_pressed"] forState:UIControlStateHighlighted];
        self.attentionBtn.backgroundColor = RGBACOLOR(0, 0, 0,0.1);
        [self.topView addSubview:self.attentionBtn];
    }
    else if([self.headerModel.status isEqualToString:@"2"])//客人态
    {
        self.attentionBtn = [self buttonWithFrame:CGRectMake(self.nameLabel.right+5, 0, self.topView.height, self.topView.height) titleFont:[UIFont systemFontOfSize:13] titleStateNorColor:kFcolorFontGreen titleStateNor:@"关注"];
        self.attentionBtn.backgroundColor = RGBACOLOR(0, 0, 0,0.1);
        [self.topView addSubview:self.attentionBtn];
    }
    
    self.starBtn = [self getSmallBtn:CGRectMake(self.nameLabel.left, self.nameLabel.bottom+5, SmallBtnWidth, SmallBtnHeight) title:self.headerModel.stone imageName:@"wealthIcon" backgroundImageName:@"wealthBG"];
    [self.topView addSubview:self.starBtn];
    
     self.likeBtn = [self getSmallBtn:CGRectMake(self.starBtn.right+10, self.nameLabel.bottom+5, SmallBtnWidth, SmallBtnHeight) title:self.headerModel.like imageName:@"charmIcon" backgroundImageName:@"charmBG"];
    [self.topView addSubview:self.likeBtn];
    
    self.connectTipLab = [self labelWithFrame:CGRectMake(self.nameLabel.x, self.starBtn.y, self.nameLabel.width, SmallBtnHeight) text:@"" textFont:[UIFont systemFontOfSize:13] textColor:[UIColor whiteColor]];
    [self.topView addSubview:self.connectTipLab];
    self.connectTipLab.hidden = YES;
}

- (void)addSubViewsOnBottomView
{
    self.feelingImage = [[UIImageView alloc]init];
    if ([self.headerModel.status isEqualToString:@"1"])//主人态
        [self.feelingImage setImage:[UIImage imageNamed:@"changeFeel"]];
    else if([self.headerModel.status isEqualToString:@"2"])//客人态
        [self.feelingImage setImage:[UIImage imageNamed:@"feeling"]];
    [self.bottomView addSubview:self.feelingImage];
    self.feelingImage.frame = CGRectMake(5, (self.bottomView.height-self.feelingImage.image.size.height)/2.0, self.feelingImage.image.size.width, self.feelingImage.image.size.height);
    
    self.feelingLabel = [self labelWithFrame:CGRectMake(self.feelingImage.right+5, 0, self.width-self.feelingImage.right-5, self.bottomView.height) text:@"" textFont:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
    self.feelingLabel.textAlignment = NSTextAlignmentLeft;
    [self.bottomView addSubview:self.feelingLabel];
  
    [self setFeeling:self.headerModel.desc];
    
   

    
//    if ([self.headerModel.status isEqualToString:@"1"])//主人态
//    {
//        self.feelingTextField =[[UITextField alloc]initWithFrame:CGRectMake(self.feelingImage.right+1, 0, self.width-self.feelingImage.right-1, self.bottomView.height)];
//        self.feelingTextField.font = [UIFont systemFontOfSize:13];
//        if([self.headerModel.placeHolder length]>0)
//        {
//            self.feelingTextField.placeholder = self.headerModel.placeHolder;
//        }
//        [self.bottomView addSubview:self.feelingTextField];
//    }
//    else if([self.headerModel.status isEqualToString:@"2"])//客人态
//    {
//        self.feelingLabel =[self labelWithFrame:CGRectMake(self.feelingImage.right+1, 0, self.width-self.feelingImage.right-1, self.bottomView.height) text:self.headerModel.desc textFont:[UIFont systemFontOfSize:13] textColor:[UIColor whiteColor]];
//        self.feelingLabel.textAlignment = NSTextAlignmentLeft;
//        [self.bottomView addSubview:self.feelingLabel];
//    }

}
- (UIButton *)getSmallBtn:(CGRect)frame title:(NSString *)title imageName:(NSString *)imageName backgroundImageName:(NSString *)backgroundImageName
{
    UIButton *btn = [[UIButton alloc]initWithFrame:frame];
    if ([backgroundImageName length]>0)
        [btn setBackgroundImage:[UIImage imageNamed:backgroundImageName] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:11];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = frame.size.height/2;
    [btn setTitle:title forState:UIControlStateNormal];
    if ([imageName length]>0)
    {
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    btn.userInteractionEnabled = NO;
    return btn;
}

- (void)setFeeling:(NSString *)feeling
{
    _feeling = feeling;
    if ([self.headerModel.status isEqualToString:@"1"])//主人态
    {
        if(_feeling.length > 0)
        {
            self.feelingLabel.text = _feeling;
            self.feelingLabel.textColor = kcolorWhite;
        }
        else
        {
            self.feelingLabel.text = @"把你的心情写在这里吧";
            self.feelingLabel.textColor = RGBCOLOR(210, 210, 210);
        }
    }
    else if([self.headerModel.status isEqualToString:@"2"])//客人态
    {
        if(_feeling.length > 0)
        {
            self.feelingLabel.text = _feeling;
            self.feelingLabel.textColor = kcolorWhite;
        }
        else
        {
            self.bottomView.hidden = YES;
            return;
        }
    }
    
    self.bottomView.hidden = NO;
    [self.feelingLabel sizeToFit];
    float width = MIN(self.feelingLabel.right+10, self.width);
    [self.feelingLabel setHeight:self.bottomView.height];
    [self.bottomView setWidth:width];
    [self.feelingLabel setWidth:self.width-10-self.feelingImage.width];
}

- (void)needToShowTipLab:(BOOL)isShow andShowContent:(NSString *)content
{
    self.bottomView.hidden = isShow;
    self.connectTipLab.hidden = !isShow;
    self.likeBtn.hidden = isShow;
    self.starBtn.hidden = isShow;
    self.connectTipLab.text = content;
    [self.connectTipLab sizeToFit];
    [self.connectTipLab setHeight:SmallBtnHeight];
    
    [self.nameLabel sizeToFit];
    [self.nameLabel setHeight:15];
    
    float maxLabWidth = MAX(self.nameLabel.right, (isShow?self.connectTipLab.right:self.likeBtn.right));
    float width = MIN(kMainScreenWidth-115, maxLabWidth+(isShow?15:self.topView.height+5));
    [self.nameLabel setWidth:maxLabWidth];
    [self.connectTipLab setWidth:maxLabWidth];
    [self.attentionBtn setRight:width];
    [self setWidth:width];
    [self.topView setWidth:width];
    self.attentionBtn.hidden = isShow;
    
    if(!isShow)
    {
        [self.nameLabel setWidth:self.attentionBtn.x-self.headerBtn.right-5];
        [self setFeeling:_feeling];
    }
}

- (void)refresh:(PersonHeaderModel*)headerModel
{
    self.headerModel = headerModel;
    [self.headerBtn sd_setImageWithURL:URL(self.headerModel.headerImage) forState:UIControlStateNormal placeholderImage:DEFAULTAVATAR];
    self.nameLabel.text = self.headerModel.name;
    [self.starBtn setTitle:self.headerModel.stone forState:UIControlStateNormal];
    [self.likeBtn setTitle:self.headerModel.like forState:UIControlStateNormal];
    [self setFeeling:self.headerModel.desc];
}

@end
