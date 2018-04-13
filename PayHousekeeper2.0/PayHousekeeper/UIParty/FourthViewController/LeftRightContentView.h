//
//  LeftRightContentView.h
//  PayHousekeeper
//
//  Created by BY on 17/2/14.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef enum {
    RightContentTypeNone = 0,
    RightContentTypeTitle,
    RightContentTypeTextField
} RightContentType;


@interface LeftRightContentView : UIView
//{
//    UITextField *rightTextField;
//}
@property (nonatomic, strong)UITextField *rightTextField;
- (void)leftLabel:(NSString *)leftText rightText:(NSString *)rightText;
- (void)leftLabel:(NSString *)leftText textFieldPlaceholder:(NSString *)placeholder;
@property (nonatomic, assign)RightContentType type;
@end
