//
//  DataManager.h
//  BerryMaps
//
//  Created by Berry on 16/4/10.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "DataDao.h"
@interface DataManager : NSObject
+ (void)getChargingNetDataWithSuccessBlock:(void(^)(NSArray *arr))success failueBlock:(void(^)(NSError *error))failue;
@end
