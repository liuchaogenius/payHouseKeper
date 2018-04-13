//
//  NTESGPUImageVideoRender.h
//  NRTCDemo
//
//  Created by fenric on 16/8/24.
//  Copyright © 2016年 Netease. All rights reserved.

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "GPUImageContext.h"
#import "GPUImageOutput.h"

extern const GLfloat kColorConversion601[];
extern const GLfloat kColorConversion709[];
extern NSString *const kGPUImageYUVVideoRangeConversionForLAFragmentShaderString;

/**
 A GPUImageOutput that provides frames from either camera
*/
@interface NTESGPUImageVideoRender : GPUImageOutput
{
    NSUInteger numberOfFramesCaptured;
    CGFloat totalFrameTimeDuringCapture;
    
    GPUImageRotationMode outputRotation, internalRotation;
    dispatch_semaphore_t frameRenderingSemaphore;
        
    GLuint luminanceTexture, chrominanceTexture;

}

/// This enables the benchmarking mode, which logs out instantaneous and average frame times to the console
@property(readwrite, nonatomic) BOOL runBenchmark;

/// This determines the rotation applied to the output image, based on the source material
@property(readwrite, nonatomic) UIInterfaceOrientation outputImageOrientation;

/** Render a video sample
 @param sampleBuffer Buffer to process
 */
- (void)renderVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/// @name Benchmarking

/** When benchmarking is enabled, this will keep a running average of the time from uploading, processing, and final recording or display
 */
- (CGFloat)averageFrameDurationDuringCapture;

- (void)resetBenchmarkAverage;


@end
