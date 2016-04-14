//
//  DataDao.m
//  BerryMaps
//
//  Created by Berry on 16/4/12.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import "DataDao.h"

@implementation DataDao
+ (NSMutableArray *)parseChargingNetModelWithDic:(NSDictionary *)dic{
    [ChargingNetModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"_id":@"id"
                 };
    }];
    NSMutableArray *muArr = [[NSMutableArray alloc] init];
    for (NSDictionary *subDic in dic[@"data"]) {
        ChargingNetModel *model = [ChargingNetModel mj_objectWithKeyValues:subDic];
        [muArr addObject:model];
    }
    
    return muArr;
}
@end
