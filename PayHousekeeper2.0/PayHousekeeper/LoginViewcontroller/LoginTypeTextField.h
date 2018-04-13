//
//  LoginTypeTextField.h
//  PayHousekeeper
//
//  Created by striveliu on 2016/10/26.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    //以下是枚举成员
    TextFieldTypeNome = 0,
    TextFieldTypePhone,
    TextFieldTypeMix
}TextFieldType;//枚举名称

@interface LoginTypeTextField : UIView
@property (nonatomic, strong) UITextField *inputTextField;
-(void)createCustomTextfieldleftDesc:(NSString *)aLeftDesc ploc:(NSString *)aPloc isSecurity:(BOOL)aIsSecurity;

-(void)createTextfieldCenterPloc:(NSString *)aPloc isSecurity:(BOOL)aIsSecurity;

- (void)setKeyType:(UIKeyboardType)aKeyType;

- (void)createAdditionPersonTF:(NSString *)aLeftConten;

- (NSString *)getInputText;

@property (nonatomic, assign)TextFieldType type;
@end
