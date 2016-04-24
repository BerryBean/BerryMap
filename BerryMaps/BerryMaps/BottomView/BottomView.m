//
//  BottomView.m
//  BerryMaps
//
//  Created by Berry on 16/4/12.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import "BottomView.h"
#import <Masonry.h>
#import <BlocksKit+UIKit.h>

@interface BottomView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *address;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *goLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *wayLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@end

@implementation BottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}
- (void)configureView{
    self.titleLabel = [[UILabel alloc] init];
    [self addSubview:self.titleLabel];
    
    self.address = [[UILabel alloc] init];
    [self addSubview:self.address];
    
    self.closeButton = [[UIButton alloc] init];
    [self.closeButton bk_whenTapped:^{
        _closeBlock();
    }];
    [self addSubview:self.closeButton];
    
    self.goLabel = [[UILabel alloc] init];
    self.goLabel.text = @"去这里";
    self.goLabel.userInteractionEnabled = YES;
    [self.goLabel bk_whenTapped:^{
        if (_goBlock) {
            _goBlock();
        }
        
    }];
    [self addSubview:self.goLabel];
    
    self.wayLabel = [[UILabel alloc] init];
    self.wayLabel.text = @"途径这里";
    self.wayLabel.userInteractionEnabled = YES;
    [self.wayLabel bk_whenTapped:^{
        if (_wayBlock) {
            _wayBlock();
        }
        
    }];
    [self addSubview:self.wayLabel];
    
    self.stateLabel = [[UILabel alloc] init];
    [self addSubview:self.stateLabel];
    
    self.distanceLabel = [[UILabel alloc] init];
    [self addSubview:self.distanceLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.height.equalTo(@(30));
        make.left.equalTo(self).offset(10);
    }];
    [self.address mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
        make.left.equalTo(self.titleLabel);
        make.height.equalTo(@(30));
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.right.equalTo(self).offset(10);
        make.height.width.equalTo(@(30));
    }];
    
    [self.goLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.address.mas_bottom).offset(20);
        make.left.equalTo(self.address);
        make.height.equalTo(@(30));
    }];
    
    [self.wayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.address.mas_bottom).offset(20);
        make.left.equalTo(self.goLabel.mas_right).offset(20);
        make.height.equalTo(@(30));
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.goLabel.mas_bottom).offset(20);
        make.left.equalTo(self.goLabel);
        make.height.equalTo(@(30));
    }];
    
    [self.distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stateLabel);
        make.left.equalTo(self.stateLabel.mas_right).offset(20);
        make.height.equalTo(@(30));
    }];
}
- (void)configureModel:(ChargingNetModel*)model{
    self.titleLabel.text = model.name;
    self.address.text = model.address;
    if (model.isUserType) {
        self.address.text = @"审核中……";
    }
    
        
    if (model.ev_nums) {
        NSString *state = [[NSString alloc] init];
        if (model.current_state) {
            state = @"是";
        }
        else
            state = @"否";
        self.stateLabel.text = [NSString stringWithFormat:@"是否可用：%@",state];

    }

}
- (void)updateDistance:(NSInteger)distance{
    self.distanceLabel.text = [NSString stringWithFormat:@"距离%ld米",(long)distance];
}
@end
