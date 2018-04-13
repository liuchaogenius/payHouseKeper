//
//  GenderView.h
//  PayHousekeeper
//
//  Created by liuguangren on 2017/2/16.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^TouchGender)();

@interface GenderView : UIView

@property (assign, nonatomic) NSString *currentGender;
@property (copy) TouchGender touchGenderBlock;
@end
