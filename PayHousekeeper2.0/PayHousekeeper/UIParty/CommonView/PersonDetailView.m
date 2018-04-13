//
//  PersonDetailView.m
//  PayHousekeeper
//
//  Created by sp on 2016/12/25.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PersonDetailView.h"
#import "UIViewAdditions.h"
#import "UIButton+WebCache.h"
#import "UserInfoData.h"
#import "NSStringEx.h"
#import "UIViewAdaptive.h"
#import "FMDBManager.h"

#define Screen_Width            [UIScreen mainScreen].bounds.size.width
#define Screen_Height           [UIScreen mainScreen].bounds.size.height
#define View_Margin             FitSize((Screen_Width-301)/2)
#define View_Width              FitSize(301)
#define View_Height             FitSize(423)
#define CloseBtn_Size           FitSize(23)
#define HeaderView_Size         FitSize(82)

#define SmallBtn_Width          FitSize(60)
#define SmallBtn_Height         FitSize(15)
#define CityBtn_Width           FitSize(80)
#define BottomBtn_Height        FitSize(45)
#define Btn_Height              FitSize(50)
#define Msg_Margin              FitSize(15)
#define Msg_Width               FitSize((self.frame.size.width-2*Msg_Margin))
#define View_Corner             FitSize(5)
#define LineSpace               FitSize(5)

#define Feature_ViewWidth             FitSize(84)
#define Feature_ViewHeight            FitSize(38)
#define Feature_ImageSize             FitSize(28)
#define Feature_LabelSize             FitSize(50)

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))


typedef enum
{
    tag_wealthLevel,
    tag_wealthValue,
    tag_charmLevel,
    tag_charmValue,
    tag_activeLevel,
    tag_activeValue,
}tagType;

@interface PersonDetailView ()
@property (nonatomic, strong) UIControl     *backgroundView;
@property (nonatomic, strong) UIButton      *headerBtn;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UIButton      *ageBtn;

@property (nonatomic, strong) UIButton      *starBtn;
@property (nonatomic, strong) UIButton      *levelBtn;
@property (nonatomic, strong) UILabel       *userIdLabel;
@property (nonatomic, strong) UIButton      *cityBtn;
@property (nonatomic, strong) UILabel       *feelingLabel;

@property (nonatomic, strong) UIButton      *wealthLevelBtn;
@property (nonatomic, strong) UIButton      *charmLevelBtn;
@property (nonatomic, strong) UIButton      *activeLevelBtn;
@property (nonatomic, strong) UIButton      *wealthValueBtn;
@property (nonatomic, strong) UIButton      *charmValueBtn;
@property (nonatomic, strong) UIButton      *activeValueBtn;


@property (nonatomic, assign) BOOL          isVisible;

@end

@implementation PersonDetailView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.baseRatio = RatioBaseOn_6_ScaleFor5;
    }
    return self;
}

- (instancetype)initWithDetailModel:(PersonDetailModel*)detailModel
{
    self = [self init];
    if (self)
    {
        self.frame = CGRectMake((Screen_Width-View_Width)/2, (Screen_Height-View_Height)/2, View_Width, View_Height);
        self.detailModel = detailModel;
        NSLog(@"profitValue====%@", self.detailModel.profitValue);
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = View_Corner;
        [self addSubviews];
        
    }
    return self;
}

- (void)addSubviews
{
    self.closeBtn = [self buttonWithFrame:CGRectMake(self.width-CloseBtn_Size-FitSize(11), FitSize(11), CloseBtn_Size, CloseBtn_Size) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"detailCloseBtn"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeBtn];
    
    if ([self.detailModel.leftBtnTitle length]>0)
    {
        self.leftBtn = [self buttonWithFrame:CGRectMake(FitSize(16), FitSize(15), FitSize(30), FitSize(30)) titleFont:FitFont(11) titleStateNorColor:ShortColor(0x99) titleStateNor:self.detailModel.leftBtnTitle];
//        self.leftBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.leftBtn];
        [self.leftBtn setImage:IMG(@"report") forState:UIControlStateNormal];
        [self.leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, (FitSize(30)-13)/2.0, FitSize(30)-13, (FitSize(30)-13)/2.0)];
        [self.leftBtn setTitleEdgeInsets:UIEdgeInsetsMake(FitSize(30)-13, -FitSize(30)/2.0+2, 0, 0)];
        
        UIButton *btn = [self buttonWithFrame:CGRectMake(FitSize(16), FitSize(16), FitSize(35), FitSize(30)) titleFont:FitFont(11) titleStateNorColor:ShortColor(0x99) titleStateNor:@"拉黑"];
        btn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [btn setX:self.leftBtn.right+12];
        [self addSubview:btn];
        [btn setImage:IMG(@"blacklist") forState:UIControlStateNormal];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, (FitSize(35)-13)/2.0, FitSize(30)-13, (FitSize(35)-13)/2.0)];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(FitSize(30)-13, -FitSize(35)/2.0+2, 0, 0)];
        [btn addTarget:self action:@selector(addToBlackList:) forControlEvents:UIControlEventTouchUpInside];
        if(self.detailModel.defriend)
        {
            [btn setTitle:@"已拉黑" forState:UIControlStateNormal];
        }
        
        if([DDSystemInfoManager sharedInstance].isOn)
        {
            NSMutableArray *arr = [[FMDBManager shareInstance] getBlackList:GETBLACKLIST];
            if([arr containsObject:self.detailModel.userId])
            {
                [btn setTitle:@"已拉黑" forState:UIControlStateNormal];
            }
        }
    }
    self.headerBtn = [self buttonWithFrame:CGRectMake((self.width-HeaderView_Size)/2, FitSize(52), HeaderView_Size, HeaderView_Size) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    //    [self.headerBtn setImage:[UIImage imageNamed:self.detailModel.headerImage] forState:UIControlStateNormal];
    [self.headerBtn sd_setBackgroundImageWithURL:URL(self.detailModel.headerImage) forState:UIControlStateNormal placeholderImage:DEFAULTAVATAR];
    self.headerBtn.userInteractionEnabled = NO;
    self.headerBtn.clipsToBounds = YES;
    self.headerBtn.layer.cornerRadius = self.headerBtn.height/2;
    
    [self addSubview:self.headerBtn];
    
    
    UIImageView *cornerView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headerBtn.frame) - 18 , CGRectGetMaxY(self.headerBtn.frame) - 18, 18, 18)];
    [self addSubview:cornerView];
    
    if (self.detailModel.cornerImage.length > 0)
    {
        cornerView.image = [UIImage imageNamed:self.detailModel.cornerImage];
    }
    else
    {
        cornerView.image = nil;
        cornerView.backgroundColor = [UIColor clearColor];
    }
    
    
    self.nameLabel = [self labelWithFrame:CGRectMake(15, self.headerBtn.bottom+FitSize(32), self.width-FitSize(2*15), FitSize(16)) text:self.detailModel.name textFont:FitFont(16) textColor:ShortColor(0x33)];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.nameLabel];
    NSString *sexImageName = @"male";
    UIColor *sexColor = RGBCOLOR(0, 114, 255);
    if ([self.detailModel.sex isEqualToString:@"2"])//女
    {
        sexImageName = @"female";
        sexColor = RGBCOLOR(251, 187, 187);
    }
    
    CGFloat ageWidth = [self.detailModel.age sizeWithFont:[UIFont systemFontOfSize:9]].width+25;
    CGFloat starWidth = [self.detailModel.startSign sizeWithFont:[UIFont systemFontOfSize:9]].width+12;
    if (kMainScreenWidth == 320) {
        starWidth += 5;
    }
    
    CGFloat levelWidth = [self.detailModel.level sizeWithFont:[UIFont systemFontOfSize:9]].width+25;
    self.ageBtn = [self getSmallBtn:CGRectMake((self.width-ageWidth-starWidth-levelWidth-12)/2, self.nameLabel.bottom+9, starWidth, SmallBtn_Height) title:self.detailModel.age imageName:sexImageName backgroundColor:sexColor font:11];
    
    [self addSubview:self.ageBtn];
    [self.ageBtn setImageEdgeInsets:UIEdgeInsetsMake(0, FitSize(-3), 0, 0)];
    [self.ageBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, FitSize(-3))];
    
    self.starBtn = [self getSmallBtn:CGRectMake(self.ageBtn.right+6, self.ageBtn.top, starWidth, SmallBtn_Height) title:self.detailModel.startSign imageName:nil backgroundColor:RGBCOLOR(132, 186, 225) font:9];
    [self addSubview:self.starBtn];
    
    self.levelBtn = [self getSmallBtn:CGRectMake(self.starBtn.right+6 ,self.ageBtn.top, starWidth, SmallBtn_Height) title:self.detailModel.level imageName:@"detailstar" backgroundColor:RGBCOLOR(254, 199, 48) font:10];
    [self addSubview:self.levelBtn];
    [self.levelBtn setImageEdgeInsets:UIEdgeInsetsMake(0, FitSize(-3), 0, 0)];
    [self.levelBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, FitSize(-3))];
    
    UIFont *userFont = [UIFont systemFontOfSize:12];
    
    NSString *userStr = [NSString stringWithFormat:@"咚咚号:%@",self.detailModel.userCode];
    CGSize  userSize = [userStr sizeWithFont:userFont];
    CGFloat cityWidth = [self.detailModel.city sizeWithFont:FitFont(12)].width+FitSize(14);
    self.userIdLabel = [self labelWithFrame:CGRectMake((self.width-userSize.width-cityWidth-FitSize(14))/2, self.ageBtn.bottom+FitSize(9), userSize.width+1, FitSize(13)) text:userStr textFont:userFont textColor:ShortColor(0x99)];
    [self addSubview:self.userIdLabel];
    
    self.cityBtn = [self getSmallBtn:CGRectMake(self.userIdLabel.right+FitSize(14), self.userIdLabel.top, cityWidth, FitSize(12)) title:self.detailModel.city imageName:@"detailAddressBtn" backgroundColor:[UIColor clearColor] font:9];
    [self.cityBtn setTitleColor:ShortColor(0x99) forState:UIControlStateNormal];
    [self.cityBtn setImageEdgeInsets:UIEdgeInsetsMake(0, FitSize(-3), 0, 0)];
    [self.cityBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, FitSize(-3))];
    [self addSubview:self.cityBtn];
    
    NSString *feelStr = self.detailModel.desc;
    UIFont  *feelFont = FitFont(14);
    self.feelingLabel = [[UILabel alloc] init];
    self.feelingLabel.numberOfLines = 0;
    self.feelingLabel.lineBreakMode =  NSLineBreakByWordWrapping;
    self.feelingLabel.backgroundColor = [UIColor whiteColor];
    self.feelingLabel.textColor = ShortColor(0x99);
    self.feelingLabel.font = feelFont;
    self.feelingLabel.text = feelStr;
    [self setLabelSpace:self.feelingLabel withValue:feelStr withFont:feelFont];
    CGFloat feelHeight  =  FitSize(41);
    self.feelingLabel.frame = CGRectMake(FitSize(15),self.cityBtn.bottom+FitSize(20),(int)(self.width-FitSize(30)), (int)feelHeight);
    self.feelingLabel.textAlignment = NSTextAlignmentCenter;


    [self addSubview:self.feelingLabel];
    
    self.wealthValueBtn = [self getBigBtn:CGRectMake((View_Width-3*Feature_ViewWidth-FitSize(22))/2, self.feelingLabel.bottom+FitSize(27), Feature_ViewWidth, Feature_ViewHeight) title:self.detailModel.wealthValueTitle value:self.detailModel.wealthValue titleimageName:self.detailModel.wealthImage backgroundColor:RGBCOLOR(246, 194, 51)];
    self.wealthValueBtn.tag = tag_wealthValue;
    [self.wealthValueBtn addTarget:self action:@selector(reverseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.wealthValueBtn];
    
    self.wealthLevelBtn = [self getBigBtn:self.wealthValueBtn.frame title:self.detailModel.wealthLevelTitle value:self.detailModel.wealthLevel titleimageName:self.detailModel.wealthImage backgroundColor:RGBCOLOR(246, 194, 51)];
    self.wealthLevelBtn.tag = tag_wealthLevel;
    [self.wealthLevelBtn addTarget:self action:@selector(reverseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.wealthLevelBtn];
    
 
    self.charmValueBtn = [self getBigBtn:CGRectMake(self.wealthLevelBtn.right+FitSize(11), self.feelingLabel.bottom+FitSize(27), Feature_ViewWidth, Feature_ViewHeight) title:self.detailModel.charmValueTitle  value:self.detailModel.charmValue titleimageName:self.detailModel.charmImage backgroundColor:RGBCOLOR(255, 133, 161)];
    [self.charmValueBtn addTarget:self action:@selector(reverseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.charmValueBtn.tag = tag_charmValue;
    [self addSubview:self.charmValueBtn];
    
    self.charmLevelBtn = [self getBigBtn:self.charmValueBtn.frame title:self.detailModel.charmLevelTitle  value:self.detailModel.charmLevel titleimageName:self.detailModel.charmImage backgroundColor:RGBCOLOR(255, 133, 161)];
    [self.charmLevelBtn addTarget:self action:@selector(reverseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.charmLevelBtn.tag = tag_charmLevel;
    [self addSubview:self.charmLevelBtn];

    self.activeValueBtn = [self getBigBtn:CGRectMake(self.charmLevelBtn.right +FitSize(11), self.feelingLabel.bottom+FitSize(27), Feature_ViewWidth, Feature_ViewHeight) title:self.detailModel.activeValueTitle value:self.detailModel.activeValue  titleimageName:self.detailModel.activeImage backgroundColor:RGBCOLOR(232, 170, 115)];
    [self.activeValueBtn addTarget:self action:@selector(reverseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.activeValueBtn.tag = tag_activeValue;
    [self addSubview:self.activeValueBtn];
    
    self.activeLevelBtn = [self getBigBtn:self.activeValueBtn.frame title:self.detailModel.activeLevelTitle value:self.detailModel.activeLevel titleimageName:self.detailModel.activeImage backgroundColor:RGBCOLOR(232, 170, 115)];
     [self.activeLevelBtn addTarget:self action:@selector(reverseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.activeLevelBtn.tag = tag_activeLevel;
    [self addSubview:self.activeLevelBtn];
    
    
    self.bottomBtn = [self buttonWithFrame:CGRectMake(0, self.height-BottomBtn_Height, self.width, BottomBtn_Height) titleFont:FitFont(14) titleStateNorColor:[UIColor whiteColor] titleStateNor:self.detailModel.bottomBtnTitle];
    if([self.detailModel.status isEqualToString:@"2"])
    {
        [self.bottomBtn setImage:IMG(@"follow_normal") forState:UIControlStateNormal];
        [self.bottomBtn setImage:IMG(@"follow_normal") forState:UIControlStateHighlighted];
        [self.bottomBtn setTitle:@"关注" forState:UIControlStateNormal];
    }
    else
    {
        
        UIImageView *tmpView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height-BottomBtn_Height - 1, self.width, BottomBtn_Height + 3)];
        tmpView.image = [UIImage imageNamed:@"bt_BG"];
        [self addSubview:tmpView];
        
        
        self.profitBtn = [self buttonWithFrame:CGRectMake(0, self.height-BottomBtn_Height, self.width/2, BottomBtn_Height) titleFont:FitFont(14) titleStateNorColor:[UIColor whiteColor] titleStateNor:self.detailModel.bottomBtnTitle];
        
        // 视频模块的收益值的显示是使用 shellCount 这个字段的
//        NSString *prStr = self.detailModel.profitValue;
        NSString *prStr = [NSString stringWithFormat:@"%lld", [UserInfoData shareUserInfoData].shellCount];
        if (prStr == nil || [prStr isEqualToString:@"(null)"] || [prStr isEqualToString:@"null"]) {
            NSLog(@"prStr=====%@", prStr);
        }
        [self.profitBtn setTitle:[NSString stringWithFormat:@"收益（%@）", prStr] forState:UIControlStateNormal];
//        self.profitBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//        self.profitBtn.backgroundColor = RGBCOLOR(53, 234, 190);
        [self.profitBtn setBackgroundImage:[UIImage imageNamed:@"Normal_BG"] forState:UIControlStateNormal];
        [self.profitBtn setBackgroundImage:[UIImage imageNamed:@"bt_BG"] forState:UIControlStateHighlighted];
//        [self.profitBtn setImage:[UIImage imageNamed:@"dongguo3"] forState:UIControlStateNormal];
//        [self.profitBtn setImage:[UIImage imageNamed:@"dongguo3"] forState:UIControlStateHighlighted];
        [self.profitBtn setImageEdgeInsets:UIEdgeInsetsMake(0, FitSize(-6), 0, 0)];
        [self.profitBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, FitSize(-6))];
        [self addSubview:self.profitBtn];

        self.bottomBtn.frame = CGRectMake(self.width/2, self.height-BottomBtn_Height, self.width/2, BottomBtn_Height);
//        self.bottomBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.bottomBtn setTitle:@"个人中心" forState:UIControlStateNormal];
        [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"Normal_BG"] forState:UIControlStateNormal];
        [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"bt_BG"] forState:UIControlStateHighlighted];
//        [self.bottomBtn setImage:[UIImage imageNamed:@"personCenter"] forState:UIControlStateNormal];
//        [self.bottomBtn setImage:[UIImage imageNamed:@"personCenter"] forState:UIControlStateHighlighted];
        [self.bottomBtn setImageEdgeInsets:UIEdgeInsetsMake(0, FitSize(-6), 0, 0)];
        [self.bottomBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, FitSize(-6))];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.width/2 - 0.5, self.profitBtn.top+(BottomBtn_Height-FitSize(36))/2, 1, FitSize(36))];
        line.backgroundColor = [UIColor whiteColor];
        [self addSubview:line];

    }
//    self.bottomBtn.backgroundColor = RGBCOLOR(53, 234, 190);
    [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"Normal_BG"] forState:UIControlStateNormal];
    [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"bt_BG"] forState:UIControlStateHighlighted];
    [self.bottomBtn setImageEdgeInsets:UIEdgeInsetsMake(0, FitSize(-6), 0, 0)];
    [self.bottomBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, FitSize(-6))];
    
    [self addSubview:self.bottomBtn];
}

- (void)addToBlackList:(UIButton *)btn
{
    if([DDSystemInfoManager sharedInstance].isOn)
    {
        [btn setTitle:@"已拉黑" forState:UIControlStateNormal];
        NSString *insertStr = ADDBLACKLIST(self.detailModel.userId);
        [[FMDBManager shareInstance] insertData:insertStr];
    }
    else
    {
        WeakSelf(self)
        NSDictionary *dic = @{@"accid":[UserInfoData shareUserInfoData].strUserId,
                              @"targetId":self.detailModel.userId,
                              @"type":self.detailModel.defriend?@"1":@"0"};
        [NetManager requestWith:dic apiName:kDeFriendAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            weakself.detailModel.defriend = !weakself.detailModel.defriend;
            [btn setTitle:weakself.detailModel.defriend?@"已拉黑":@"拉黑" forState:UIControlStateNormal];
            [DLAPPDELEGATE showToastView:(weakself.detailModel.defriend?@"已拉黑":@"已取消拉黑") duration:1 position:CSToastPositionCenter];
        } failure:^(NSDictionary *failDict, NSError *error) {
        }];
    }
}

- (UIButton *)getBigBtn:(CGRect)frame title:(NSString *)title value:(NSString *)value titleimageName:(NSString *)imageName backgroundColor:(UIColor *)color
{
    UIButton *btn = [[UIButton alloc]initWithFrame:frame];
    btn.backgroundColor = color;
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = frame.size.height/2;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(FitSize(5), (btn.height-Feature_ImageSize)/2, Feature_ImageSize, Feature_ImageSize)];
    [imageView setImage:[UIImage imageNamed:imageName]];
    [btn addSubview:imageView];
    
    UILabel *titleLabel= [self labelWithFrame:CGRectMake(imageView.right+FitSize(5), (btn.height-FitSize(26))/2 + 3, Feature_LabelSize, FitSize(9)) text:title textFont:FitFont(9) textColor:[UIColor whiteColor]];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [btn addSubview:titleLabel];
    
    UIFont *valueFont = FitFont(11);
    
    CGSize valueSize = [value sizeWithFont:valueFont];
    
    UILabel *valueLabel= [self labelWithFrame:CGRectMake(imageView.right+FitSize(5), titleLabel.bottom+FitSize(5), MIN(valueSize.width + 30, Feature_LabelSize-FitSize(20)), FitSize(11)) text:value textFont:valueFont textColor:[UIColor whiteColor]];
    valueLabel.textAlignment = NSTextAlignmentLeft;
    // 粗体
    valueLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.f];
    [btn addSubview:valueLabel];
    
    return btn;
}

- (UIButton *)getSmallBtn:(CGRect)frame title:(NSString *)title imageName:(NSString *)imageName backgroundColor:(UIColor *)color font:(CGFloat)font
{
    UIButton *btn = [[UIButton alloc]initWithFrame:frame];

    btn.backgroundColor = color;
    btn.titleLabel.font = FitFont(font);
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = frame.size.height/2;
    [btn setTitle:title forState:UIControlStateNormal];
    if ([imageName length]>0)
    {
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
    }    
    
    return btn;
}

- (CGFloat)heightForLabel:(NSString *)message font:(UIFont *)font
{
    CGFloat minHeight = 1 * font.lineHeight;
    
    CGFloat maxHeight = 2 * font.lineHeight;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:LineSpace];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.hyphenationFactor = 1.0;
    paragraphStyle.firstLineHeadIndent = 0.0;
    paragraphStyle.paragraphSpacingBefore = 0.0;
    paragraphStyle.headIndent = 0;
    paragraphStyle.tailIndent = 0;
    
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGRect rect = [message boundingRectWithSize:CGSizeMake(Msg_Width, maxHeight)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:attributes
                                        context:nil];
    
    return MAX(minHeight, ceil(rect.size.height));
    
    
    
    return minHeight;
}

- (void)reverseBtnClicked:(UIButton *)senderBtn
{
    if ([self.detailModel.status isEqualToString:@"2"])
    {
        return;
    }
    
    
    if (senderBtn.tag == tag_wealthLevel)
    {
         [self reverseFromView:self.wealthLevelBtn to:self.wealthValueBtn];
        
    }
    else if(senderBtn.tag == tag_wealthValue)
    {
         [self reverseFromView:self.wealthValueBtn to:self.wealthLevelBtn];
    }
    else if(senderBtn.tag == tag_charmLevel)
    {
        [self reverseFromView:self.charmLevelBtn to:self.charmValueBtn];
    }
    else if(senderBtn.tag == tag_charmValue)
    {
        [self reverseFromView:self.charmValueBtn to:self.charmLevelBtn];
    }
    else if(senderBtn.tag == tag_activeLevel)
    {
        [self reverseFromView:self.activeLevelBtn to:self.activeValueBtn];
    }
    else if(senderBtn.tag == tag_activeValue)
    {
        [self reverseFromView:self.activeValueBtn to:self.activeLevelBtn];
    }
   
}
//给UILabel设置行间距和字间距
-(void)setLabelSpace:(UILabel*)label withValue:(NSString*)str withFont:(UIFont*)font {
    if([str length]<=0)
    {
        return;
    }
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentCenter;
    paraStyle.lineSpacing = LineSpace; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSParagraphStyleAttributeName:paraStyle,
                          NSKernAttributeName:@1.5f};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:str attributes:dic];
    label.attributedText = attributeStr;
}
- (void)reverseFromView:(UIView *)fromView to:(UIView *)toView
{
    UIViewAnimationOptions option =  UIViewAnimationOptionTransitionFlipFromLeft;

    [UIView transitionWithView:toView
                      duration:0.5f
                       options:option
                    animations:^ {
                        [fromView removeFromSuperview];
                        [self addSubview:toView];
                    }
                    completion:^ (BOOL finished){
                    }];
}
- (UIView *)backgroundView
{
    if (_backgroundView == nil)
    {
        _backgroundView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, Screen_Height, Screen_Height)];
        _backgroundView.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
        _backgroundView.userInteractionEnabled = YES;
        [_backgroundView addTarget:self action:@selector(backgroundTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backgroundView;
}
- (void)show
{
    if (self.isVisible)
    {
        return;
    }
    self.isVisible = YES;
    [self.backgroundView addSubview:self];
    UIWindow *showWindow = [[UIApplication sharedApplication] keyWindow];
    [showWindow addSubview:self.backgroundView];
}
- (void)showInView:(UIView *)view
{
    if (self.isVisible)
    {
        return;
    }
    self.isVisible = YES;
    [self.backgroundView addSubview:self];
    [view addSubview:self.backgroundView];
}
- (void)dismiss
{
    self.isVisible = NO;
    [self.backgroundView removeFromSuperview];
    [self removeFromSuperview];
    
}
- (void)backgroundTaped:(id)sender
{
    [self dismiss];
}
@end
