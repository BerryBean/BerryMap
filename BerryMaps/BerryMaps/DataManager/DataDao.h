//
//  DataDao.h
//  BerryMaps
//
//  Created by Berry on 16/4/12.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChargingNetModel.h"
#import <MJExtension.h>
@interface DataDao : NSObject
+ (NSMutableArray *)parseChargingNetModelWithDic:(NSDictionary *)dic;
@end
