//
//  ViewController.m
//  BerryMaps
//
//  Created by Berry on 16/4/7.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "DataManager.h"
#import "PoinAnnotationClass.h"
#import <BlocksKit+UIKit.h>
#import "BottomView.h"
#import <Realm/Realm.h>
#import "AnnotationViewClass.h"
#import <MBProgressHUD.h>
static const CGFloat kBottomViewHeight = 200;
@interface ViewController () <MAMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UIImageView *titleView;
@property (nonatomic, strong) MAMapView *maMapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UIButton *showMeButton;
@property (nonatomic, strong) UIButton    *showTrafficButton;
@property (nonatomic, strong) MAUserLocation *meLocation;
@property (nonatomic, strong) NSArray   *dataArr;
@property (nonatomic, strong) BottomView    *bottomView;
@property (nonatomic, assign) BOOL      isBottomShow;
@property (nonatomic, assign) BOOL      isEditMode;
@property (nonatomic, strong) UITapGestureRecognizer *creatTap;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavi];
    [self setupMap];
    [self setupView];
    [self setupBottomView];
    [self configureBuildPointTap];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setupNavi{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] init];
    @WeakObj(rightButton)
    [rightButton bk_initWithTitle:@"建桩" style:
        UIBarButtonItemStylePlain handler:^(id sender) {
        @StrongObj(rightButton)
        
        _isEditMode = !_isEditMode;
        if (_isEditMode) {
            rightButton.title = @"取消建桩";
            [_maMapView addGestureRecognizer:_creatTap];
        }
        else {
            rightButton.title = @"建桩";
            [_maMapView removeGestureRecognizer:_creatTap];
        }
    }];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}
- (void)setupView{
    _showMeButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height-100, 50, 50)];
    [_showMeButton setImage:[UIImage imageNamed:@"showMe"] forState:UIControlStateNormal];
    [_showMeButton addTarget:self action:@selector(showMe:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_showMeButton];
    
    _showTrafficButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height-50, 50, 50)];
    [_showTrafficButton setImage:[UIImage imageNamed:@"ic_tab_Charge"] forState:UIControlStateNormal];
    [_showTrafficButton bk_whenTapped:^{

        _maMapView.showTraffic = !_maMapView.isShowTraffic;
    }];
    [self.view addSubview:_showTrafficButton];
    
    
    
}

- (void)setupMap{
    [MAMapServices sharedServices].apiKey = @"cca661f233e4d01fac6e27e1f98b6bf5";
    _maMapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_maMapView];
    _maMapView.delegate = self;
    _maMapView.mapType = MAMapTypeStandard;
    _maMapView.showsUserLocation = YES;
    _maMapView.showsCompass = YES;
    _maMapView.compassOrigin = CGPointMake(20, 100);
    _maMapView.scaleOrigin = CGPointMake(20, 70);
    _maMapView.rotateEnabled = YES;
    _maMapView.scrollEnabled = YES;
    _maMapView.zoomEnabled = YES;
    _maMapView.showTraffic = YES;
    _maMapView.userTrackingMode = MAUserTrackingModeNone;
    _maMapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(113.449769, 23.163609);
    _coordinate = coordinate;
    MACoordinateSpan span = MACoordinateSpanMake(0.1, 0.1);
    MACoordinateRegion region = MACoordinateRegionMake(coordinate, span);
    _maMapView.region = region;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        //        总是定位
        [_locationManager requestAlwaysAuthorization];
        //        使用的时候才定位
//        [_locationManager requestWhenInUseAuthorization];
    }
    
    
    [_locationManager startUpdatingLocation];

}

- (void)setupBottomView{
    self.bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, kBottomViewHeight)];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    @WeakObj(self)
    [self.bottomView setCloseBlock:^{
        @StrongObj(self)
        [self hideBottomView];
    }];
    [self.view addSubview:self.bottomView];
    _isBottomShow = NO;
}
- (void)hideBottomView{
    if (_isBottomShow) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomView.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, kBottomViewHeight);
        }];
    }
    
    _isBottomShow = NO;
}
- (void)showBottomViewWithModel:(ChargingNetModel *)model{
    if (!_isBottomShow) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomView.frame = CGRectMake(0, self.view.bounds.size.height-kBottomViewHeight, self.view.bounds.size.width, kBottomViewHeight);
        }];
    }
    else {
        [self hideBottomView];
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomView.frame = CGRectMake(0, self.view.bounds.size.height-kBottomViewHeight, self.view.bounds.size.width, kBottomViewHeight);
        }];
    }
    
    _isBottomShow = YES;
    [self.bottomView configureModel:model];
    
}
- (void)configureBuildPointTap{
    _creatTap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (_isEditMode) {
            CLLocationCoordinate2D coordinate = [_maMapView convertPoint:location toCoordinateFromView:_maMapView];
            PoinAnnotationClass *pointAnn = [[PoinAnnotationClass alloc] init];
            pointAnn.coordinate = coordinate;
            ChargingNetModel *model = [[ChargingNetModel alloc] init];
            model.isUserType = YES;
            model._id = [[[NSUUID UUID] UUIDString] integerValue];
            model.coordinate = [NSString stringWithFormat:@"%f,%f",coordinate.longitude,coordinate.latitude];
            pointAnn.model = model;
            [_maMapView addAnnotation:pointAnn];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入电桩名字" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView setCancelButtonIndex:1];
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alertView bk_setDidDismissBlock:^(UIAlertView *alert, NSInteger index) {
                pointAnn.title = [alertView textFieldAtIndex:0].text;
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                    model.name = [alertView textFieldAtIndex:0].text;
                    
                }];
                [self showAllTextDialog:@"建桩成功"];
            }];
            
            [alertView show];
            [self saveData:model];
        }
        
        
    }];
    
    
}
-(void)showAllTextDialog:(NSString *)str
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = str;
    hud.mode = MBProgressHUDModeText;
    
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
    
}
#pragma mark - action
- (void)showMe:(UIButton *)sender{
    MACoordinateSpan span = MACoordinateSpanMake(0.1, 0.1);
    MACoordinateRegion region = MACoordinateRegionMake(_coordinate, span);
    [_maMapView setRegion:region];
}
- (void)showPointWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle model:(ChargingNetModel *)model{
    PoinAnnotationClass *pointAnnotation = [[PoinAnnotationClass alloc] init];
    pointAnnotation.coordinate = coordinate;
    pointAnnotation.title = title;
    pointAnnotation.subtitle = subtitle;
    pointAnnotation.model = model;
    
    [_maMapView addAnnotation:pointAnnotation];
}

#pragma mark - delegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
//    CLLocation *location = userLocation.location;
    CLLocationCoordinate2D coordinate = userLocation.coordinate;
    _coordinate = coordinate;
    NSLog(@"我的坐标位置：%f, %f", coordinate.longitude, coordinate.latitude);
    
    _maMapView.showsUserLocation = NO;
    [self showPointWithCoordinate:coordinate title:@"当前位置" subtitle:nil model:nil];
    [self showMe:self.showMeButton];
    
}
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error{

    
    NSLog(@"定位失败");
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{

}
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    /* 自定义定位精度对应的MACircleView. */
    if (overlay == mapView.userLocationAccuracyCircle)
    {
        MACircleRenderer *accuracyCircleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        accuracyCircleRenderer.lineWidth    = 2.f;
        accuracyCircleRenderer.strokeColor  = [UIColor lightGrayColor];
        accuracyCircleRenderer.fillColor    = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
        
        return accuracyCircleRenderer;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
    static NSString *otherLocationStyleReuseIndetifier = @"otherLocationStyleReuseIndetifier";
    /* 自定义userLocation对应的annotationView. */
    if ([annotation isKindOfClass:[PoinAnnotationClass class]])
    {
    
        PoinAnnotationClass *myAnnotation = (PoinAnnotationClass *)annotation;
        ChargingNetModel *model = myAnnotation.model;
        
        
        if (model.isUserType) {
            AnnotationViewClass *annotationView = (AnnotationViewClass *)[mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[AnnotationViewClass alloc] initWithAnnotation:annotation
                                                                 reuseIdentifier:userLocationStyleReuseIndetifier];
            }
            annotationView.draggable = YES;
            annotationView.canShowCallout = YES;
            UIImage *pointImage = [UIImage imageNamed:@"ic_home_other"];
            annotationView.image = pointImage;
            [annotationView configureDragStateBlockWithStart:^{
//                annotationView.centerOffset = CGPointMake(0, -18);
            } draging:^{
                
            } end:^{
//                annotationView.centerOffset = CGPointMake(0, 18);
                NSString *locaString = [NSString stringWithFormat:@"%f,%f",myAnnotation.coordinate.longitude,myAnnotation.coordinate.latitude];
                NSLog(@"%@",locaString);
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                    model.coordinate = [NSString stringWithFormat:@"%f,%f",myAnnotation.coordinate.longitude,myAnnotation.coordinate.latitude];
                }];
            }];
            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_tab_found"]];
            annotationView.leftCalloutAccessoryView.userInteractionEnabled = YES;
            @WeakObj(self);
            [annotationView.leftCalloutAccessoryView bk_whenTapped:^{
                @StrongObj(self);
                [self showBottomViewWithModel:model];
            }];
            return annotationView;
        }
        else {
            AnnotationViewClass *annotationView = (AnnotationViewClass *)[mapView dequeueReusableAnnotationViewWithIdentifier:otherLocationStyleReuseIndetifier];
            if (annotationView == nil)
            {
                annotationView = [[AnnotationViewClass alloc] initWithAnnotation:annotation
                                                                 reuseIdentifier:otherLocationStyleReuseIndetifier];
            }
            annotationView.canShowCallout= YES;
            annotationView.draggable = NO;
            UIImage *pointImage = [UIImage imageNamed:@"user"];
            if ([model.type isEqualToString:@"1"]) {
                pointImage = [UIImage imageNamed:@"ic_home_gb"];
            } else if([model.type isEqualToString:@"2"]){
                pointImage = [UIImage imageNamed:@"ic_home_tsl"];
            } else if([model.type isEqualToString:@"3"]){
                pointImage = [UIImage imageNamed:@"ic_home_byd"];
            }
            annotationView.image = pointImage;
            annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_tab_found"]];
            annotationView.leftCalloutAccessoryView.userInteractionEnabled = YES;
            @WeakObj(self);
            [annotationView.leftCalloutAccessoryView bk_whenTapped:^{
                @StrongObj(self);
                [self showBottomViewWithModel:model];
            }];
            return annotationView;
        }
        
        
        
    }
    return nil;
}


#pragma mark - getData
- (void)getData{
    RLMRealm *realm = [RLMRealm defaultRealm];
    if ([realm isEmpty]) {
        [DataManager getChargingNetDataWithSuccessBlock:^(NSArray *arr) {
            
            self.dataArr = arr;
            
            for (ChargingNetModel *model in arr) {
                [self saveData:model];
                NSString *lat = [model.coordinate componentsSeparatedByString:@","][1];
                NSString *lon = [model.coordinate componentsSeparatedByString:@","][0];
                
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]);
                [self showPointWithCoordinate:coordinate title:model.name subtitle:model.address model:model];
            }
        } failueBlock:^(NSError *error) {
            
        }];
    }
    else {
        NSMutableArray *muArr = [[NSMutableArray alloc] init];
        RLMResults *results = [ChargingNetModel allObjects];
        for (ChargingNetModel *model in results) {
            NSString *lat = [model.coordinate componentsSeparatedByString:@","][1];
            NSString *lon = [model.coordinate componentsSeparatedByString:@","][0];
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]);
            [self showPointWithCoordinate:coordinate title:model.name subtitle:model.address model:model];
            [muArr addObject:model];
        }
        self.dataArr = muArr;
        
    }
    
}
- (void)saveData:(ChargingNetModel *)model{

    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addObject:model];
    }];
}

@end
