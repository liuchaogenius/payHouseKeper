//
//  GPUImageManager.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/29.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "GPUImageManager.h"
#import "YXGPUImageRawDataOutput.h"
#import "NTESGPUImageVideoRender.h"
#import <Accelerate/Accelerate.h>
#import "UIAlertView+NTESBlock.h"
#import "LFGPUImageBeautyFilter.h"
#import "LFGPUImageEmptyFilter.h"
//#import "GPUView.h"

@interface GPUImageManager ()<GPUImageVideoCameraDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_captureSession;
    BOOL isRunning;
    AVCaptureVideoDataOutput *theCaptureOutput;
    dispatch_queue_t queue;
    AVCaptureDeviceInput *captureInput;
    dispatch_queue_t filterQueu;
    dispatch_queue_t checkCamerQueue;
    BOOL isFiltering;
    
    dispatch_source_t _timer;

}
@property (strong) GPUImageBilateralFilter *bilateralFilter,*bilateralFilter0;
@property (strong) GPUImageBrightnessFilter *brightnessFilter,*brightnessFilter0;
@property (strong) GPUImageGaussianBlurFilter *gaussianBlurFilter,*gaussianBlurFilter0;
@property (strong) GPUImageFilterGroup *groupFilter,*groupFilter0;
@property (strong) GPUImageVideoCamera *videoCamera;
@property (strong) GPUImageView *captureVideoPreview;

@property (nonatomic, assign) size_t localVideoWidth;
@property (nonatomic, assign) size_t localVideoHeight;
@property (strong) YXGPUImageRawDataOutput *filterOutput;
@property (strong, nonatomic) NTESGPUImageVideoRender *localVideoRender;

@property (nonatomic, strong) UIImageView *imageView;

@property (strong) LFGPUImageBeautyFilter *lfBeautyFilter,*lfBeautyFilter2;
@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *output;

@end

@implementation GPUImageManager

+ (GPUImageManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static GPUImageManager *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[GPUImageManager alloc] init];
    });
    return sSharedInstance;
}

- (void)checkCameraService:(void(^)(BOOL))result
{
#if TARGET_IPHONE_SIMULATOR
    if (result)
    {
        result(NO);
    }
#else
    dispatch_async(checkCamerQueue, ^{
        __block AVCaptureSession *weakCaptureSession = _captureSession;
        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
            [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                //            dispatch_async_main_safe(^{
                NSString *mediaType = AVMediaTypeVideo;
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
                {
                    if (result)
                    {
                        result(NO);
                    }

                    if(weakCaptureSession)
                    {
                        [weakCaptureSession stopRunning];
                        weakCaptureSession = nil;
                    }
                }
                else if(authStatus == AVAuthorizationStatusNotDetermined)
                {
                    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                        if (granted)
                        {
                            if (result)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    result(YES);
                                });
                            }
                        }
                        else
                        {
                            if (result)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    result(NO);
                                });
                            }
                        }
                    }];
                }
                else
                {
                    if (result)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            result(YES);
                        });
                    }
                }
            }];
        }
    });

#endif
}

- (void)checkMicrophoneService
{
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            dispatch_async_main_safe(^{
                if (!granted)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"未开启麦克风权限，无法正常通话"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                    [alert showAlertWithCompletionHandler:^(NSInteger idx) {
                    }];
                }
            });
        }];
    }
}

- (void)initTimer
{
    [self stopTimer];
    
    // 获得队列
    dispatch_queue_t timerQueue = dispatch_get_main_queue();
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(0.05 * NSEC_PER_SEC);
    dispatch_source_set_timer(_timer, start, interval, 0);
    WeakSelf(self)
    // 设置回调
    dispatch_source_set_event_handler(_timer, ^{
        [weakself changeStatue];
    });
    // 启动定时器
    dispatch_resume(_timer);
}

- (void)stopTimer
{
    if(_timer)
    {
        dispatch_cancel(_timer);
        _timer = nil;
    }
}

- (void)changeStatue
{
    isFiltering = !isFiltering;
}

#pragma mark 初始化方法
- (id)init
{
    self=[super init];
    if(self)
    {
        _dressupIndex = -1;
        _isFront = YES;
        filterQueu = dispatch_queue_create([[NSString stringWithFormat:@"QueueFilter%@", self] UTF8String], DISPATCH_QUEUE_SERIAL);
        checkCamerQueue = dispatch_queue_create([[NSString stringWithFormat:@"checkCamerQueue%@", self] UTF8String], DISPATCH_QUEUE_SERIAL);
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
        _imageView.image = DEFAULTCALLBG;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.hidden = YES;
        //        _gpuView = [[GPUView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
        
        WeakSelf(self);
        [self checkCameraService:^(BOOL ressult) {
            weakself.isOpenCameraService = ressult;
        }];
        [self checkMicrophoneService];
        
#if TARGET_IPHONE_SIMULATOR
        NSLog(@"not supported");
#else
        // 创建最终预览View
        _captureVideoPreview = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
        _captureVideoPreview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        _captureVideoPreview.backgroundColor = [UIColor clearColor];
        [_captureVideoPreview addSubview:_imageView];
        _captureVideoPreview.clipsToBounds = YES;
        
        self.lfBeautyFilter = [[LFGPUImageBeautyFilter alloc] init];
        self.lfBeautyFilter2 = [[LFGPUImageBeautyFilter alloc] init];
        
        // 创建滤镜：磨皮，美白，组合滤镜
        _groupFilter = [[GPUImageFilterGroup alloc] init];
        _groupFilter0 = [[GPUImageFilterGroup alloc] init];
        
        [_groupFilter addTarget:_lfBeautyFilter];
        
        // 高斯模糊
        _gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        [_groupFilter addTarget:_gaussianBlurFilter];
        _gaussianBlurFilter.blurRadiusInPixels = 0;
        
        // 设置滤镜组链
        [_bilateralFilter addTarget:_lfBeautyFilter];
        [_lfBeautyFilter addTarget:_gaussianBlurFilter];
        
        [_groupFilter setInitialFilters:@[_lfBeautyFilter]];
        _groupFilter.terminalFilter = _gaussianBlurFilter;
        [_groupFilter useNextFrameForImageCapture];
        
        _videoHandler = ^(CMSampleBufferRef sampleBuffer) {
            if([YXManager sharedInstance].callInfo)
                [weakself processVideoSampleBuffer:sampleBuffer];
        };
        
        [self.localVideoRender removeAllTargets];
        [self.localVideoRender addTarget:self.groupFilter];
        [self.groupFilter addTarget:_captureVideoPreview];
        
        [self initTimer];
#endif
        
    }
    return self;
}

- (GPUImageView *)localPreviewView
{
    return _captureVideoPreview;
}

- (void)switchCamera
{
    WeakSelf(self);
    _isFront = !_isFront;
    __weak AVCaptureSession *weakCaptureSession = _captureSession;
    //    __weak UIImageView *weakImgView = _imageView;
    [self checkCameraService:^(BOOL result) {
        if(result)
        {
            NSArray *inputs = weakCaptureSession.inputs;
            for (AVCaptureDeviceInput *input in inputs ) {
                AVCaptureDevice *device = input.device;
                if ( [device hasMediaType:AVMediaTypeVideo] ) {
                    AVCaptureDevicePosition position = device.position;
                    AVCaptureDevice *newCamera =nil;
                    AVCaptureDeviceInput *newInput =nil;
                    
                    if (position ==AVCaptureDevicePositionFront)
                        newCamera = [weakself cameraWithPosition:AVCaptureDevicePositionBack];
                    else
                        newCamera = [weakself cameraWithPosition:AVCaptureDevicePositionFront];
                    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
                    
                    [weakCaptureSession beginConfiguration];
                    
                    [weakCaptureSession removeInput:input];
                    [weakCaptureSession addInput:newInput];
                    
                    [weakCaptureSession commitConfiguration];
                    //                    weakImgView.transform = CGAffineTransformScale(weakImgView.transform, -1.0, 1.0);
                    break;
                }
            }
        }
    }];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)initCaptureSession
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        }
    }
    
    theCaptureOutput = [[AVCaptureVideoDataOutput alloc]init];
    theCaptureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    if(!queue)
    {
        queue = dispatch_queue_create("cameraQueue", NULL);
    }
    [theCaptureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [theCaptureOutput setVideoSettings:videoSettings];
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    [_captureSession addInput:captureInput];
    [_captureSession addOutput:theCaptureOutput];
    AVCaptureConnection *connection = [theCaptureOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
//    [_captureSession startRunning];
//    isRunning = YES;
}

- (void)stop
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        _imageView.hidden = YES;
//        
//    });
//    isFiltering = YES;
    [_lfBeautyFilter2 removeAllTargets];
    if(!isRunning)
        return;
    [_captureSession stopRunning];
    isRunning = NO;
}

- (void)setFlag:(BOOL)flag
{
    _flag = flag;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        _imageView.hidden = YES;
////        _captureVideoPreview.hidden = YES;
//    });
}

- (void)start:(BOOL)isDelay
{
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"not supported");
#else
    
    if(!self.isOpenCameraService)
        return;
    
    [_lfBeautyFilter2 removeAllTargets];
    dispatch_async(checkCamerQueue, ^{
        
        if(!_captureSession)
        {
            [self initCaptureSession];
//            sleep(1);
        }
        NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        [theCaptureOutput setVideoSettings:videoSettings];
        theCaptureOutput.alwaysDiscardsLateVideoFrames = YES;
        _captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        
//        if(_flag)
        {
            _flag = NO;
            NSArray *inputs = _captureSession.inputs;
            for (AVCaptureDeviceInput *input in inputs )
            {
                AVCaptureDevice *device = input.device;
                if ( [device hasMediaType:AVMediaTypeVideo] ) {
                    AVCaptureDevicePosition position = device.position;
                    AVCaptureDevice *newCamera =nil;
                    AVCaptureDeviceInput *newInput =nil;
                    
                    if (position ==AVCaptureDevicePositionFront)
                        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
                    else
                        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
                    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
                    
                    [_captureSession beginConfiguration];
                    
                    [_captureSession removeInput:input];
                    [_captureSession addInput:newInput];
                    
                    [_captureSession commitConfiguration];
                    break;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self adjustBounds];
//            _imageView.hidden = NO;
            _captureVideoPreview.hidden = NO;
        });

        if(isRunning)
            return;

//        NSArray *inputs = _captureSession.inputs;
//        for (AVCaptureDeviceInput *input in inputs )
//        {
//            AVCaptureDevice *device = input.device;
//            if ( [device hasMediaType:AVMediaTypeVideo] ) {
//                AVCaptureDevicePosition position = device.position;
//                AVCaptureDevice *newCamera =nil;
//                AVCaptureDeviceInput *newInput =nil;
//                
//                if (position ==AVCaptureDevicePositionFront)
//                    newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
//                else
//                    newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
//                newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
//                
//                [_captureSession beginConfiguration];
//                
//                [_captureSession removeInput:input];
//                [_captureSession addInput:newInput];
//                
//                [_captureSession commitConfiguration];
//                break;
//            }
//        }
        [_captureSession startRunning];
        
        isRunning = YES;
    });
#endif
}

- (void)adjustBounds
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _captureVideoPreview.frame = _captureVideoPreview.superview.bounds;
        _imageView.frame = _captureVideoPreview.superview.bounds;
        MLOG(@"testframe=%@",NSStringFromCGRect(_captureVideoPreview.superview.bounds));
    });
}

- (void)clearImg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _captureVideoPreview.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
        _imageView.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    });
}

//设置高斯模糊值
- (void)setBlurFilterValue:(CGFloat)value
{
    _gaussianBlurFilter.blurRadiusInPixels = value;
    [MobClick event:MsgSetBlur];
}

- (UIImage *)getBlurImage:(UIImage *)image
{
    CGRect imageRect = { CGPointZero, image.size };
    UIImage *effectImage = image;
    
    float blurRadius = 10;
    float saturationDeltaFactor = 1;
    UIImage *maskImage = nil;
    UIColor *tintColor = RGBACOLOR(0, 0, 0, 0.4);
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -image.size.height);
        CGContextDrawImage(effectInContext, imageRect, image.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            uint32_t tempRadius = (uint32_t)radius;
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, tempRadius, tempRadius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, tempRadius, tempRadius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, tempRadius, tempRadius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722f + 0.9278f * s,  0.0722f - 0.0722f * s,  0.0722f - 0.0722f * s,  0,
                0.7152f - 0.7152f * s,  0.7152f + 0.2848f * s,  0.7152f - 0.7152f * s,  0,
                0.2126f - 0.2126f * s,  0.2126f - 0.2126f * s,  0.2126f + 0.7873f * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // 开启上下文 用于输出图像
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -image.size.height);
    
    // 开始画底图
    CGContextDrawImage(outputContext, imageRect, image.CGImage);
    
    // 开始画模糊效果
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // 添加颜色渲染
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // 输出成品,并关闭上下文
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
    
    //    GPUImageFilterGroup *group = [[GPUImageFilterGroup alloc] init];
    //
    //    GPUImageBrightnessFilter *brightness = [[GPUImageBrightnessFilter alloc] init];
    //    [_groupFilter addTarget:_brightnessFilter];
    //    brightness.brightness = -0.4;
    //
    //    GPUImageGaussianBlurFilter *blur = [[GPUImageGaussianBlurFilter alloc] init];
    //    blur.blurRadiusInPixels = 7.0;
    //
    //    [brightness addTarget:blur];
    //    [group setInitialFilters:@[brightness]];
    //    group.terminalFilter = blur;
    //
    //    UIImage *img = [group imageByFilteringImage:image];
    //    return image;
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    BOOL supportsVideoMirroring = _isFront;
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:supportsVideoMirroring?UIImageOrientationLeftMirrored:UIImageOrientationRight];
    CGImageRelease(quartzImage);
    return ([self fixOrientation:image]);
}
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if(!isRunning || isFiltering || captureOutput != theCaptureOutput)
    {
        return;
    }
    
     if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
         return;
    
    isFiltering = YES;
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
//    if(isFiltering)
//    {
//        image = _imageView.image;
//    }
    _imageView.image = image;
    GPUImagePicture *sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    
//    [_lfBeautyFilter2 forceProcessingAtSize:_captureVideoPreview.sizeInPixels];
    [sourcePicture addTarget:_lfBeautyFilter2];
    [_lfBeautyFilter2 addTarget:_captureVideoPreview];
    
    [sourcePicture useNextFrameForImageCapture];
    [_lfBeautyFilter2 useNextFrameForImageCapture];
    [sourcePicture processImage];
//    [sourcePicture removeAllTargets];
//    [_lfBeautyFilter2 removeAllTargets];
    
//    if(image)
//    {
//        isFiltering = YES;
//        [self.lfBeautyFilter2 useNextFrameForImageCapture];
////        [self.lfBeautyFilter2 removeOutputFramebuffer];
//        UIImage *img = [self.lfBeautyFilter2 imageByFilteringImage:image];
//        if(img)
//        {
//            [self.imageView setImage:img];
////            [[[GPUImageContext sharedImageProcessingContext] framebufferCache] purgeAllUnassignedFramebuffers];
//        }
//        else
//            NSLog(@"-----");
//    }
}

- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    size_t bufferWidth = 0;
    size_t bufferHeight = 0;
    
    if (CVPixelBufferIsPlanar(pixelBuffer)) {
        bufferHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
        bufferWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    } else {
        bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
        bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    }
    if (!self.filterOutput)
    {
        self.filterOutput = [[YXGPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(bufferWidth, bufferHeight)];
        
        self.filterOutput.sampleBufferBlock = ^(CMSampleBufferRef buffer) {
            [[NIMSDK sharedSDK].netCallManager sendVideoSampleBuffer:buffer];
        };
        
        if (self.groupFilter) {
            [self.groupFilter addTarget:self.filterOutput];
        }
    }
    
    if ((bufferHeight != _localVideoHeight) || (bufferWidth != _localVideoWidth)) {
        _localVideoHeight = bufferHeight;
        _localVideoWidth = bufferWidth;
        [self.filterOutput setImageSize:CGSizeMake(_localVideoWidth, _localVideoHeight)];
    }
    
    [self.localVideoRender renderVideoSampleBuffer:sampleBuffer];
}

- (GPUImageView *)filterView
{
    return _captureVideoPreview;
}

- (NTESGPUImageVideoRender *)localVideoRender
{
    if (!_localVideoRender) {
        _localVideoRender = [[NTESGPUImageVideoRender alloc] init];
//        [_localVideoRender addTarget:_captureVideoPreview];
    }
    return _localVideoRender;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
//    if (aImage.imageOrientation == UIImageOrientationUp || kSystemVersion < 10)
//        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)getCurrentImage
{
    return _imageView.image;
}

- (void)freeYX
{
    [_lfBeautyFilter2 removeAllTargets];
    [self.localVideoRender removeAllTargets];
    [self.groupFilter removeAllTargets];
    self.filterOutput = nil;
    self.localVideoRender = nil;
//    [[[GPUImageContext sharedImageProcessingContext] framebufferCache] purgeAllUnassignedFramebuffers];
}

- (void)setupYX
{
    [_lfBeautyFilter2 removeAllTargets];
    [self.localVideoRender addTarget:self.groupFilter];
    [self.groupFilter addTarget:_captureVideoPreview];
}

@end
