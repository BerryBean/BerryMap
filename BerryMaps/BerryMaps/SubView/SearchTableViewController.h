//
//  SearchTableViewController.h
//  BerryMaps
//
//  Created by Berry on 16/4/14.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface SearchTableViewController : UITableViewController
@property (nonatomic, copy) void (^selectedBlock)(AMapPOI *model);
- (instancetype)initWithKeyworks:(NSString *)keyworks locationWithLat:(double)lat lon:(double)lon;
@end
