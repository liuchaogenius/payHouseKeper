//
//  WXCamerasViewViewController.m
//  WXCustomCamera
//
//  Created by wx on 16/7/8.
//  Copyright © 2016年 WX. All rights reserved.
//

#import "WXCamerasViewViewController.h"
#import "WXCameraCoverView.h"
#import "WXAVCamPreView.h"
#import "WXImageScrollView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "WXHead.h"
#import "GPUImageManager.h"

@interface WXCamerasViewViewController ()<UIImagePickerControllerDelegate>
/**AVCaptureSession对象来执行输入设备和输出设备之间的数据传递*/
@property (nonatomic, strong) AVCaptureSession* session;
/**输入设备*/
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**照片输出流*/
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**预览图层*/
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, assign) CGRect roundRect;
/**装下面button的View*/
@property (nonatomic,weak)UIView * buttonView;
/**选择照片的View*/
@property (nonatomic,weak)UIView * chooseView;
/**选择照片的Button*/
@property (nonatomic,weak)UIButton * usePhotoButton;
/**拍照按钮*/
@property (nonatomic,weak)UIButton * takePhotoButton;
/**闪光灯的按钮*/
@property (nonatomic,weak)UIButton * flashButton;
/**前后摄像头的按钮*/
@property (nonatomic,weak)UIButton * changeCameraButton;
/**显示图片的*/
@property (nonatomic,strong)WXImageScrollView * imageScrollView;
/**遮盖View*/
@property (nonatomic,strong)WXCameraCoverView * cameraCoverView;
/**保存时拍照还是相册图*/
@property (nonatomic, assign) BOOL photoFromCamera;
/**从相册选择的按钮*/
@property (nonatomic, assign) BOOL albumeButton;
/**判断前后摄像头的状态*/
@property (nonatomic, assign) BOOL isUsingFrontFacingCamera;
/**判断闪光灯的状态*/
@property (nonatomic, assign) BOOL flashModeOn;
@property (nonatomic, copy)void(^userImgItem)(UIImage *aImg);
@end

@implementation WXCamerasViewViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"not supported");
#elif TARGET_OS_IPHONE
    if (self.session) {
        [self.session startRunning];
    }
#endif
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];    
    if (self.session) {
        [self.session stopRunning];
    }
}
- (void)viewDidLoad 
{
    
    [super viewDidLoad];
    self.title = @"拍照界面";
    self.view.backgroundColor =[UIColor whiteColor];
    [self initAVCaptureSession];
    [self setupAddBlueBGView];
    [self setupAddCameraChild];
    [self setupAddChooseImageChild];
}
/**初始化相机*/
- (void)initAVCaptureSession
{
    self.session = [[AVCaptureSession alloc] init];
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    if ([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceFront]) {
        [device setFlashMode:AVCaptureFlashModeAuto];
    }
    
    [device unlockForConfiguration];
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"not supported");
#elif TARGET_OS_IPHONE
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    backView.backgroundColor =[UIColor orangeColor];
    [self.view addSubview:backView];
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    self.previewLayer.frame = CGRectMake(0, 0,SCREEN_WIDTH,SCREEN_HEIGHT);
    backView.layer.masksToBounds = YES;
    [backView.layer addSublayer:self.previewLayer];
#endif
}
/**添加圆圈背景View*/
-(void)setupAddBlueBGView
{
    
    float scrollViewWidth = 0.7*SCREEN_WIDTH;
    float scrollViewX = (SCREEN_WIDTH - scrollViewWidth)/2;
    float scrollViewY = 0.15*SCREEN_HEIGHT;
    self.roundRect = CGRectMake(scrollViewX, scrollViewY, scrollViewWidth, scrollViewWidth);
    WXCameraCoverView *cameraCoverView = [[WXCameraCoverView alloc]initWithRoundFrame:self.roundRect];
    self.cameraCoverView = cameraCoverView;
    //    cameraCoverView.backgroundColor = [UIColor redColor];
    cameraCoverView.alpha = 0.8;
    self.automaticallyAdjustsScrollViewInsets = NO;
    WXImageScrollView * imageScrollView = [[WXImageScrollView alloc]initWithFrame:self.roundRect];
    imageScrollView.backgroundColor = [UIColor lightGrayColor];
    self.imageScrollView = imageScrollView;
    imageScrollView.hidden = YES;
    [self.view addSubview:imageScrollView];
    [self.view addSubview:cameraCoverView];
}
/**添加拍照时候的控件*/
-(void)setupAddCameraChild
{
    CGFloat buttonViewH = 150;
    UIView * buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT -150-60, SCREEN_WIDTH, buttonViewH)];
    self.buttonView = buttonView;
    buttonView.backgroundColor =[UIColor clearColor];
    [self.view addSubview:buttonView];
    //添加拍照按钮
    UIButton * takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePhotoButton setImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    takePhotoButton.frame = CGRectMake((SCREEN_WIDTH -75)/2,0, 75, 75);
    [takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    self.takePhotoButton = takePhotoButton;
    [buttonView addSubview:takePhotoButton];
    /**添加闪光灯按钮*/
    UIButton * flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    flashButton.frame = CGRectMake(SCREEN_WIDTH/4 - 13,24.5, 26, 26);
    [flashButton addTarget:self action:@selector(setFlashModeOnOff:) forControlEvents:UIControlEventTouchUpInside];
    self.flashButton = flashButton;
    [buttonView addSubview:flashButton];
    /**添加前后摄像头切换按钮*/
    UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeCameraButton setImage:[UIImage imageNamed:@"changeCamera"] forState:UIControlStateNormal];
    changeCameraButton.frame = CGRectMake(SCREEN_WIDTH*3/4 - 21,18, 43, 41);
    [changeCameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    self.changeCameraButton = changeCameraButton;
    [buttonView addSubview:changeCameraButton];
    /**从相册选择*/
    UIButton * albumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [albumeButton setBackgroundImage:[UIImage imageNamed:@"choosePhotoBtn"] forState:UIControlStateNormal];
    [albumeButton setTitle:@"从相册选择" forState:UIControlStateNormal];
    albumeButton.titleLabel.font =[UIFont fontWithName:kfontBold size:18];
    [albumeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    albumeButton.frame = CGRectMake((SCREEN_WIDTH - 225)/2,buttonView.frame.size.height -60, 225, 50);
    [albumeButton addTarget:self action:@selector(showAlbume) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:albumeButton];
}
/**添加选择图片时候的控件*/
- (void)setUserImgCallBack:(void(^)(UIImage *aBackImg))aBlock
{
    if(self.userImgItem)
    {
        self.userImgItem = nil;
    }
    self.userImgItem = aBlock;
    [GPUImageManager sharedInstance].flag = YES;
}
/**添加选择图片时候的控件*/
-(void)setupAddChooseImageChild
{
    CGFloat buttonViewH = 150;
    UIView * chooseView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT -150-60, SCREEN_WIDTH, buttonViewH)];
    self.chooseView = chooseView;
    chooseView.hidden = YES;
    chooseView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:chooseView];
    //添加使用照片button
    UIButton *usePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.usePhotoButton = usePhotoButton;
    [usePhotoButton setBackgroundImage:[UIImage imageNamed:@"usePhoto"] forState:UIControlStateNormal];
    [usePhotoButton setTitle:@"使用照片" forState:UIControlStateNormal];
    usePhotoButton.titleLabel.font = [UIFont fontWithName:kfontBold size:18];
    [usePhotoButton setTitleColor:WXColorFromRGB(0x0A233C) forState:UIControlStateNormal];
    usePhotoButton.frame = CGRectMake((SCREEN_WIDTH - 225)/2, 25, 225, 50);
    [usePhotoButton addTarget:self action:@selector(useCrop) forControlEvents:UIControlEventTouchUpInside];
    [chooseView addSubview:usePhotoButton];
    //重拍的button
    UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [retakeButton setBackgroundImage:[UIImage imageNamed:@"signupButton"] forState:UIControlStateNormal];
    [retakeButton setTitle:@"重拍" forState:UIControlStateNormal];
    retakeButton.titleLabel.font = [UIFont fontWithName:kfontBold size:18];
    [retakeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    retakeButton.frame = CGRectMake((SCREEN_WIDTH - 225)/2, chooseView.frame.size.height - 55, 225, 50);
    [retakeButton addTarget:self action:@selector(retakePhoto) forControlEvents:UIControlEventTouchUpInside];
    [chooseView addSubview:retakeButton];
}
/**拍照方法*/
-(void)takePhoto:(UIButton *)button
{
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput        connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:1];
    if (self.flashModeOn) {//判断是否闪光灯
        [self setFlashMode:AVCaptureFlashModeOn forDevice:[[self videoInput] device]];
    }else{
        [self setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoInput] device]];
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer)
        {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            //            image = [self imageWithImage:image scaledToSize:CGSizeMake(660, 560)];
            self.photoFromCamera = YES;
            image =  [self setupWithImage:image imageSize:image.size];
            [self chooseViewHiddenCameraView];
            [self reladImageScrollView:image];
            NSLog(@"image:%@",image);
        }
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,imageDataSampleBuffer,kCMAttachmentMode_ShouldPropagate);
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
            //无权限
            return ;
        }
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
            
        }];
        
    }];
}
/**是否打开闪光灯的方法*/
-(void)setFlashModeOnOff:(UIButton *)button
{
    if (self.flashModeOn) {
        self.flashModeOn = NO;
    }else{
        self.flashModeOn = YES;
    }
}
/**前后摄像头切换的方法*/
-(void)changeCamera:(UIButton *)button
{
    AVCaptureDevicePosition desiredPosition;
    if (self.isUsingFrontFacingCamera){
        desiredPosition = AVCaptureDevicePositionBack;
    }else{
        desiredPosition = AVCaptureDevicePositionFront;
    }
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [self.previewLayer.session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in self.previewLayer.session.inputs) {
                [[self.previewLayer session] removeInput:oldInput];
            }
            [self.previewLayer.session addInput:input];
            [self.previewLayer.session commitConfiguration];
            break;
        }
    }
    
    self.isUsingFrontFacingCamera = !self.isUsingFrontFacingCamera;
}
/**从相册选择的按钮方法*/
-(void)showAlbume
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id)self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}
/**点击使用照片所做操作*/
-(void)useCrop
{
    UIImage *scrollViewImage = [self getImageFromScrollView:self.imageScrollView];
    if(self.userImgItem)
    {
        self.userImgItem(scrollViewImage);
    }
    self.userImgItem = nil;
    [self.navigationController popViewControllerAnimated:YES];
    //WXGetViewController * imageVC = [[WXGetViewController alloc]init];
    //imageVC.getImages = scrollViewImage;
    //[self.navigationController pushViewController:imageVC animated:YES];
}
/**重拍的按钮点击*/
-(void)retakePhoto
{
    [UIView animateWithDuration:0.38 animations:^{
        self.imageScrollView.hidden = YES;
        self.cameraCoverView.alpha = 0.8;
        self.buttonView.hidden = NO;
        self.chooseView.hidden = YES;        
    }];
}
/**将照片放在scrollView上*/
-(void)reladImageScrollView:(UIImage *)chooseImage
{
    [self.imageScrollView displayImage:chooseImage];
    if (self.photoFromCamera) {
        [self.imageScrollView setContentOffsetIfPhotoFromCamera];
    }
}
#pragma mark - UIImagePickerControllerDelegate
-(AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}
- (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}
/**拍完照后隐藏牌照View显示选择图片的View等等*/
-(void)chooseViewHiddenCameraView
{
    [UIView animateWithDuration:0.38 animations:^{        
        self.imageScrollView.hidden = NO;
        self.cameraCoverView.alpha = 1;
        self.buttonView.hidden = YES;
        self.chooseView.hidden = NO;
    }];
}
/**设置image的大小*/
-(UIImage *)setupWithImage:(UIImage *)images imageSize:(CGSize)size
{
//    UIImageOrientation orientation = [images imageOrientation];
    UIImage *image = [self imageWithImage:images scaledToSize:size];
//    NSData *imageData = UIImageJPEGRepresentation(image,0.6);
//    image = [UIImage imageWithData:imageData];
//    CGImageRef imRef = [image CGImage];
//    NSInteger texWidth = CGImageGetWidth(imRef);
//    NSInteger texHeight = CGImageGetHeight(imRef);
//    float imageScale = 1;
//    if(orientation == UIImageOrientationUp && texWidth < texHeight){
//        image = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationLeft]; }
//    else if((orientation == UIImageOrientationUp && texWidth > texHeight) || orientation == UIImageOrientationRight){
//        image = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationUp];		}
//    else if(orientation == UIImageOrientationDown){
//        image = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationDown];}
//    else if(orientation == UIImageOrientationLeft){
//        image = [UIImage imageWithCGImage:imRef scale:imageScale orientation: UIImageOrientationUp];
//    }
    return image;
}
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}
-(UIImage *)getImageFromScrollView:(UIScrollView *)theScrollView
{
    //UIGraphicsBeginImageContext(theScrollView.frame.size);
    UIGraphicsBeginImageContextWithOptions(theScrollView.frame.size, NO, [UIScreen mainScreen].scale);
    CGPoint offset=theScrollView.contentOffset;
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -offset.x, -offset.y);
    [theScrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
    self.photoFromCamera = NO;
    UIImage * image = info[UIImagePickerControllerOriginalImage];
    image =  [self setupWithImage:image imageSize:image.size];
    [self chooseViewHiddenCameraView];
    [self reladImageScrollView:image];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
