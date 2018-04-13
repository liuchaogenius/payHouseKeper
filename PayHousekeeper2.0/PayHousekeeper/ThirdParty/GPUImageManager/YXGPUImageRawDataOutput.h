//
//  YXGPUImageRawDataOutput.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/1.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <GPUImage/GPUImage.h>

typedef void(^SampleBufferAvailableBlock)(CMSampleBufferRef buffer);

@interface YXGPUImageRawDataOutput : GPUImageRawDataOutput

- (id)initWithImageSize:(CGSize)newImageSize;

@property(nonatomic, copy) SampleBufferAvailableBlock sampleBufferBlock;

@property(nonatomic, readonly) CGSize outputSize;

@end
