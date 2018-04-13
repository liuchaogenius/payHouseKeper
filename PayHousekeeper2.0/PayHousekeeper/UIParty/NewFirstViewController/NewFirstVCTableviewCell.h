//
//  NewFirstVCTableviewCell.h
//  PayHousekeeper
//
//  Created by striveliu on 2017/2/17.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFirstVCCellData : NSObject

@property (nonatomic, strong) NSString *topicId; // 话题ID
@property (nonatomic, strong) NSString *distributeUrl; // 搭配图
@property (nonatomic, strong) NSString *contentStr; // 话题内容
@property (nonatomic, assign)int videoCount; // 视频
@property (nonatomic, assign)int sharesCount; // 分享
- (void)unPacketData:(NSDictionary *)aDict;

@end


@class NewFirstVCTableviewCell;

@protocol NewFirstVCTableviewCellDelegate <NSObject>
@optional
- (void)cellWithTransmit:(UIButton *)btn;
@end

@interface NewFirstVCTableviewCell : UITableViewCell

@property (nonatomic, weak)id<NewFirstVCTableviewCellDelegate> delegate;

- (void)setCellData:(NewFirstVCCellData *)aCellData;
@end
