//
//  YXGPUImageRawDataOutput.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/1.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "YXGPUImageRawDataOutput.h"

@implementation YXGPUImageRawDataOutput

- (id)initWithImageSize:(CGSize)newImageSize
{
    if (self = [super initWithImageSize:newImageSize resultsInBGRAFormat:YES])
    {
        _outputSize = newImageSize;
    }
    return self;
}

- (void)setImageSize:(CGSize)newImageSize
{
    [super setImageSize:newImageSize];
    _outputSize = newImageSize;
}


- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        [self lockFramebufferForReading];
        
        GLubyte *rawData  = [self rawBytesForImage];
        
        if (rawData)
        {
            CVPixelBufferRef pixelBuffer = NULL;
            
            CVPixelBufferCreateWithBytes(kCFAllocatorDefault, _outputSize.width, _outputSize.height, kCVPixelFormatType_32BGRA, rawData, [self bytesPerRowInOutput], NULL, NULL, NULL, &pixelBuffer);
            
            CMSampleBufferRef sampleBuffer = NULL;
            
            if (pixelBuffer) {
                
                CMSampleTimingInfo timing = {frameTime, frameTime, kCMTimeInvalid};
                
                CMVideoFormatDescriptionRef videoInfo = NULL;
                CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
                
                OSStatus status = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
                if (status != noErr) {
                    NSLog(@"Failed to create sample buffer with error %zd.", status);
                }
                
                if (videoInfo) {
                    CFRelease(videoInfo);
                }
                
                CVPixelBufferRelease(pixelBuffer);
                
                if (_sampleBufferBlock  && sampleBuffer) {
                    _sampleBufferBlock(sampleBuffer);
                }
                
                if (sampleBuffer) {
                    CFRelease(sampleBuffer);
                }
            }
        }
        
        [self unlockFramebufferAfterReading];
    }
    
}

@end
