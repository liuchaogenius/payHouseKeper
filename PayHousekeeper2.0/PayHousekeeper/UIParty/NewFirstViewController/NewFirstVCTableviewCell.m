//
//  NewFirstVCTableviewCell.m
//  PayHousekeeper
//
//  Created by striveliu on 2017/2/17.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "NewFirstVCTableviewCell.h"

@implementation NewFirstVCCellData

- (void)unPacketData:(NSDictionary *)aDict
{
    AssignMentID(self.topicId, [aDict objectForKey:@"topicId"]);
    AssignMentID(self.contentStr, [aDict objectForKey:@"topicTitle"]);
    AssignMentID(self.distributeUrl, [aDict objectForKey:@"thumbUrl"]);
    self.videoCount = [[aDict objectForKey:@"vedioNum"] intValue];
    self.sharesCount = [[aDict objectForKey:@"shareNum"] intValue];
    
    
}

@end

@interface NewFirstVCTableviewCell()
@property (nonatomic)NewFirstVCCellData *cellData;

//  配图 cell里面的父控件
@property (nonatomic, strong) UIImageView *imgView;
// 底部蒙层的父控件
@property (nonatomic, strong) UIImageView *belowView;
// 正文
@property (nonatomic, strong) UILabel *contentLabel;
// 视频集
@property (nonatomic, strong) UIButton *videoBtn;
// 分享
@property (nonatomic, strong) UIButton *share;

@end

@implementation NewFirstVCTableviewCell

- (void)setCellData:(NewFirstVCCellData *)aCellData
{

    _cellData = aCellData;

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // 0.设置cell选中时的背景
        //        self.selectedBackgroundView = [[UIView alloc] init];
        
        self.backgroundColor = RGBCOLOR(238, 238, 238);
        
        self.imgView = [[UIImageView alloc] init];
        //        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        self.imgView.userInteractionEnabled = YES;
        self.imgView.backgroundColor = [UIColor whiteColor];
        self.imgView.userInteractionEnabled = YES;
        [self addSubview:self.imgView];
        
        self.belowView = [[UIImageView alloc] init];
        self.belowView.userInteractionEnabled = YES;
        self.belowView.image = [UIImage imageNamed:@"透明蒙版"];
        //        self.belowView.backgroundColor = RGBACOLOR(0, 0, 0, 0.55);
        [self.imgView addSubview:self.belowView];
        
        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.textColor = [UIColor whiteColor];
        self.contentLabel.font = kFont18;
        [self.belowView addSubview:self.contentLabel];
        
        self.videoBtn = [[UIButton alloc] init];
        [self.videoBtn setImage:[UIImage imageNamed:@"视频数"] forState:UIControlStateNormal];
        self.videoBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        self.videoBtn.titleLabel.font= kFont13;
        [self.belowView addSubview:self.videoBtn];
        [self.videoBtn addTarget:self action:@selector(btnclicked:) forControlEvents:UIControlEventTouchUpInside];
        self.videoBtn.tag = 10;
        
        self.share = [[UIButton alloc] init];
        [self.share setImage:[UIImage imageNamed:@"转发-1"] forState:UIControlStateNormal];
        self.share.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        self.share.titleLabel.font= kFont13;
        [self.belowView addSubview:self.share];
        [self.share addTarget:self action:@selector(btnclicked:) forControlEvents:UIControlEventTouchUpInside];
        self.share.tag = 20;
        
    }
    return self;
}


- (void)btnclicked:(UIButton *)btn
{

    if ([self.delegate respondsToSelector:@selector(cellWithTransmit:)]) {
        [self.delegate cellWithTransmit:btn];
    }
}



- (void)layoutSubviews
{
    [super layoutSubviews];

    [self setupCellFrame];
    
    [self createCellView];
    
}

- (void)setupCellFrame
{
    CGFloat imgViewH = self.frame.size.height - 5;
    if (kMainScreenWidth == 320) {
        imgViewH = 196;
    }
    
    self.imgView.frame = CGRectMake(0, 0, kMainScreenWidth, imgViewH);
    
    self.belowView.frame = CGRectMake(0, self.frame.size.height - 60, kMainScreenWidth, 55);
    self.contentLabel.frame = CGRectMake(13, self.belowView.frame.size.height - 55, kMainScreenWidth - 130, 55);
    
    self.videoBtn.frame = CGRectMake(kMainScreenWidth - 113, self.belowView.frame.size.height - 55, 50, 55);
    
    self.share.frame = CGRectMake(CGRectGetMaxX(self.videoBtn.frame), self.belowView.frame.size.height - 55, 50, 55);
    
    
}

- (void)createCellView
{
    
    //    图层-24 本地测试适配图片
    //    [self.imgView setImage:[UIImage imageNamed:@"图层-24"]];
    [self.imgView sd_setImageWithURL:URL(self.cellData.distributeUrl) placeholderImage:DEFAULTPROBE];
    
    NSString *conStr = [NSString stringWithFormat:@"#%@#", self.cellData.contentStr];
    self.contentLabel.text = conStr;
    [self.videoBtn setTitle:[NSString stringWithFormat:@"%d", self.cellData.videoCount] forState:UIControlStateNormal];
    [self.share setTitle:[NSString stringWithFormat:@"%d", self.cellData.sharesCount] forState:UIControlStateNormal];

}
@end
