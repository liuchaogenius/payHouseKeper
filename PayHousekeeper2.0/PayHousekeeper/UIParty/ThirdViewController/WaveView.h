//
//  WaveView.h
//  PayHousekeeper
//
//  Created by liuguangren on 2017/1/19.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaveView : UIView

- (void)startAnimation;
- (void)stopAnimation;

@end

@interface WaveProgress : UIView
@property (nonatomic,assign)CGFloat progress;
@property (nonatomic,assign)CGFloat speed;/**< 波动的速度*/
@property (nonatomic,strong)UIColor * waveColor;
@property (nonatomic,assign)CGFloat waveHeight;

- (void)stopWaveAnimation;
@end
