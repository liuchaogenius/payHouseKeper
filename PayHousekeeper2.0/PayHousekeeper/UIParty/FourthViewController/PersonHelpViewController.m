//
//  PersonHelpViewController.m
//  PayHousekeeper
//
//  Created by striveliu on 2017/1/3.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "PersonHelpViewController.h"
#import "NSStringTool.h"
#import "HelpDetailViewController.h"

@interface PersonHelpViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableview;
@end

@implementation PersonHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:@"帮助与反馈"];
    self.view.backgroundColor = kViewBackgroundHexColor;
    [self createTableview];
}


- (void)createTableview
{
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-64) style:UITableViewStylePlain];
    self.tableview.delegate   =  self;
    self.tableview.dataSource =  self;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableview.tableHeaderView = [self getTableviewHeadView];
    self.tableview.tableFooterView = [UIView new];
    [self.view addSubview:self.tableview];
}

- (UIView *)getTableviewHeadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 130)];
    view.backgroundColor = kcolorWhite;
    UIView *spaceview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 15)];
    spaceview.backgroundColor = kShortColor(238);
    [view addSubview:spaceview];
    
    UILabel *tLabel = [self.view labelWithFrame:CGRectMake(0, spaceview.bottom + (72-15-13-8)/2, view.width, 15) text:@"意见反馈或内测用户交流" textFont:kFont14 textColor:kShortColor(51)];
    tLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:tLabel];
    
    UILabel *dLabel = [self.view labelWithFrame:CGRectMake(0, tLabel.bottom + 8, view.width, 15) text:@"请加入咚咚交流群，群号：362877088" textFont:kFont12 textColor:kShortColor(153)];
    
    NSAttributedString *attributed = [NSStringTool createAttributesting:@"请加入咚咚交流群，群号：362877088" highContent:@"362877088" hgihtFont:kFont12 highColor:RGBCOLOR(33,235,190)];
    dLabel.attributedText = attributed;
    dLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:dLabel];
    
    UIView *celltBgview = [[UIView alloc] initWithFrame:CGRectMake(0, 15+72, view.width, 43)];
    celltBgview.backgroundColor = kShortColor(238);
    [view addSubview:celltBgview];
    
    UILabel *cellTLabel = [self.view labelWithFrame:CGRectMake(16, 0, view.width, celltBgview.height) text:@"常见问题解答" textFont:kFont14 textColor:kShortColor(153)];
    [celltBgview addSubview:cellTLabel];
    return view;
}

#pragma mark tableviewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 50.0f;
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableview dequeueReusableCellWithIdentifier:@"personHelpvccell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"personHelpvccell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.textColor = kShortColor(102);
    cell.textLabel.font = kFont14;
    if(indexPath.row == 0)
    {
        cell.textLabel.text = @"1.Q.为什么我总是连不到人？";
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = @"2.Q.为什么每次连接都要那么久？";
    }
    else if(indexPath.row == 2)
    {
        cell.textLabel.text = @"3.Q.为什么我连到的都是同性？";
    }
    else if(indexPath.row == 3)
    {
        cell.textLabel.text = @"4.Q.害羞的问一下：怎样才可以连到高颜值的帅哥（美女）啊？";
    }
    else if(indexPath.row == 4)
    {
        cell.textLabel.text = @"5.Q.（骄傲脸）我这么帅（美），怎样才能连到土豪给我送礼啊？";
    }
    else if(indexPath.row == 5)
    {
        cell.textLabel.text = @"6.Q.我长得不是很上镜，想问一下在这个看脸的时代如何才能不被对方划掉？";
    }
    else if(indexPath.row == 6)
    {
        cell.textLabel.text = @"7.Q.我很壕，但如何才能让对方知道我很壕？";
    }
    else if(indexPath.row == 7)
    {
        cell.textLabel.text = @"8.Q.倒计时快结束时想送礼延长时间，但是余额不足，去充值的话时间不够啊，怎么办？";
    }
    else if(indexPath.row == 8)
    {
        cell.textLabel.text = @"9.Q.有没有什么方法可以快速升级？";
    }
    else if(indexPath.row == 9)
    {
        cell.textLabel.text = @"10.Q.跟陌生人视频聊天会害羞，不知道聊些什么好，有没有什么“聊天宝典”之类的推荐一下？";
    }
    else if(indexPath.row == 10)
    {
        cell.textLabel.text = @"11.Q.咚咚只有普通VIP会员吗？有没有超级会员？";
    }
    else if(indexPath.row == 11)
    {
        cell.textLabel.text = @"12.Q.好喜欢咚咚这个应用，有没有什么途径可以第一时间体验咚咚的新功能？";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HelpDetailViewController *vc = [[HelpDetailViewController alloc] init];
    if(indexPath.row == 0)
    {
        vc.titleStr = @"为什么我总是连不到人？";
        vc.content = @"连不到人的原因有几种：①可能是你当前的网络不是很好，或者为你匹配到的用户网络不好；②当前在线并处在空闲状态的用户较少；③你的个人信息还不够完善，应用优先帮别人匹配去了。\n如果总是连不到人，不妨试试以下方法：①换个姿势，找个网络好点的地方再试一下；②去完善一下你自己的个人资料，资料越齐全越好；③耐心的继续等待；④使用“秒配”功能，花费3咚币让后台帮你飞速连接成功；⑤购买会员资格，尊享优先连接特权。如果还不行，也有可能是应用太紧张了，你不妨退出应用让它冷静一下，然后再重新试试；或者请直接联系我们，让我们的技术大牛帮你解决。";
    }
    else if(indexPath.row == 1)
    {
        vc.titleStr = @"为什么每次连接都要那么久？";
        vc.content = @"网络不好、当前在线并处在空闲状态的用户较少等原因都会导致连接时间变长，如果不想等待太久，建议找一个好一点的WiFi，或者你也可以购买会员资格哦，因为会员特权可以帮你快速连接成功。";
    }
    else if(indexPath.row == 2)
    {
        vc.titleStr = @"为什么我连到的都是同性？";
        vc.content = @"咚咚默认连接异性用户，如果在线并处在空闲状态的异性用户较少，它有可能会为你连接到同性的用户。如果你连到的一直都是同性，可能是你个人资料里的“性别”填错啦，很遗憾的告诉你，资料里的“性别”是不能更改的；然而，重点来了，在新推出的版本里，你可以手动选择匹配对象的性别，跟男生还是女生聊天，选择权在你手里哦。";
    }
    else if(indexPath.row == 3)
    {
        vc.titleStr = @"害羞的问一下：怎样才可以连到高颜值的帅哥（美女）啊？";
        vc.content = @"爱美之心人皆有之，有什么害羞的呢。成为咚咚的VIP会员，可大大提高连到帅哥美女的概率哦；除了成为会员，如果你是土豪，平时有经常打赏礼物的良好习惯，那连到帅哥美女的概率也会大大提高哦。";
    }
    else if(indexPath.row == 4)
    {
        vc.titleStr = @"(骄傲脸）我这么帅（美），怎样才能连到土豪给我送礼啊？";
        vc.content = @"长得好看与否因人而异，咚咚只看你的魅力值哦。长得好看就大胆地叫对方给你送礼吧，魅力值高，咚咚自然会优先给你连接到土豪用户哦。";
    }
    else if(indexPath.row == 5)
    {
        vc.titleStr = @"我长得不是很上镜，想问一下在这个看脸的时代如何才能不被对方划掉？";
        vc.content = @"这是个忧伤的问题，但也不是无法解决。如果你学识渊博、幽默风趣、才华横溢、谈笑风生……你可以在视频前选择开启“模糊效果”，咚咚给你60秒的时间去“征服”对方。当然，如果对方提前给你打赏礼物了，对不起，那你只能捂住或切换相机了。但我们始终认为，自信的人最美丽，你觉得呢？";
    }
    else if(indexPath.row == 6)
    {
        vc.titleStr = @"我很壕，但如何才能让对方知道我很壕？";
        vc.content = @"匹配成功后的连接过程，对方可以看到你是否是咚咚的VIP会员，此外，你还可以在视频聊天时大方地给对方打赏礼物，用行动来证明你的“壕”是最有说服力的。";
    }
    else if(indexPath.row == 7)
    {
        vc.titleStr = @"倒计时快结束时想送礼延长时间，但是余额不足，去充值的话时间不够啊，怎么办？";
        vc.content = @"来不及充值的话，那就赶紧关注对方吧！即使倒计时结束，你也能在“通讯录——我的关注”里找到对方哦。";
    }
    else if(indexPath.row == 8)
    {
        vc.titleStr = @"有没有什么方法可以快速升级？";
        vc.content = @"A.	当然有！①每天在线视频聊天10分钟可获得1活跃值，积累活跃值可以升级到对应的活跃等级；②大方的给对方赠送礼物，每送出10咚币礼物可获得1财富值哦；③视频过程中收到礼物或“爱心”可获得魅力值累积，每收到10咚币礼物可获得1魅力值，每收到30个“爱心”可增加1魅力值（每次视频最多可收到30个“爱心”）；分值累积越快，对应的等级升级就越快哦";
    }
    else if(indexPath.row == 9)
    {
        vc.titleStr = @"跟陌生人视频聊天会害羞，不知道聊些什么好，有没有什么“聊天宝典”之类的推荐一下？";
        vc.content = @"害羞是正常的，不知道聊什么也是正常的，“聊天宝典”什么的就不推荐了。俗话说“打赏礼物是最好的开场白”，如果实在不知道聊些什么，可以聊聊兴趣爱好啊、星座啊、最近发生的新鲜事啊什么的，鼓起勇气主动点去聊，说不定会遇到志趣相投的小伙伴哦！";
    }
    else if(indexPath.row == 10)
    {
        vc.titleStr = @"11.Q.咚咚只有普通VIP会员吗？有没有超级会员？";
        vc.content = @"目前咚咚有月度会员、季度会员和年度会员3种，在接下来的版本里可能会加入超级会员哦，敬请期待。";
    }
    else if(indexPath.row == 11)
    {
        vc.titleStr = @"12.Q.好喜欢咚咚这个应用，有没有什么途径可以第一时间体验咚咚的新功能？";
        vc.content = @"对于这么热情的用户，我们一向是十分欢迎的。加入咚咚内测群即可优先体验咚咚的新功能，并可以将自己的意见或建议第一时间反馈给我们哦，内测群QQ号：123456，我在群里等你哦";
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
