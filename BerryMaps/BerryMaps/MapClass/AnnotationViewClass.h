//
//  AnnotationViewClass.h
//  BerryMaps
//
//  Created by Berry on 16/4/13.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface AnnotationViewClass : MAAnnotationView
@property (nonatomic, copy) void(^startDrag)();
@property (nonatomic, copy) void(^draging)();
@property (nonatomic, copy) void(^endDrag)();
- (id)initWithAnnotation:(id <MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;
- (void)configureDragStateBlockWithStart:(void(^)())startDrag draging:(void(^)())draging end:(void(^)())endDrag;
@end
