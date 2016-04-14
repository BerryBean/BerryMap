//
//  PoinAnnotationClass.h
//  BerryMaps
//
//  Created by Berry on 16/4/12.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <MAMapKit/MAMapKit.h>
#import "ChargingNetModel.h"
@interface PoinAnnotationClass : MAUserLocation
@property (nonatomic, strong) ChargingNetModel* model;
@property (nonatomic, assign) BOOL      isUserLocation;

@end
