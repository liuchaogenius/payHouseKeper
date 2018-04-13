//
//  GenderView.m
//  PayHousekeeper
//
//  Created by liuguangren on 2017/2/16.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "GenderView.h"
#import "UserInfoData.h"


#define BtnIndex 200
#define kSelectGender [NSString stringWithFormat:@"dongdongSelectGender_%@",[UserInfoData shareUserInfoData].strUserCode]

@interface GenderView()
{
    int index;
}

@property (strong, nonatomic) NSArray *genderImgNameArr;
@property (strong, nonatomic) NSArray *genderNameArr;
@end

@implementation GenderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _genderImgNameArr = @[@"match_all",@"match_female",@"match_male"];
        _genderNameArr = @[@"全部",@"女生",@"男生"];
        self.clipsToBounds = YES;
        
        self.backgroundColor = [UIColor clearColor];
        
        for(int i = 0; i < 3; i++)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:_genderImgNameArr[i]] forState:UIControlStateNormal];
            btn.tag = BtnIndex + i;
            btn.frame = CGRectMake(0, i*71, self.width, 37);
            [self addSubview:btn];
            [btn addTarget:self action:@selector(showAndHide:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = kFont13;
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(37, -37, 0, 0)];
            
            if(i > 0)
            {
                [btn setY:btn.y-17];
                [btn setHeight:54];
                [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 17, 0)];
                [btn setTitle:_genderNameArr[i] forState:UIControlStateNormal];
            }
        }
        
        index = 0;
        _currentGender = @"A";
        NSString *selectGender = [self readSelectGender];
        if (selectGender&&[[self readSelectGender]length]>0 && ![selectGender isEqualToString:@"A"])
        {
            UIButton *tmpBtn = (UIButton *)[self viewWithTag:index+BtnIndex];
            [tmpBtn setTitle:_genderNameArr[index] forState:UIControlStateNormal];
            
            _currentGender = selectGender;
            if([selectGender isEqualToString:@"F"])
            {
                index = 1;
            }
            else if ([selectGender isEqualToString:@"M"])
            {
                index = 2;
            }
            
            UIButton *btn = (UIButton *)[self viewWithTag:index+BtnIndex];
            [tmpBtn setY:btn.y];
            [tmpBtn setHeight:54];
            [tmpBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 17, 0)];
            [btn setTitle:@"" forState:UIControlStateNormal];
            [btn setY:0];
            [btn setHeight:37];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
    }
    
    return self;
}

- (void)showAndHide:(UIButton *)btn
{
    if(self.height > 37)
    {
        if(btn.tag-BtnIndex != index)
        {
            UIButton *tmpBtn = (UIButton *)[self viewWithTag:index+BtnIndex];
            [tmpBtn setY:btn.y];
            [tmpBtn setHeight:54];
            [tmpBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 17, 0)];
            [tmpBtn setTitle:_genderNameArr[index] forState:UIControlStateNormal];

            index = (int)btn.tag-BtnIndex;
            [btn setTitle:@"" forState:UIControlStateNormal];
            [btn setY:0];
            [btn setHeight:37];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            
            if(_touchGenderBlock)
            {
                _touchGenderBlock();
            }
            
        }
        [self hideGender];
    }
    else
    {
        [self showAllGender];
    }
}

- (void)showAllGender
{
    WeakSelf(self)
    [UIView animateWithDuration:0.2 animations:^{
        [weakself setHeight:180];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideGender
{
    switch (index) {
        case 0:
            _currentGender = @"A";
            break;
        case 1:
            _currentGender = @"F";
            break;
        case 2:
            _currentGender = @"M";
            break;
        default:
            break;
    }
    [self saveSelectGender];
    WeakSelf(self)
    [UIView animateWithDuration:0.2 animations:^{
        [weakself setHeight:37];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)saveSelectGender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.currentGender forKey:kSelectGender];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString *)readSelectGender
{
   NSString *selectGender = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectGender];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return selectGender;
}
@end
