//
//  GPUImageManager.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/29.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>

#define BILATERALKEY  @"bilateralFilterValue"
#define BRIGHTNESSKEY @"brightnessFilterValue"
#define BLURKEY       @"gaussianBlurFilterValue"
#define DRESSUPINDEX  @"dressupIndex"

@protocol NTESBeautifyMakerDataSource <NSObject>

- (GPUImageView *)filterView;

@end

@interface GPUImageManager : NSObject

@property (nonatomic,copy) NIMNetCallVideoSampleBufferHandler videoHandler;
@property (nonatomic,weak) id<NTESBeautifyMakerDataSource> datasource;
@property (nonatomic,assign) NSInteger dressupIndex;
@property (nonatomic,assign) BOOL flag;
@property (nonatomic,assign) BOOL isFront;
@property (nonatomic,assign) BOOL isOpenCameraService;

+ (GPUImageManager *)sharedInstance;

- (GPUImageView *)localPreviewView;

- (void)switchCamera;

- (void)stop;

- (void)start:(BOOL)isDelay;

- (void)adjustBounds;

- (void)clearImg;

//设置高斯模糊值
- (void)setBlurFilterValue:(CGFloat)value;

- (UIImage *)getBlurImage:(UIImage *)image;

- (void)checkCameraService:(void(^)(BOOL))result;

- (UIImage *)getCurrentImage;

- (void)freeYX;

- (void)setupYX;

@end
