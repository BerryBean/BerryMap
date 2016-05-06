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
@property (nonatomic, strong)   void(^closeBlock)();
@property (nonatomic, copy)     void(^goBlock)();
@property (nonatomic, copy)     void(^wayBlock)();
@property (nonatomic, copy)     void(^verifyBlock)();
-(instancetype)initWithFrame:(CGRect)frame;
- (void)configureModel:(ChargingNetModel*)model;
- (void)updateDistance:(NSInteger)distance;
- (void)updateVerifyNum:(ChargingNetModel*)model;
@end
