//
//  BuyDBOrderView.m
//  PayHousekeeper
//
//  Created by striveliu on 2016/11/19.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BuyDBOrderView.h"
#import "NSStringEX.h"
#import "UIButton+WGBCustom.h"

@interface BuyDBOrderView()<UITextFieldDelegate>
{
    UIView *bgView;
    int currentDBCount;
    int dbeiCount;
    //    CGFloat payMoney;
    NSMutableString *convCount;
    UITextField *dbInput;
    UILabel *bLabel;
    CGFloat rule;
}
@property (nonatomic, copy) void(^buttonItemBlcok)(int index);
@property (nonatomic, copy) void(^covbuttonItemBlcok)(int index, NSString *covcount);
@end

@implementation BuyDBOrderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kClearColor;
        bgView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:bgView];
    }
    return self;
}

- (void)setConvRule:(CGFloat)aRule
{
    rule = aRule;
}

- (void)setBGColor:(UIColor *)aColor alpha:(CGFloat)aAlpha
{
    bgView.backgroundColor = aColor;
    bgView.alpha = aAlpha;
}

- (void)createOrderview:(NSString *)aShellCount clickBlock:(void(^)(int buttonTag,NSString *convcount))aBlock
{
    self.covbuttonItemBlcok = aBlock;
    UIView *orderview = [[UIView alloc] initWithFrame:CGRectMake(25, (self.height-237)/2, self.width-25*2, 237)];
    orderview.backgroundColor = kcolorWhite;
    [self addSubview:orderview];
    NSString *currentDB = [NSString stringWithFormat:@"当前咚币%@",aShellCount];
    CGSize csize = [currentDB sizeWithFont:[UIFont systemFontOfSize:17]];
    int topx = (orderview.width-25-10-csize.width+2)/2;
    UIImageView *iconImgview = [[UIImageView alloc] initWithFrame:CGRectMake(topx, 18, 25, 18)];
    [iconImgview setImage:[UIImage imageNamed:@"dongguoIcon"]];
    iconImgview.backgroundColor = [UIColor clearColor];
    [orderview addSubview:iconImgview];
    
    UILabel *tLabel = [self labelWithFrame:CGRectMake(iconImgview.right+10, 19, csize.width+2, 20) text:currentDB textFont:[UIFont systemFontOfSize:17] textColor:kShortColor(0x33)];
    [orderview addSubview:tLabel];
    //继续构造购买咚币页面
    
    UIView *line = [self getViewLine:CGRectMake(0, 52, orderview.width, kLineWidth)];
    [orderview addSubview:line];
    
    UILabel *dLabel = [self labelWithFrame:CGRectMake(15, 75, orderview.width-30,17) text:@"我要兑换的咚果" textFont:[UIFont systemFontOfSize:14] textColor:kShortColor(0x33)];
    [orderview addSubview:dLabel];
    
    dbInput = [[UITextField alloc] initWithFrame:CGRectMake(20, dLabel.bottom+16, orderview.width-40, 33)];
    dbInput.backgroundColor = kcolorWhite;
    dbInput.font = kFont17;
    dbInput.delegate = self;
    dbInput.textColor = kShortColor(0x33);
    dbInput.placeholder = @"请输入咚币数量";
    dbInput.textAlignment = NSTextAlignmentCenter;
    dbInput.layer.cornerRadius = 4.0f;
    dbInput.layer.borderWidth = kLineWidth;
    dbInput.layer.borderColor = kLineColor.CGColor;
    dbInput.keyboardType = UIKeyboardTypeNumberPad;
    [orderview addSubview:dbInput];
    
    NSString *strDBeiCount = [NSString stringWithFormat:@"将获得%d咚贝",dbeiCount];
    bLabel = [self labelWithFrame:CGRectMake(0, dbInput.bottom+16, orderview.width, 16) text:strDBeiCount textFont:[UIFont systemFontOfSize:14] textColor:kShortColor(0x99)];
    bLabel.textAlignment = NSTextAlignmentCenter;
    [orderview addSubview:bLabel];
    
    UIView *bline = [self getViewLine:CGRectMake(0, orderview.height-43, orderview.width, kLineWidth)];
    [orderview addSubview:bline];
    
    UIButton *cancelBt = [self buttonWithFrame:CGRectMake(0, orderview.height-42, (orderview.width-1)/2, 42) titleFont:[UIFont systemFontOfSize:17] titleStateNorColor:kShortColor(0x33) titleStateNor:@"取消"];
    cancelBt.tag = buttonItem_close;
    [cancelBt addTarget:self action:@selector(buttomItem:) forControlEvents:UIControlEventTouchUpInside];
    [orderview addSubview:cancelBt];
    
    UIButton *buyBt = [self buttonWithFrame:CGRectMake((orderview.width-1)/2, orderview.height-42, (orderview.width-1)/2, 42) titleFont:[UIFont systemFontOfSize:17] titleStateNorColor:kShortColor(0x33) titleStateNor:@"兑换"];
    buyBt.tag = buttonItem_ok;
    [buyBt setTitleColor:kFcolorFontGreen forState:UIControlStateNormal];
    [buyBt addTarget:self action:@selector(buttomItem:) forControlEvents:UIControlEventTouchUpInside];
    [orderview addSubview:buyBt];
    
    UIView *mdline = [self getViewLine:CGRectMake((orderview.width)/2, bline.bottom, kLineWidth, orderview.height-bline.bottom)];
    [orderview addSubview:mdline];
    
    orderview.layer.cornerRadius = 8.0f;
}
#pragma mark textfieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    convCount = [textField.text mutableCopy];
    [convCount replaceCharactersInRange:range withString:string];
    dbeiCount = [convCount intValue]*rule;
    NSString *strDBeiCount = [NSString stringWithFormat:@"将获得%d咚贝",dbeiCount];
    bLabel.text = strDBeiCount;
    return YES;
}

#pragma mark buttonItem
-(void)buttomItem:(UIButton *)aBt
{
    if(self.covbuttonItemBlcok)
    {
        self.covbuttonItemBlcok((int)aBt.tag, convCount);
    }
}

#pragma mark 充值页面
- (void)createChongzhiView:(NSString *)aBuyValue clickBlock:(void(^)(int index))aClickBlock
{
    [self createChongzhiView:aBuyValue containsApplePay:NO clickBlock:aClickBlock];
}
- (void)createChongzhiView:(NSString *)aBuyValue  containsApplePay:(BOOL)contains clickBlock:(void(^)(int index))aClickBlock
{
    self.buttonItemBlcok = aClickBlock;
    UIView *payview = [[UIView alloc] initWithFrame:CGRectMake(30, (self.height-204)/2, (self.width-30*2), 204)];
    payview.backgroundColor = kcolorWhite;
    payview.layer.cornerRadius = 8.0f;
    [self addSubview:payview];
    
    UIButton *closeBt = [self buttonWithFrame:CGRectMake(payview.width-13-23, 13, 23, 23) titleFont:nil titleStateNorColor:nil titleStateNor:nil];
    [closeBt setImage:[UIImage imageNamed:@"buyvip_close"] forState:UIControlStateNormal];
    closeBt.tag = buttonItem_close;
    [closeBt addTarget:self action:@selector(payButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    closeBt.backgroundColor = kClearColor;
    //    closeBt.layer.cornerRadius = 15.0f;
    [payview addSubview:closeBt];
    
    
    UILabel *valueLabel = [self labelWithFrame:CGRectMake(0, 42, payview.width, 32) text:aBuyValue textFont:[UIFont systemFontOfSize:30] textColor:kShortColor(51)];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [payview addSubview:valueLabel];
    
    UIView *valueline = [self getViewLine:CGRectMake(16, valueLabel.bottom+15, payview.width-32, kLineWidth)];
    valueline.backgroundColor = kShortColor(238);
    [payview addSubview:valueline];
    
    
    UIImage *wximg = [UIImage imageNamed:@"wxPayBt"];
    UIButton *wxzfBt = [[UIButton alloc] initWithFrame:CGRectMake(17, valueline.bottom, payview.width-34, 58)];
    wxzfBt.tag = buttonItem_wxPay;
    [wxzfBt addTarget:self action:@selector(payButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    [payview addSubview:wxzfBt];
    
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(17, (wxzfBt.height-wximg.size.height)/2, wximg.size.width, wximg.size.height)];
    [imgview setImage:wximg];
    [wxzfBt addSubview:imgview];
    
    UILabel *wxtitle = [self labelWithFrame:CGRectMake(imgview.right+15, 0, 80, wxzfBt.height) text:@"微信支付" textFont:kFont17 textColor:kShortColor(51)];
    [wxzfBt addSubview:wxtitle];
    
    UIView *wxzfBtline = [self getViewLine:CGRectMake(16, wxzfBt.bottom-kLineWidth, payview.width-32, kLineWidth)];
    wxzfBtline.backgroundColor = kShortColor(238);
    [payview addSubview:wxzfBtline];
    
    
    
    UIImage *alipayimg = [UIImage imageNamed:@"alipayBt"];
    UIButton *zfbBt = [[UIButton alloc] initWithFrame:CGRectMake(17, wxzfBt.bottom, payview.width-34, 58)];
    zfbBt.tag = buttonItem_aliPay;
    [zfbBt addTarget:self action:@selector(payButtonItem:) forControlEvents:UIControlEventTouchUpInside];
    [payview addSubview:zfbBt];
    
    UIImageView *alipayimgview = [[UIImageView alloc] initWithFrame:CGRectMake(15, (zfbBt.height-alipayimg.size.height)/2, alipayimg.size.width, alipayimg.size.height)];
    [alipayimgview setImage:alipayimg];
    [zfbBt addSubview:alipayimgview];
    
    UILabel *alipaytitle = [self labelWithFrame:CGRectMake(alipayimgview.right+15, 0, 100, zfbBt.height) text:@"支付宝支付" textFont:kFont17 textColor:kShortColor(51)];
    [zfbBt addSubview:alipaytitle];
    
    if(contains == YES)
    {
        payview.height = payview.height+58;
        UIView *alipayBtline = [self getViewLine:CGRectMake(16, zfbBt.bottom-kLineWidth, payview.width-32, kLineWidth)];
        alipayBtline.backgroundColor = kShortColor(238);
        [payview addSubview:alipayBtline];
        UIImage *applepayimg = [UIImage imageNamed:@"applepayBt"];
        UIButton *appleBt = [[UIButton alloc] initWithFrame:CGRectMake(17, zfbBt.bottom, payview.width-34, 58)];
        appleBt.tag = buttonItem_applePay;
        [appleBt addTarget:self action:@selector(payButtonItem:) forControlEvents:UIControlEventTouchUpInside];
        [payview addSubview:appleBt];
        
        UIImageView *applepayimgview = [[UIImageView alloc] initWithFrame:CGRectMake(15, (appleBt.height-applepayimg.size.height)/2, applepayimg.size.width, applepayimg.size.height)];
        [applepayimgview setImage:applepayimg];
        [appleBt addSubview:applepayimgview];
        
        UILabel *applepaytitle = [self labelWithFrame:CGRectMake(applepayimgview.right+15, 0, 100, appleBt.height) text:@"苹果支付" textFont:kFont17 textColor:kShortColor(51)];
        [appleBt addSubview:applepaytitle];
    }
}
- (void)payButtonItem:(UIButton *)aTag
{
    if(self.buttonItemBlcok)
    {
        self.buttonItemBlcok((int)aTag.tag);
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


@end
