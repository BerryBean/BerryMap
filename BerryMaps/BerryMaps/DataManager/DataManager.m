//
//  DataManager.m
//  BerryMaps
//
//  Created by Berry on 16/4/10.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager
+ (void)getChargingNetDataWithSuccessBlock:(void(^)(NSArray *arr))success failueBlock:(void(^)(NSError *error))failue{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:@"http://dzv3.dz.tt/index.php?m=app_server&c=api&a=teld&charge_port_type=1_2_3_4&current_state=1_2_3&is_active=1_0&lat=23.15475400386208&lng=113.3619126260622&req_mode=3&type=1_2_3" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *arr = [DataDao parseChargingNetModelWithDic:responseObject];
        success(arr);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failue(error);
        NSLog(@"error:%@",error);
    }];
}
@end
