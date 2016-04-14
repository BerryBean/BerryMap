//
//  AnnotationViewClass.m
//  BerryMaps
//
//  Created by Berry on 16/4/13.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import "AnnotationViewClass.h"

@implementation AnnotationViewClass
- (id)initWithAnnotation:(id <MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    return self;
}
- (void)setDragState:(MAAnnotationViewDragState)newDragState animated:(BOOL)animated{
    [super setDragState:newDragState animated:animated];
    if (newDragState == MAAnnotationViewDragStateStarting) {
        if (_startDrag) {
            _startDrag();
        }
        
    }
    else if (newDragState == MAAnnotationViewDragStateDragging) {
        if (_draging) {
            _draging();
        }
        
    }
    else if (newDragState == MAAnnotationViewDragStateEnding) {
        if (_endDrag) {
            _endDrag();
        }
        
    }
}

- (void)configureDragStateBlockWithStart:(void(^)())startDrag draging:(void(^)())draging end:(void(^)())endDrag{
    [self setStartDrag:^{
        if (startDrag) {
            startDrag();
        }
        
    }];
    [self setDraging:^{
        if (draging) {
            draging();
        }
        
    }];
    [self setEndDrag:^{
        if (endDrag) {
            endDrag();
        }
        
    }];
}
@end
