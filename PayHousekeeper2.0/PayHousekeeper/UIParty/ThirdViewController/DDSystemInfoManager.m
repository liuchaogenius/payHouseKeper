//
//  DDSystemInfoManager.m
//  PayHousekeeper
//
//  Created by liuguangren on 2016/12/20.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import "DDSystemInfoManager.h"
#import "SSZipArchive.h"

static BOOL SDImageCacheOldShouldDecompressImages = YES;
static BOOL SDImagedownloderOldShouldDecompressImages = YES;

@interface DDSystemInfoManager ()
{
    NSString *blurKey, *switchKey;
}

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) int currentDownloadAllIndex,currentDownloadManIndex,currentDownloadFemalIndex;
@end
@implementation DDSystemInfoManager

#pragma mark 初始化方法
- (id)init
{
    self=[super init];
    if(self)
    {
        _timeArr = [NSMutableArray array];
        _broadcastArr = [NSMutableArray array];
        _allAvaterArr = [NSMutableArray array];
        _manAvaterArr = [NSMutableArray array];
        _femalAvaterArr = [NSMutableArray array];
        _giftsArr = [NSMutableArray array];
        _picUrlDic = [NSMutableDictionary dictionary];
        _downloadZipDic = [NSMutableDictionary dictionary];

        [self getKeyStr];
    }
    return self;
}

+ (DDSystemInfoManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static DDSystemInfoManager *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[DDSystemInfoManager alloc] init];
    });
    return sSharedInstance;
}

- (void)getMacthTimeInfo
{
    WeakSelf(self)
    [NetManager requestWith:nil apiName:kSysInfoAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        [weakself.timeArr removeAllObjects];
        NSString *timeStr = [successDict objectForKey:@"matchTime"];
        NSArray *matchTime = [timeStr componentsSeparatedByString:@","];
        for(NSString *str in matchTime)
        {
            NSArray *tmpArr = [str componentsSeparatedByString:@"-"];
            NSDictionary *dic = @{@"startTime":[tmpArr firstObject],
                                  @"endTime":[tmpArr lastObject]};
            [weakself.timeArr addObject:dic];
        }
    } failure:^(NSDictionary *failDict, NSError *error) {
    }];
}

- (void)getBroadcastInfo
{
    if([UserInfoData shareUserInfoData].strUserId)
    {
        WeakSelf(self)
        [NetManager requestWith:@{@"accid":[UserInfoData shareUserInfoData].strUserId} apiName:kNoticeInfoAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            
            if([successDict isKindOfClass:[NSArray class]])
            {
                for(NSDictionary *dic in (NSArray *)successDict)
                {
                    BroadcastModel *model = [[BroadcastModel alloc] init];
                    [model unPakceBroadcastInfoDict:dic];
                    [weakself.broadcastArr insertObject:model atIndex:0];
                }
            }
            
        } failure:^(NSDictionary *failDict, NSError *error) {
        }];
    }
}

- (void)getRandAvatarInfo
{
    NSDictionary *dic = @{@"accid":[UserInfoData shareUserInfoData].strUserId,
                          @"gender":@"A"};
    WeakSelf(self)
    if(self.allAvaterArr.count == 0)
    {
        [NetManager requestWith:dic apiName:kRandAvatarAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            [weakself.allAvaterArr removeAllObjects];
            if([successDict isKindOfClass:[NSArray class]])
            {
                for(NSDictionary *dic in (NSArray *)successDict)
                {
                    if(![dic isKindOfClass:[NSNull class]] && dic.count > 0 && [dic objectForKey:@"avatar"])
                    {
                        [weakself.allAvaterArr addObject:dic];
                        SDImageCache *canche = [SDImageCache sharedImageCache];
                        SDImageCacheOldShouldDecompressImages = canche.shouldDecompressImages;
                        canche.shouldDecompressImages = NO;
                        
                        SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
                        SDImagedownloderOldShouldDecompressImages = downloder.shouldDecompressImages;
                        downloder.shouldDecompressImages = NO;
                        
                        [weakself downloadPicAll];
                    }
                }
            }
        } failure:^(NSDictionary *failDict, NSError *error) {
        }];
    }
    
    if(self.manAvaterArr.count == 0)
    {
        dic = @{@"accid":[UserInfoData shareUserInfoData].strUserId,
                @"gender":@"M"};
        [NetManager requestWith:dic apiName:kRandAvatarAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            [weakself.manAvaterArr removeAllObjects];
            if([successDict isKindOfClass:[NSArray class]])
            {
                for(NSDictionary *dic in (NSArray *)successDict)
                {
                    if(![dic isKindOfClass:[NSNull class]] && dic.count > 0 &&  [dic objectForKey:@"avatar"])
                    {
                        [weakself.manAvaterArr addObject:dic];
                        SDImageCache *canche = [SDImageCache sharedImageCache];
                        SDImageCacheOldShouldDecompressImages = canche.shouldDecompressImages;
                        canche.shouldDecompressImages = NO;
                        
                        SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
                        SDImagedownloderOldShouldDecompressImages = downloder.shouldDecompressImages;
                        downloder.shouldDecompressImages = NO;
                        
                        [weakself downloadPicMan];
                    }
                }
            }
        } failure:^(NSDictionary *failDict, NSError *error) {
        }];
    }
    
    if(self.femalAvaterArr.count == 0)
    {
        dic = @{@"accid":[UserInfoData shareUserInfoData].strUserId,
                @"gender":@"F"};
        [NetManager requestWith:dic apiName:kRandAvatarAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
            [weakself.femalAvaterArr removeAllObjects];
            if([successDict isKindOfClass:[NSArray class]])
            {
                for(NSDictionary *dic in (NSArray *)successDict)
                {
                    if(![dic isKindOfClass:[NSNull class]] && dic.count > 0 && [dic objectForKey:@"avatar"])
                    {
                        [weakself.femalAvaterArr addObject:dic];
                        SDImageCache *canche = [SDImageCache sharedImageCache];
                        SDImageCacheOldShouldDecompressImages = canche.shouldDecompressImages;
                        canche.shouldDecompressImages = NO;
                        
                        SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
                        SDImagedownloderOldShouldDecompressImages = downloder.shouldDecompressImages;
                        downloder.shouldDecompressImages = NO;
                        
                        [weakself downloadPicFemal];
                    }
                }
            }
        } failure:^(NSDictionary *failDict, NSError *error) {
        }];
    }
}

- (void)getGiftsInfo
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:[UserInfoData shareUserInfoData].strUserId forKey:@"accid"];
    WeakSelf(self)
    [NetManager requestWith:dict apiName:kGetGiftsAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            [weakself.giftsArr removeAllObjects];
            NSArray *tmpArr = [successDict objectForKey:@"data"];
            for(NSDictionary *dic in tmpArr)
            {
                GiftModel *model = [[GiftModel alloc] init];
                [model unPakceGiftInfoDict:dic];
                [weakself.giftsArr addObject:model];
                if(![NetManager shareInstance].is3G && [NetManager shareInstance].isNetConnected)
                    [weakself downloadGiftZip:model];
            }
        }
        
    } failure:^(NSDictionary *failDict, NSError *error) {
    }];
}

- (void)downloadGiftZip:(GiftModel *)model
{
    NSArray *tmpArr = [model.effect componentsSeparatedByString:@"/"];
    if([[tmpArr lastObject] length] <= 0)
        return;
    
    
    NSString *docName = [[tmpArr lastObject] substringToIndex:[[tmpArr lastObject] length]-4];
    NSString *giftDocument = [GiftDocumentPath stringByAppendingPathComponent:docName];
    [self checkPath:GiftDocumentPath isCreaet:YES];
    NSString *giftZip = [GiftDocumentPath stringByAppendingPathComponent:[tmpArr lastObject]];
    if([self checkPath:giftZip isCreaet:NO])
        return;
    else
    {
        [NetManager downloadFileUrl:model.effect fullPath:giftZip progressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            
        } succ:^(NSDictionary *successDict) {
            if([SSZipArchive unzipFileAtPath:giftZip toDestination:giftDocument] && _downloadFinishBlock)
            {
                _downloadFinishBlock();
            }
            
        } failure:^(NSDictionary *failDict, NSError *error) {
            
        }];
    }
    
}

- (BOOL)checkPath:(NSString *)path isCreaet:(BOOL)isCreate
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    
    if(!(isDirExist && isDir) && isCreate)
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir)
        {
            NSLog(@"Create Directory Failed.");
        }
    }
    
    return isDirExist;
}

- (void)getSwitchInfo
{
    WeakSelf(self)
    [NetManager requestWith:nil apiName:kGetSwitchAPI method:kPost timeOutInterval:15 succ:^(NSDictionary *successDict) {
        if(successDict)
        {
            weakself.isOn = [[successDict objectForKey:@"flag"] boolValue];
            weakself.supportPayType = [NSString stringWithFormat:@"%@",[successDict objectForKey:@"supportPayType"]];
        }
        
    } failure:^(NSDictionary *failDict, NSError *error) {
    }];
}

- (void)cancelDownloadPic
{
    [[SDWebImageManager sharedManager] cancelAll];
    [_allAvaterArr removeAllObjects];
    [_manAvaterArr removeAllObjects];
    [_femalAvaterArr removeAllObjects];

    [self.picUrlDic removeAllObjects];
    self.currentDownloadAllIndex = 0;
    self.currentDownloadManIndex = 0;
    self.currentDownloadFemalIndex = 0;

    
    SDImageCache *canche = [SDImageCache sharedImageCache];
    canche.shouldDecompressImages = SDImageCacheOldShouldDecompressImages;
    
    SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
    downloder.shouldDecompressImages = SDImagedownloderOldShouldDecompressImages;
}

- (void)cancelDownloadGift
{
    for(NSURLSessionDownloadTask *task in _downloadZipDic.allValues)
    {
        if(task)
        {
            [task cancel];
        }
    }
}

- (void)startBroadcastTimer
{
    WeakSelf(self)
    // 获得队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 创建一个定时器(dispatch_source_t本质还是个OC对象)
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
    // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
    // 何时开始执行第一个任务
    // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚3秒
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120.0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(120.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(weakself.timer, start, interval, 0);
    
    // 设置回调
    dispatch_source_set_event_handler(weakself.timer, ^{
        [weakself getBroadcastInfo];
    });
    
    // 启动定时器
    dispatch_resume(self.timer);
}

- (void)stopBroadcastTimer
{
    if(self.timer)
    {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
}

- (BOOL)shouldShowTip:(NSString *)key
{
    NSString *theKey = key;
    BOOL res = YES;
    if([key isEqualToString:Tip4Blur])
    {
        theKey = blurKey;
    }
    else if ([key isEqualToString:Tip4Switch])
    {
        theKey = switchKey;
    }
    res = [[NSUserDefaults standardUserDefaults] boolForKey:theKey];
    return !res;
}

- (void)setShowTipValue:(BOOL)flag key:(NSString *)key
{
    NSString *theKey = key;
    if(flag)
    {
        if([theKey isEqualToString:Tip4Blur] || [theKey isEqualToString:Tip4Switch])
        {
            BOOL res = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-1",key]];
            if(!res)
            {
                theKey = [NSString stringWithFormat:@"%@-1",key];
            }
            else
            {
                res = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-2",key]];
                if(!res)
                {
                    theKey = [NSString stringWithFormat:@"%@-2",key];
                }
                else
                {
                    theKey = [NSString stringWithFormat:@"%@-3",key];
                }
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:theKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)getKeyStr
{
    NSString *key = Tip4Blur;
    BOOL res = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-1",key]];
    if(!res)
    {
        blurKey = [NSString stringWithFormat:@"%@-1",key];
    }
    else
    {
        res = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-2",key]];
        if(!res)
        {
            blurKey = [NSString stringWithFormat:@"%@-2",key];
        }
        else
        {
            blurKey = [NSString stringWithFormat:@"%@-3",key];
        }
    }
    
    key = Tip4Switch;
    res = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-1",key]];
    if(!res)
    {
        switchKey = [NSString stringWithFormat:@"%@-1",key];
    }
    else
    {
        res = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-2",key]];
        if(!res)
        {
            switchKey = [NSString stringWithFormat:@"%@-2",key];
        }
        else
        {
            switchKey = [NSString stringWithFormat:@"%@-3",key];
        }
    }
}

- (void)downloadPicAll
{
    //先进行缓存
    if(_allAvaterArr.count > 0 && _allAvaterArr.count-1>=self.currentDownloadAllIndex)
    {
        WeakSelf(self)
      
        NSDictionary *dic = [_allAvaterArr objectAtIndex:weakself.currentDownloadAllIndex];
        [[SDWebImageManager sharedManager] downloadImageWithURL:URL([dic objectForKey:@"avatar"]) options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if(finished && !error && image)
                [weakself.picUrlDic setObject:image forKey:[dic objectForKey:@"avatar"]];
            
            if(weakself.currentDownloadAllIndex == weakself.allAvaterArr.count-1)
            {
                SDImageCache *canche = [SDImageCache sharedImageCache];
                canche.shouldDecompressImages = SDImageCacheOldShouldDecompressImages;
                
                SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
                downloder.shouldDecompressImages = SDImagedownloderOldShouldDecompressImages;
                return ;
            }
            else
            {
                weakself.currentDownloadAllIndex++;
                [weakself downloadPicAll];
            }
        }];
    }
}

- (void)downloadPicFemal
{
    //先进行缓存
    if(_femalAvaterArr.count > 0 && _femalAvaterArr.count-1>=self.currentDownloadFemalIndex)
    {
        WeakSelf(self)
        
        NSDictionary *dic = [_femalAvaterArr objectAtIndex:weakself.currentDownloadFemalIndex];
        [[SDWebImageManager sharedManager] downloadImageWithURL:URL([dic objectForKey:@"avatar"]) options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if(finished && !error && image)
                [weakself.picUrlDic setObject:image forKey:[dic objectForKey:@"avatar"]];
            
            if(weakself.currentDownloadFemalIndex == weakself.femalAvaterArr.count-1)
            {
                SDImageCache *canche = [SDImageCache sharedImageCache];
                canche.shouldDecompressImages = SDImageCacheOldShouldDecompressImages;
                
                SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
                downloder.shouldDecompressImages = SDImagedownloderOldShouldDecompressImages;
                return ;
            }
            else
            {
                weakself.currentDownloadFemalIndex++;
                [weakself downloadPicFemal];
            }
        }];
    }
}

- (void)downloadPicMan
{
    //先进行缓存
    if(_manAvaterArr.count > 0 && _manAvaterArr.count-1>=self.currentDownloadManIndex)
    {
        WeakSelf(self)
        
        NSDictionary *dic = [_manAvaterArr objectAtIndex:weakself.currentDownloadManIndex];
        [[SDWebImageManager sharedManager] downloadImageWithURL:URL([dic objectForKey:@"avatar"]) options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if(finished && !error && image)
                [weakself.picUrlDic setObject:image forKey:[dic objectForKey:@"avatar"]];
            
            if(weakself.currentDownloadManIndex == weakself.manAvaterArr.count-1)
            {
                SDImageCache *canche = [SDImageCache sharedImageCache];
                canche.shouldDecompressImages = SDImageCacheOldShouldDecompressImages;
                
                SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
                downloder.shouldDecompressImages = SDImagedownloderOldShouldDecompressImages;
                return ;
            }
            else
            {
                weakself.currentDownloadManIndex++;
                [weakself downloadPicMan];
            }
        }];
    }
}

- (BOOL)isOKTime
{
    return [self isBetweenFromTime:@"19:00:00" toTime:@"30:00:00"];
}

- (BOOL)isOKTime4Lab
{
    return [self isBetweenFromTime:@"21:00:00" toTime:@"23:00:00"];
}

- (BOOL)isBetweenFromTime:(NSString *)startTime toTime:(NSString *)endTime
{
    NSDate *date1 = [self getCustomDateWithTime:startTime];
    NSDate *date2 = [self getCustomDateWithTime:endTime];
    
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:date1] == NSOrderedDescending && [currentDate compare:date2] == NSOrderedAscending)
    {
        return YES;
    }
    return NO;
}

- (NSDate *)getCustomDateWithTime:(NSString *)timeStr
{
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    
    //设置当天的某个点
    NSArray *tmpArr = [timeStr componentsSeparatedByString:@":"];
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:[[tmpArr firstObject] integerValue]];
    [resultComps setMinute:[[tmpArr lastObject] integerValue]];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}

@end
