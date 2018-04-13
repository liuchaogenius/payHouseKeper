//
//  InviteFriendViewController.m
//  PayHousekeeper
//
//  Created by sp on 2016/12/31.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "InviteFriendViewController.h"
#import "UIViewAdditions.h"
#import "PersonInfoManager.h"
#import "NSStringTool.h"
#import <SDWebImage/UIButton+WebCache.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "UserInfoData.h"
#import "AppDelegate.h"
#import "UIImage+ImageEffects.h"

#define RankViewHeight     136
#define ShareViewHeight    216.5
#define ShareItemWidth     50
#define ShareItemHeight    54.5

#define shareTitle @"我的故事有点多，你敢看，我敢播"
#define shareDesc  [NSString stringWithFormat:@"「%@」邀请你来咚咚视频速配！", [UserInfoData shareUserInfoData].strUserNick]
#define shareUrl   [NSString stringWithFormat:@"http://moqukeji.top/invite.html?%@",self.data.inviteCode]

@interface InviteFriendViewController ()

@property (nonatomic, strong) PersonInfoManager  *personInfoManager;
@property (nonatomic, strong) InviateData        *data;
@property (nonatomic, strong) UIView             *earningView;//收益模块view
@property (nonatomic, strong) UIView             *inviteViewView;//邀请模块view
@property (nonatomic, strong) UIView             *rankView;//排行榜模块view
@property (nonatomic, strong) UIView             *shareView;//分享模块view
@property (nonatomic, strong) UIImage            *shareImage;


@end

@implementation InviteFriendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self settitleLabel:@"邀请好友"];
    self.personInfoManager = [[PersonInfoManager alloc]init];
    [self.personInfoManager requestInviateData:^(InviateData *data) {
        self.data = data;
        [self createEarningView];
        [self createInviteView];
        [self createRankView];
    }];

    self.shareImage = [UIImage imageNamed:@"personInfoheadimg"];
    WeakSelf(self)
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[UserInfoData shareUserInfoData].strHeadUrl] options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        if (image)
        {
            weakself.shareImage = image;
        }
    }];
}

- (void)createEarningView
{
    self.earningView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 118)];
    self.earningView.backgroundColor = RGBCOLOR(0x21, 0xeb, 0xbe);
    [self.view addSubview:self.earningView];
    
    UILabel *desLabel = [self.earningView labelWithFrame:CGRectMake(kComm_Content_Margin, 13, 80, 13) text:@"收益合计" textFont:[UIFont systemFontOfSize:13] textColor:[UIColor whiteColor]];
    
    [self.earningView addSubview:desLabel];
    
    UILabel *totlaLabel = [self.earningView labelWithFrame:CGRectMake(kComm_Content_Margin, 35, self.earningView.width-2*kComm_Content_Margin, 28) text:[NSString stringWithFormat:@"%.0f",self.data.income] textFont:[UIFont systemFontOfSize:28] textColor:[UIColor whiteColor]];
    totlaLabel.textAlignment = NSTextAlignmentCenter;
    [self.earningView addSubview:totlaLabel];
    
    UILabel *unitLabel = [self.earningView labelWithFrame:CGRectMake(kComm_Content_Margin, totlaLabel.bottom+12, self.earningView.width-2*kComm_Content_Margin, 15) text:@"咚果" textFont:[UIFont systemFontOfSize:15] textColor:[UIColor whiteColor]];
    unitLabel.textAlignment = NSTextAlignmentCenter;
    [self.earningView addSubview:unitLabel];
}

- (void)createInviteView
{
    self.inviteViewView = [[UIView alloc]initWithFrame:CGRectMake(0,self.earningView.bottom , self.view.width, self.view.height-RankViewHeight-self.earningView.height-1)];
    [self.view addSubview:self.inviteViewView];
    
    UILabel *inviteLabel = [self.inviteViewView labelWithFrame:CGRectMake(kComm_Content_Margin,IsLower6Screen?36:46, kComm_Content_Width ,12) text:@"邀请码" textFont:kFont12 textColor:ShortColor(0x66)];
    inviteLabel.textAlignment = NSTextAlignmentCenter;
    [self.inviteViewView addSubview:inviteLabel];
    
    UILabel *codeLabel = [self.inviteViewView labelWithFrame:CGRectMake(kComm_Content_Margin, inviteLabel.bottom+7, kComm_Content_Width ,14) text:self.data.inviteCode textFont:kFont18 textColor:RGBCOLOR(0x00, 0x90, 0xff)];
    codeLabel.textAlignment = NSTextAlignmentCenter;
    [self.inviteViewView addSubview:codeLabel];
    
    NSString *descStr = @"好友使用邀请码注册成功，你可获得对方礼物收益的5%";
    UILabel *desLabel = [self.inviteViewView labelWithFrame:CGRectMake(60, codeLabel.bottom+(IsLower6Screen?28:38), self.view.width-120 ,13) text:descStr textFont:kFont13 textColor:ShortColor(0x99)];
    
    NSAttributedString *attstr = [NSStringTool createAttributesting:descStr highContents:@[@"10%"] hgihtFont:kFont13 highColor:RGBCOLOR(0x21, 0xeb, 0xbe)];
    desLabel.attributedText = attstr;
    desLabel.numberOfLines = 0;
    desLabel.lineBreakMode = NSLineBreakByWordWrapping;
    desLabel.textAlignment = NSTextAlignmentCenter;
    [desLabel sizeToFit];
    [self.inviteViewView addSubview:desLabel];
    
    UIButton *inviteBtn = [self.inviteViewView buttonWithFrame:CGRectMake(87, desLabel.bottom+(IsLower6Screen?26:36), self.view.width-2*87, 45) titleFont:kFont16 titleStateNorColor:ShortColor(0xf4) titleStateNor:@"邀请好友"];
    inviteBtn.backgroundColor = RGBCOLOR(0x21, 0xeb, 0xbe);
    inviteBtn.layer.masksToBounds = YES;
    inviteBtn.layer.cornerRadius = inviteBtn.height/2;
    [inviteBtn addTarget:self action:@selector(inviteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.inviteViewView addSubview:inviteBtn];
    
    
}
- (void)createRankView
{
    self.rankView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.height-RankViewHeight, self.view.width, RankViewHeight)];
    [self.view addSubview:self.rankView];
    
    NSString *descStr = @"好友贡献排行榜";
    UIFont *desFont = [UIFont systemFontOfSize:15];
    CGSize descSize = [descStr sizeWithFont:desFont];
    CGFloat lineWidth = (self.view.width-32-17-descSize.width)/2;
    UIView *frontLine =  [self.rankView getViewLine:CGRectMake(kComm_Content_Margin, 7, lineWidth, 0.5)];
    [self.rankView addSubview:frontLine];
    
    UILabel *descLabel = [self.rankView labelWithFrame:CGRectMake(frontLine.right+7, 0, descSize.width+1 , 15) text:descStr textFont:desFont textColor:ShortColor(0x99)];
    [self.rankView addSubview:descLabel];
    
    UIView *backLine =  [self.rankView getViewLine:frontLine.frame];
    backLine.left = descLabel.right+6;
    [self.rankView addSubview:backLine];
    
    if (self.data.frilist==nil ||self.data.frilist.count==0)
    {
        UILabel *inviteLabel = [self.rankView labelWithFrame:CGRectMake(kComm_Content_Margin, descLabel.bottom+50,kComm_Content_Width, 15) text:@"您尚未邀请好友" textFont:desFont textColor:ShortColor(0xc8)];
        inviteLabel.textAlignment = NSTextAlignmentCenter;
        [self.rankView addSubview:inviteLabel];
    }
    else
    {
        UIView *friendView = [self getFriendView];
        friendView.top = frontLine.bottom+38;
        [self.rankView addSubview:friendView];
    }
    
}
- (UIView *)createShareview
{
    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0,kMainScreenHeight -ShareViewHeight, kMainScreenWidth, ShareViewHeight)];
    shareView.backgroundColor = kShortColor(0xf4);
    
    CGFloat space = (kMainScreenWidth-ShareItemWidth*4)/5;
    CGFloat xPos = space;
    CGFloat yPos = 28;
    for(int i=0;i<5;i++) //share_icon_
    {
        UIView *button = [self getShareItemViewRect:CGRectMake(xPos, yPos, ShareItemWidth,ShareItemHeight) img:[UIImage imageNamed:[NSString stringWithFormat:@"share_icon_%d",(i==4?i+2:i+1)]] title:[self getTitle:i] space:6.5];
        
        if(i == 3)
        {
            xPos = space;
            yPos = button.bottom+19;
        }
        else
        {
            xPos = button.right+space;
        }
        button.tag = i;
        
        [shareView addSubview:button];
    }
    UIButton *cancelBtn = [shareView buttonWithFrame:CGRectMake(0, yPos+ShareItemHeight+15, kMainScreenWidth, 45.5) titleFont:kFont16 titleStateNorColor:ShortColor(51) titleStateNor:@"取消"];
    [cancelBtn addTarget:self action:@selector(shareCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn viewAddTopLine];
    [shareView addSubview:cancelBtn];
    shareView.height = cancelBtn.bottom;
    return shareView;
}

- (UIView *)getFriendView
{
    NSArray *inviteList = self.data.frilist;
    UIView *friendView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 70)];
    NSInteger canShowCount = 5;
    CGFloat space = (self.view.width-canShowCount*50)/(canShowCount+1);
    NSInteger realShowCount =  inviteList.count>=5?5:inviteList.count;
    for (NSInteger index=0; index<realShowCount; index++)
    {
        FriListInvite *friend = inviteList[index];
        CGFloat left  = space +index*(space+50);
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(left, 0, 50, 50)];
        [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:friend.headUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"invite_icon"]];
        btn.userInteractionEnabled = NO;
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = btn.height/2;
        [friendView addSubview:btn];
        
        UILabel *label = [friendView labelWithFrame:CGRectMake(left, btn.bottom+8, 50, 12) text:friend.nickname textFont:kFont12 textColor:[UIColor blackColor]];
        [friendView addSubview:label];
        
    }
    return friendView;
    
}
- (void)inviteBtnClicked:(id)sender
{
    self.shareView = [self createShareview];
    [self showViewOnMask:self.shareView];
}

- (void)shareItemClicked:(UIButton *)sender
{
    NSString *title = [self getTitle:sender.tag];
    if ([title isEqualToString:@"微信好友"])
    {
        [self shareToWx:0];
        
    }
    else if ([title isEqualToString:@"微信朋友圈"])
    {
        [self shareToWx:1];
    }
    else if ([title isEqualToString:@"QQ"])
    {
        [self shareToQQ];
    }
    else if ([title isEqualToString:@"QQ空间"])
    {
        [self shareToQZone];
        
    }
//     else if ([title isEqualToString:@"微博"])
//    {
//        
//    }
    else if ([title isEqualToString:@"复制链接"])
    {
        [self copylink];
    }
    else
    {
        
    }
}

- (void)shareCancelClicked:(UIButton *)sender
{
    [self dismissViewOnMask:self.shareView animated:YES];
}

- (NSString *)getTitle:(NSInteger)aIndex
{
    NSString *str = nil;
    switch (aIndex) {
        case 0:
            str = @"微信好友";
            break;
        case 1:
            str = @"微信朋友圈";
            break;
        case 2:
            str = @"QQ";
            break;
        case 3:
            str = @"QQ空间";
            break;
//        case 4:
//            str = @"微博";
//            break;
        case 4:
            str = @"复制链接";
            break;
            
        default:
            str = @" ";
            break;
    }
    return str;
}


- (UIView *)getShareItemViewRect:(CGRect)aRect
                             img:(UIImage *)aImg
                           title:(NSString *)aTitle
                           space:(int)aSpace
{
    UIButton *itemBtn = [[UIButton alloc] initWithFrame:aRect];
    int imgX = (aRect.size.width-aImg.size.width)/2;
    CGSize tsize = [aTitle sizeWithFont:kFont12];
    int toffsetx = (aRect.size.width-tsize.width)/2;
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, 0, aImg.size.width, aImg.size.height)];
    [icon setImage:aImg];
    [itemBtn addSubview:icon];
    
    UILabel *label = [self.view labelWithFrame:CGRectMake(toffsetx, icon.bottom+aSpace, tsize.width+1, tsize.height) text:aTitle textFont:kFont12 textColor:kShortColor(102)];
    [itemBtn addSubview:label];
    [itemBtn addTarget:self action:@selector(shareItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    return itemBtn;
}

- (void)shareToWx:(int)scene
{
    SendMessageToWXReq *sendreq = [[SendMessageToWXReq alloc] init];
    sendreq.bText = NO;
    sendreq.scene = scene; //0 = 好友列表 1 = 朋友圈 2 = 收藏
    
    WXMediaMessage *urlMessage = [WXMediaMessage message];
    urlMessage.title = shareTitle;//分享标题
    urlMessage.description = shareDesc;//分享描述
    [urlMessage setThumbImage:self.shareImage];
    
    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = shareUrl;//分享链接
    
    urlMessage.mediaObject = webObj;
    sendreq.message = urlMessage;
    [WXApi sendReq:sendreq];
}
- (void)shareToQQ
{
    [QQApiInterface sendReq:[self getQQShareMessage]];
}

- (void)shareToQZone
{
    [QQApiInterface SendReqToQZone:[self getQQShareMessage]];
}

- (SendMessageToQQReq*)getQQShareMessage
{
//    NSString *previewImageUrl = @"http://www.qqtouxiang.com/d/file/jiemei/2017-01-04/969cc642c6f2068e2676a76f497b4c3f.jpg";
    self.shareImage = [self.shareImage imageWithImageSimple:CGSizeMake(80, 80)];
    NSData *previewData = UIImageJPEGRepresentation(self.shareImage,0.5);
    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:shareUrl]
                                                        title:shareTitle
                                                  description:shareDesc
                                              previewImageData:previewData];
    
    SendMessageToQQReq *req =[SendMessageToQQReq reqWithContent:newsObj];
    return req;
}

- (void)copylink
{
//    [self.view makeToast:@"复制成功!"];
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [del showToastView:@"复制成功"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = shareUrl;
    [self shareCancelClicked:nil];
}
@end
