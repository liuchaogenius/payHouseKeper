//
//  DDBearViewController.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/28.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "BaseViewController.h"

@interface DDBearViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) id<NIMSessionConfig>  sessionConfig;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *messArr;

@end
