//
//  ChargingNetModel.h
//  BerryMaps
//
//  Created by Berry on 16/4/10.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
@interface ChargingNetModel : RLMObject
@property (nonatomic, copy) NSString    *oper_name;
@property (nonatomic, copy) NSString    *coordinate;
@property (nonatomic, copy) NSString    *is_active;
@property (nonatomic, copy) NSString    *free_num;
@property (nonatomic, copy) NSString    *charge_port_type;
@property (nonatomic, copy) NSString    *type;
@property (nonatomic, copy) NSString    *charge_total_time;
@property (nonatomic, copy) NSString    *is_rent;
@property (nonatomic, copy) NSString    *distance;
@property (nonatomic, copy) NSString    *nature;
@property (nonatomic, copy) NSString    *address;
@property (nonatomic, copy) NSString    *oper_code;
@property (nonatomic, copy) NSString    *charge_members;
@property (nonatomic, copy) NSString    *name;
@property (nonatomic, copy) NSString    *charge_slow_num;
@property (nonatomic, copy) NSString    *ev_nums;
@property (nonatomic, copy) NSString    *charge_fast_num;
@property (nonatomic, copy) NSString    *current_state;
@property (nonatomic, copy) NSString    *oper_tel;
@property (nonatomic, assign) NSInteger    charge_station_id;
@property (nonatomic, assign) NSInteger    _id;
@property (nonatomic, assign) BOOL      isUserType;
@property (nonatomic, assign) NSInteger verifyNum;
@property (nonatomic, assign) NSInteger noVerifyNum;

@end
RLM_ARRAY_TYPE(ChargingNetModel)

