//
//  BottomView.h
//  BerryMaps
//
//  Created by Berry on 16/4/12.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChargingNetModel.h"

@interface BottomView : UIView
@property (nonatomic, strong) void(^closeBlock)() ;
-(instancetype)initWithFrame:(CGRect)frame;
- (void)configureModel:(ChargingNetModel*)model;
@end
