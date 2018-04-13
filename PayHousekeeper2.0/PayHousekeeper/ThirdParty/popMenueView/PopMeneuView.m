//
//  PopMeneuView.m
//  PayHousekeeper
//
//  Created by 1 on 2016/11/30.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "PopMeneuView.h"

@interface PopMeneuView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) UITableView *tableview;
@property (nonatomic) NSArray *contentArry;
@property (nonatomic,copy) void(^clickItemBlock)(int index);
@end

@implementation PopMeneuView

- (instancetype)init
{
    if(self=[super init])
    {
    }
    return self;
}

- (void)setMeneuDataArry:(NSArray *)dataArry clickItem:(void(^)(int aClickIndex))aBlock
{
    _contentArry = dataArry;
    self.clickItemBlock = aBlock;
    if(!self.tableview)
    {
        [self createTableview];
    }
    else
    {
        [self.tableview reloadData];
    }
}

- (void)createTableview
{
    UIImage *arrowImg = [UIImage imageNamed:@"popMenue_arrow"];
     UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-10-20-arrowImg.size.width, 0, arrowImg.size.width, arrowImg.size.height)];
    [imgview setImage:arrowImg];
    [self addSubview:imgview];
   
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(self.width-10-139, imgview.bottom, 139, 90) style:UITableViewStylePlain];
    self.tableview.delegate   =  self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"popMenueBg"]];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableview.layer.cornerRadius = 8.0f;
    self.tableview.tableFooterView = [UIView new];
    [self addSubview:self.tableview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contentArry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PopMeneuViewcell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PopMeneuViewcell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if(indexPath.row < self.contentArry.count)
    {
        if(indexPath.row == 0)
        {
            [cell.imageView setImage:[UIImage imageNamed:@"popMenue_recordIcon"]];
        }
        else
        {
            [cell.imageView setImage:[UIImage imageNamed:@"popMenue_Addfri"]];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, kMainScreenWidth);
        }
        cell.textLabel.text = [self.contentArry objectAtIndex:indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = kFcolorFontGreen;//RGBCOLOR(136, 136, 136);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.clickItemBlock)
    {
        self.clickItemBlock((int)indexPath.row);
        [self dissmiss];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dissmiss];
}

- (void)showPopMenue:(UIView *)aInview titles:(NSArray<NSString *> *)dataArry clickItem:(void(^)(int aClickIndex))aBlock
{
    self.frame = aInview.bounds;
    [aInview addSubview:self];
    [self setMeneuDataArry:dataArry clickItem:aBlock];
}

- (void)dissmiss
{
    self.hidden = YES;
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
