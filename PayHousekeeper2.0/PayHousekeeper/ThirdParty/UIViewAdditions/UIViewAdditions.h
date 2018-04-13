#import <Foundation/Foundation.h>
#import "UIColor+Addition.h"
#import <UIKit/UIKit.h>

#define kFontW16 [UIFont systemFontOfSize:16]
#define kFontW15 [UIFont systemFontOfSize:15]
#define kFontW12 [UIFont systemFontOfSize:12]
#define kFontW14 [UIFont systemFontOfSize:14]
#define kColorW1 RGBCOLOR(72, 74, 76)
#define kcolorWhite RGBCOLOR(255, 255, 255)
#define kColorW2 RGBCOLOR(144, 147, 133)
#define kColorLine [UIColor colorWithHexValue:0xd8d8dc]
#define kColorLineNarrow RGBCOLOR(216, 221, 229)
#define kButtonNickTextFieldTag 100
#define kNickTextFieldTag  101
#define kImgCodeTextFieldTag 102
#define kColorBlack RGBCOLOR(48,49,51)
//#define kViewBackgroundColor RGBCOLOR(240, 240, 240)
#define kMaskColorHighlight RGBCOLORA(0, 0, 0, 0.1)

@interface UIView (TTCategory)

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat bottom;

@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

@property(nonatomic) CGFloat centerX;
@property(nonatomic) CGFloat centerY;

@property(nonatomic,readonly) CGFloat screenX;
@property(nonatomic,readonly) CGFloat screenY;
@property(nonatomic,readonly) CGFloat screenViewX;
@property(nonatomic,readonly) CGFloat screenViewY;
@property(nonatomic,readonly) CGRect screenFrame;

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign, readonly) CGFloat bottomFromSuperView;

//@property(nonatomic,readonly) CGFloat orientationWidth;
//@property(nonatomic,readonly) CGFloat orientationHeight;

- (UIScrollView*)findFirstScrollView;

- (UIView*)firstViewOfClass:(Class)cls;

- (UIView*)firstParentOfClass:(Class)cls;

- (UIView*)findChildWithDescendant:(UIView*)descendant;

/**
 * Removes all subviews.
 */
- (void)removeSubviews;

/**
 * WARNING: This depends on undocumented APIs and may be fragile.  For testing only.
 */
- (void)simulateTapAtPoint:(CGPoint)location;

- (CGPoint)offsetFromView:(UIView*)otherView;

- (void)viewAddTopLine;

- (void)viewAddTopLine:(CGFloat)aOffsetx;

- (void)viewAddMiddleLine:(CGFloat)aOffsetx;

- (UIView *)getViewLine:(CGRect)aRect;

- (void)viewaddCircleLine;

- (void)viewAddBottomLine;

-(UILabel*) labelWithFrame:(CGRect)frame
                      text:(NSString*)text
                  textFont:(UIFont*)font
                 textColor:(UIColor*)color;

- (UIButton *) buttonWithFrame:(CGRect)frame
                     titleFont:(UIFont *)aFont
            titleStateNorColor:(UIColor *)atitleColor
                 titleStateNor:(NSString *)aTitle;

/**
 *  2.UIView 的点击事件
 *
 *  @param target   目标
 *  @param action   事件
 */

- (void)addTarget:(id)target
           action:(SEL)action;

- (UIView *)tableviewFootView:(CGRect)aRect;

- (void)makeCenterToastActivity;

//弹出一个类似present效果的窗口
- (void)presentView:(UIView*)view animated:(BOOL)animated complete:(void(^)()) complete;

//获取一个view上正在被present的view
- (UIView *)presentedView;

- (void)dismissPresentedView:(BOOL)animated complete:(void(^)()) complete;

//这个是被present的窗口本身的方法
//如果自己是被present出来的，消失掉
- (void)hideSelf:(BOOL)animated complete:(void(^)()) complete;
@end
