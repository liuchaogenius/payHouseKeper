//
//  WXCamerasViewViewController.h
//  WXCustomCamera
//
//  Created by wx on 16/7/8.
//  Copyright © 2016年 WX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXCamerasViewViewController : UIViewController
- (void)setUserImgCallBack:(void(^)(UIImage *aBackImg))aBlock;

@end
