//
//  DDBearViewController.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/28.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "DDBearViewController.h"
#import "NIMMessageCellMaker.h"
#import "NSDateDeal.h"
#import "NIMMessageMaker.h"
#import "NIMDefaultValueMaker.h"
#import "NIMAvatarImageView.h"
#import "WebViewController.h"
#import "UITableView+NIMScrollToBottom.h"

@interface DDBearViewController ()

@end

@implementation DDBearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settitleLabel:@"咚咚熊"];
    self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    
    _messArr = [NSMutableArray array];
    [self makeUI];
    
    [self reqMessData];
}

- (void)reqMessData
{
    WeakSelf(self)
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    [dict setObject:[NSDateDeal formateTimerInterval:[NSDateDeal getCurrentTimeInterval] formate:@"yyyy-MM-dd hh:mm:ss"] forKey:@"time"];
    [NetManager requestWith:dict apiName:kGetDDPushMsgAPI method:KGet timeOutInterval:15 succ:^(NSDictionary *successDict) {
        NSArray *tmpArr = [successDict objectForKey:@"data"];
        if(tmpArr)
        {
            [weakself.messArr removeAllObjects];
            for(NSDictionary *dic in tmpArr)
            {
                NIMMessage *message = [NIMMessageMaker msgWithText:[dic objectForKey:@"content"]];
                message.localExt = dic;
                NIMMessageModel *model = [[NIMMessageModel alloc] initWithMessage:message];
                [weakself layoutConfig:model];
                [weakself.messArr insertObject:model atIndex:0];
                
                NIMTimestampModel *time = [[NIMTimestampModel alloc] init];
                time.messageTime = [[dic objectForKey:@"pushTime"] doubleValue]/1000;
                [weakself.messArr insertObject:time atIndex:0];
            }
            [weakself.tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.tableView nim_scrollToBottom:YES];
            });
        }
        
    } failure:^(NSDictionary *failDict, NSError *error) {
    }];
}

- (void)makeUI
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    id model = [_messArr objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[NIMMessageModel class]]) {
        cell = [NIMMessageCellMaker cellInTable:tableView
                                 forMessageMode:model];
        [(NIMMessageCell *)cell retryButton].hidden = YES;
        [(NIMMessageCell *)cell headImageView].image = IMG(@"DDBear");
        [[(NIMMessageCell *)cell bubbleView] addTarget:self action:@selector(clickCell:)];
    }
    else if ([model isKindOfClass:[NIMTimestampModel class]])
    {
        cell = [NIMMessageCellMaker cellInTable:tableView
                                   forTimeModel:model];
    }
    else
    {
        NSAssert(0, @"not support model");
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0;
    id modelInArray = [_messArr objectAtIndex:indexPath.row];
    if ([modelInArray isKindOfClass:[NIMMessageModel class]])
    {
        NIMMessageModel *model = (NIMMessageModel *)modelInArray;
        NSAssert([model respondsToSelector:@selector(contentSize)], @"config must have a cell height value!!!");
//        [self layoutConfig:model];
        CGSize size = model.contentSize;
        UIEdgeInsets contentViewInsets = model.contentViewInsets;
        UIEdgeInsets bubbleViewInsets  = model.bubbleViewInsets;
        cellHeight = size.height + contentViewInsets.top + contentViewInsets.bottom + bubbleViewInsets.top + bubbleViewInsets.bottom;
    }
    else if ([modelInArray isKindOfClass:[NIMTimestampModel class]])
    {
        cellHeight = [modelInArray height];
    }
    else
    {
        NSAssert(0, @"not support model");
    }
    return cellHeight;
}

- (NSTimeInterval)dateConverter:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *date = [[NSDate alloc] init];
    date = [dateFormatter dateFromString:string];
    
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    return timeInterval;
}

#pragma mark - 配置项
- (id<NIMSessionConfig>)sessionConfig
{
    return nil;
}
#pragma mark - Private
- (id<NIMCellLayoutConfig>)layoutConfigForModel:(NIMMessageModel *)model
{
    id<NIMCellLayoutConfig> config = nil;
    if ([self.sessionConfig respondsToSelector:@selector(layoutConfigWithMessage:)]) {
        config = [self.sessionConfig layoutConfigWithMessage:model.message];
    }
    return config ? : [[NIMDefaultValueMaker sharedMaker] cellLayoutDefaultConfig];
}

- (void)layoutConfig:(NIMMessageModel *)model{
    
    model.sessionConfig = self.sessionConfig;
    model.layoutConfig = [self layoutConfigForModel:model];
    [model calculateContent:self.tableView.width force:NO];
}

- (void)clickCell:(UITapGestureRecognizer *)sender
{
    NIMMessageCell *cell = (NIMMessageCell *)[[sender.view superview] superview];
    NSLog(@"%@",cell.model.message.text);
    
    NSDictionary *dic = cell.model.message.localExt;
    NSString *urlStr = [dic objectForKey:@"link"];
    if(urlStr && urlStr.length > 0)
    {
        WebViewController *vc = [[WebViewController alloc] init];
        vc.urlStr = urlStr;
        [self.navigationController pushViewController:vc animated:YES];
        [vc settitleLabel:[dic objectForKey:@"title"]];
    }
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
