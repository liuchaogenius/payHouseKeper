//
//  BaseViewController.m
//  FW_Project
//
//  Created by  striveliu on 13-10-3.
//  Copyright (c) 2013年 striveliu. All rights reserved.
//

#import "BaseViewController.h"
#import "ViewInteraction.h"
#import "FTAnimation.h"

typedef enum
{
    E_Ani_Popin,
    E_Ani_Popout
}E_Ani_Type;

@interface BaseViewController ()
{
    UILabel                 *titleLabel;
    E_Ani_Type              _animType;
    BOOL                    _animating;
    BOOL      isHiddenNavBar;
}
@property (nonatomic, strong) UIImageView *makImageView;
@end

@implementation BaseViewController
@synthesize g_OffsetY;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self setNavgtionBarBg];
    self.view.backgroundColor = kViewBackgroundHexColor;
    if(kSystemVersion>=7.0)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        //self.navigationController.navigationBar.barTintColor = kClearColor;//KColor;
        

        self.statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 64)];
//        self.statusBarView.backgroundColor = [UIColor whiteColor];
//        [self.navigationController.view addSubview:self.statusBarView];
//        [self.navigationController.view sendSubviewToBack:self.statusBarView];
        //        [self.navigationController setNavigationBarHidden:NO];
        //        self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
        
        //self.navigationController.navigationBar.barTintColor = kClearColor;//KColor;
        
    }
    else
    {
        self.navigationController.navigationBar.tintColor = kClearColor;//KColor;
    }
    self.navigationController.navigationBar.alpha = 1;
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    if (self != [self.navigationController.viewControllers objectAtIndex:0])
    {
        [self setLeftButton:[UIImage imageNamed:@"back"] title:nil target:self action:@selector(back)];
    }

    if(kSystemVersion >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }

    if(self.navigationController)
    {
        if(self.navigationController.navigationBarHidden == YES)
        {
            if(kSystemVersion >= 7.0)
            {
                g_OffsetY = 20;
                self.view.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
            }
            else
            {
                g_OffsetY = 0;
                self.view.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-20);
            }
        }
        else
        {
            if(kSystemVersion >= 7.0)
            {
                self.view.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-self.navigationController.navigationBar.frame.size.height-20);
            }
            else
            {
                self.view.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-self.navigationController.navigationBar.frame.size.height-20);
            }
        }
    }
    else
    {
        if(kSystemVersion >= 7.0)
        {
            g_OffsetY = 20;
            self.view.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
        }
        else
        {
            g_OffsetY = 0;
            self.view.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-20);
        }
    }
}
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([self isMovingFromParentViewController])
    {
        [self.view hideToastActivity];
        AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [del.window hideToastActivity];
        [SVProgressHUD dismiss];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self isMovingToParentViewController])
    {
        [self firstMovingToParentvc];
    }
    
//    if(isHiddenNavBar)
//    {
//        self.statusBarView.hidden = YES;
//    }
}

- (void)firstMovingToParentvc
{
    
}

- (void)setBackgroundimg:(UIImage *)aBackgroundimg
{
    if(aBackgroundimg)
    {
        _backgroundimg = [aBackgroundimg resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        UIImageView *imgview = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imgview.contentMode = UIViewContentModeScaleAspectFill;
        [imgview setImage:_backgroundimg];
        [self.view addSubview:imgview];
    }
}
- (void)setLeftButton:(UIImage *)aImg title:(NSString *)aTitle target:(id)aTarget action:(SEL)aSelector
{
    CGRect buttonFrame = CGRectMake(-15, 0, 88/2, 44);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    if(aImg)
    {
        [button setImage:aImg forState:UIControlStateNormal];
    }
    if(aTitle)
    {
        [button setTitle:aTitle forState:UIControlStateNormal];
    }
    [button addTarget:aTarget action:aSelector forControlEvents:UIControlEventTouchUpInside];
    CGRect viewFrame = CGRectMake(0, 0, 88/2, 44);
    UIView *view = [[UIView alloc]initWithFrame:viewFrame];
    [view addSubview:button];
    
    if(self.navigationController && self.navigationItem)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    }
}

- (void)settitleLabel:(NSString*)aTitle
{
    if(!titleLabel)
    {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 200, self.navigationController.navigationBar.frame.size.height)];
        self.navigationItem.titleView = titleLabel;
    }
    titleLabel.center = self.navigationController.navigationBar.center;
    titleLabel.backgroundColor = kClearColor;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = kFont16;
    titleLabel.text = aTitle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
}

- (void)setRightButton:(UIImage *)aImg title:(NSString *)aTitle titlecolor:(UIColor *)aTitleColor target:(id)aTarget action:(SEL)aSelector
{
    int btw = 44;
    if(aTitle)
    {
        btw = [aTitle sizeWithFont:kFont16].width;
    }
    CGRect buttonFrame = CGRectMake(13, 0, 44.0f, 44.0f);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button addTarget:aTarget action:aSelector forControlEvents:UIControlEventTouchUpInside];
    if(aTitle)
    {
        [button setTitle:aTitle forState:UIControlStateNormal];
        [button setTitleColor:aTitleColor forState:UIControlStateNormal];
        button.titleLabel.font = kFont16;
    }
    if(aImg)
    {
        [button setImage:aImg forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    

    CGRect viewFrame = CGRectMake(0, 0, 47, 44);
    UIView *view = [[UIView alloc]initWithFrame:viewFrame];
    [view addSubview:button];
    if(self.navigationController && self.navigationItem)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    }
    _rightButton = button;
}

- (void)pushView:(UIView*)aView
{
    [ViewInteraction viewPresentAnimationFromRight:self.view toView:aView];
}

- (void)popView:(UIView*)aView completeBlock:(void(^)(BOOL isComplete))aCompleteblock
{
    [ViewInteraction viewDissmissAnimationToRight:aView isRemove:NO completeBlock:^(BOOL isComplete) {
        aCompleteblock(isComplete);
    }];
}

- (void)addCustomNavgationBar:(UIImage*)aLeftBtImg
                        title:(NSString*)aLeftBtTitle
                 leftBtAction:(SEL)aLeftBtAction
                   rightBtImg:(UIImage*)aRightBtImg
                        title:(NSString*)aRightBtTitle
                rightBtAction:(SEL)aRightAction
                  navBarTitle:(NSString *)aNavTitle
                  navBarColor:(UIColor *)aNavColor
{
    UIView *navBarview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 64)];
    navBarview.backgroundColor = aNavColor;
    [self.view addSubview:navBarview];
    
    if(aLeftBtImg || aLeftBtTitle)
    {
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
        leftButton.backgroundColor = kClearColor;
        leftButton.titleLabel.textColor = kcolorWhite;
        leftButton.titleLabel.font = kFont15;
        if(aLeftBtImg)
        {
            [leftButton setImage:aLeftBtImg forState:UIControlStateNormal];
        }
        if(aLeftBtTitle)
        {
            [leftButton setTitle:aLeftBtTitle forState:UIControlStateNormal];
        }
        [leftButton addTarget:self action:aLeftBtAction forControlEvents:UIControlEventTouchUpInside];
        [navBarview addSubview:leftButton];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, kMainScreenWidth-100, 44)];
    label.backgroundColor = kClearColor;
    label.font = kFont18;
    label.text = aNavTitle;
    label.textColor = kcolorWhite;
    [navBarview addSubview:label];
    
    if(aRightBtImg || aRightBtTitle)
    {
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth-44, 20, 44, 44)];
        rightButton.backgroundColor = kClearColor;
        rightButton.titleLabel.textColor = kcolorWhite;
        rightButton.titleLabel.font = kFont15;
        if(aRightBtImg)
        {
            [rightButton setImage:aRightBtImg forState:UIControlStateNormal];
        }
        if(aRightBtTitle)
        {
            [rightButton setTitle:aRightBtTitle forState:UIControlStateNormal];
        }
        [rightButton addTarget:self action:aRightAction forControlEvents:UIControlEventTouchUpInside];
        [navBarview addSubview:rightButton];
    }
}

- (void)setNavgationBarClear
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsCompact];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.navigationController.navigationBar.clipsToBounds=YES;
    CGRect vrect = self.view.frame;
    vrect.size.height = vrect.size.height+64;
    self.view.frame = vrect;
}

- (void)dealloc
{
    NSString *str = [NSString stringWithFormat:@"%@ dealloc",[NSString stringWithUTF8String:object_getClassName(self)]];
    NSLog(@"%@",str);
}

#pragma mark - showMaskView with animation
- (UIImageView *)makImageView
{
    if (_makImageView == nil)
    {
        _makImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _makImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _makImageView.userInteractionEnabled=YES;
        UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onMaskViewClicked)];
        [_makImageView addGestureRecognizer:singleTap];
    }
    return _makImageView;
}
- (void)onMaskViewClicked
{
}
- (void)showViewOnMask:(UIView*)view
{
    if (_animating)
    {
        return;
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self.makImageView];
    _animType = E_Ani_Popin;
    _animating = YES;
    [self.makImageView addSubview:view];
    [view popIn:0.5 delegate:self];
}

- (void)dismissViewOnMask:(UIView *)view animated:(BOOL)animated
{
    if(animated)
    {
        _animType = E_Ani_Popout;
        [view popOut:0.5 delegate:self];
    }
    else
    {
        _animating = NO;
        [view removeFromSuperview];
        [self.makImageView removeFromSuperview];
    }
}
#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
    _animating = NO;
    if(_animType == E_Ani_Popin)
    {
    }
    else if(_animType == E_Ani_Popout)
    {
        [self.makImageView removeFromSuperview];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.statusBarView removeFromSuperview];
}

@end
