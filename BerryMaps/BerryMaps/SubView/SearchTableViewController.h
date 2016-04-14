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
@property (nonatomic, copy) void (^searchBlock)(AMapPOI *model);
- (void)searchWithKeyworks:(NSString *)keyworks locationWithLat:(float)lat lon:(float)lon;
@end
