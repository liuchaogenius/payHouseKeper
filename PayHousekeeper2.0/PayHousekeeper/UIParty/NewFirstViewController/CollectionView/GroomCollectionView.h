//
//  ManGodView.h
//  DongDong
//
//  Created by BY on 2017/3/14.
//  Copyright © 2017年 BestLife. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    e_recommend = 0,//推荐
    e_malegods,//男神
    e_goddess,//女神
    e_active,//活跃
    e_rookie//新秀
}CollectionViewType;
@class GroomCollectionView;

@protocol GroomCollectionViewDelegate <NSObject>

@optional
- (void)groomCell:(GroomCollectionView *)collectionView didSelectItem:(NSIndexPath *)indexPath;

@end

@interface GroomCollectionView : UIView
@property (nonatomic, assign)CollectionViewType viewType;
@property (nonatomic, weak)id<GroomCollectionViewDelegate> delegate;
// collectionData 显示的数据
- (instancetype)initWithFrame:(CGRect)frame collectionData:(NSArray *)collectionData;
@end
