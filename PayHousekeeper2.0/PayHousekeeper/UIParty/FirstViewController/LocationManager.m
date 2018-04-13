//
//  LocationManager.m
//  PayHousekeeper
//
//  Created by liuguangren on 2017/1/9.
//  Copyright © 2017年 striveliu. All rights reserved.
//

#import "LocationManager.h"
#import "DDLoginManager.h"

@interface LocationManager ()<CLLocationManagerDelegate,UINavigationControllerDelegate>
{
    CLLocationManager *locationManager;
}

@end

@implementation LocationManager
+ (LocationManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static LocationManager *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[LocationManager alloc] init];
    });
    return sSharedInstance;
}

#pragma mark 初始化方法
- (id)init
{
    self=[super init];
    if(self)
    {
        self.latitude = @"0";
        self.longitude = @"0";
    }
    return self;
}

- (void)start
{
    // 判断定位操作是否被允许
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        //提示用户无法进行定位操作
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                  @"提示" message:@"定位不成功 ,请确认开启定位" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    else
    {
        //开启定位
        
        locationManager = [[CLLocationManager alloc] init];//创建位置管理器
        
        locationManager.delegate=self;
        
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        
        locationManager.distanceFilter=1000.0f;
        
        //启动位置更新
#ifdef __IPHONE_8_0
        if(kSystemVersion>=8.0)
        {
            [locationManager requestAlwaysAuthorization];
            [locationManager requestWhenInUseAuthorization];
        }
#endif
        
        [locationManager startUpdatingLocation];
    }
}

#pragma mark - CoreLocation Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    self.latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    WeakSelf(self)
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             //将获得的所有信息显示到label上
             NSLog(@"placemark.name=%@",placemark.name);
             //获取城市
             NSString *city = placemark.locality;
             if (!city)
             {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             NSLog(@"city=%@",city);
             weakself.city = city;
             [[DDLoginManager shareLoginManager] reqestComInfoGender:nil nickName:nil imgData:nil birthday:nil inviteCode:nil place:weakself.city completeBlock:^(BOOL ret) {
             }];
         }
         else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }
         else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
     }];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied)
    {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}

@end
