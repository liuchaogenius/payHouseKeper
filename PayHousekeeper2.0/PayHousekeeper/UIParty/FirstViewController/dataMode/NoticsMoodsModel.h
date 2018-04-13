//
//  NoticsMoodsModel.h
//  PayHousekeeper
//
//  Created by liuguangren on 2016/11/10.
//  Copyright © 2016年 striveliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoticsMoodsModel : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *type;

- (void)unPackeDict:(NSDictionary *)aDict;

@end
