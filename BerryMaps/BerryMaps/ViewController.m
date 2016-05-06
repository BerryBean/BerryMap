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
#import "SearchTableViewController.h"
#import "CommonUtility.h"
static const CGFloat kBottomViewHeight = 200;
@interface ViewController () <MAMapViewDelegate, AMapSearchDelegate,CLLocationManagerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UIImageView *titleView;
@property (nonatomic, strong) MAMapView *maMapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UIButton      *showMeButton;
@property (nonatomic, strong) UIButton      *showTrafficButton;
@property (nonatomic, strong) UIButton      *showGoWhereButton;
@property (nonatomic, strong) MAUserLocation *meLocation;
@property (nonatomic, strong) NSArray   *dataArr;
@property (nonatomic, strong) BottomView    *bottomView;
@property (nonatomic, assign) BOOL      isBottomShow;
@property (nonatomic, assign) BOOL      isEditMode;
@property (nonatomic, strong) UITapGestureRecognizer *creatTap;
@property (nonatomic, strong) AMapSearchAPI     *search;
@property (nonatomic, strong) NSString          *myCity;
@property (nonatomic, strong) NSMutableArray    *overlayArr;
@property (nonatomic, strong) AMapGeoPoint      *desPoi;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavi];
    [self setupMap];
    [self setupSearchServer];
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
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] init];
    @WeakObj(self)
    [leftButton bk_initWithTitle:@"去哪儿" style:UIBarButtonItemStylePlain handler:^(id sender) {
        @StrongObj(self)
        [self showSearchInputAlert];
        
    }];
    self.navigationItem.leftBarButtonItem = leftButton;
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
    
    _showGoWhereButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height-150, 50, 50)];
    [_showGoWhereButton setImage:[UIImage imageNamed:@"ic_tab_me"] forState:UIControlStateNormal];
    @WeakObj(self)
    [_showGoWhereButton bk_whenTapped:^{
        @StrongObj(self)
        [self showSearchInputAlert];
    }];
    [self.view addSubview:_showGoWhereButton];
    
    
    
    
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
- (void)setupSearchServer{
    //配置用户Key
    [AMapSearchServices sharedServices].apiKey = @"cca661f233e4d01fac6e27e1f98b6bf5";
    
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    
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
    @WeakObj(self)
    [self.bottomView setGoBlock:^{
        @StrongObj(self)
        AMapGeoPoint *oriPoi = [AMapGeoPoint locationWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        NSArray *stringList = [model.coordinate componentsSeparatedByString:@","];
        AMapGeoPoint *desPoi = [AMapGeoPoint locationWithLatitude:[stringList[1] floatValue] longitude:[stringList[0] floatValue]];
        self.desPoi = desPoi;
        [self searchRouteWithOrigin:oriPoi  destination:desPoi waypoints:nil];
    }];
    [self.bottomView setWayBlock:^{
        @StrongObj(self)
        AMapGeoPoint *oriPoi = [AMapGeoPoint locationWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        NSArray *stringList = [model.coordinate componentsSeparatedByString:@","];
        AMapGeoPoint *wayPoi = [AMapGeoPoint locationWithLatitude:[stringList[1] floatValue] longitude:[stringList[0] floatValue]];
        NSArray *poiArr = @[wayPoi];
        [self searchRouteWithOrigin:oriPoi  destination:self.desPoi waypoints:poiArr];
    }];
    [self.bottomView setVerifyBlock:^{
        @StrongObj(self)
        UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"审核充电桩" message:@"是否真实？"];
        [alert bk_addButtonWithTitle:@"是" handler:^{
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm transactionWithBlock:^{
                model.verifyNum += 1;
                
            }];
            [self.bottomView updateVerifyNum:model];
        }];
        [alert bk_addButtonWithTitle:@"否" handler:^{
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm transactionWithBlock:^{
                model.noVerifyNum += 1;
            }];
            [self.bottomView updateVerifyNum:model];
        }];
        [alert show];
        
        
        
    }];
    
}
- (void)showSearchInputAlert{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入目的地" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView setCancelButtonIndex:0];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView bk_setDidDismissBlock:^(UIAlertView *alert, NSInteger index) {
        if (index == 0) {
            SearchTableViewController *tableVC = [[SearchTableViewController alloc] initWithKeyworks:[alertView textFieldAtIndex:0].text locationWithLat:_coordinate.latitude lon:_coordinate.longitude];
            @WeakObj(self)
            [tableVC setSelectedBlock:^(AMapPOI *poi) {
                @StrongObj(self)
                
                AMapGeoPoint *oriPoi = [AMapGeoPoint locationWithLatitude:_coordinate.latitude longitude:_coordinate.longitude];
                self.desPoi = poi.location;
                [self searchRouteWithOrigin:oriPoi  destination:poi.location waypoints:nil];
            }];
            [self.navigationController pushViewController:tableVC animated:YES];
            
        }

    }];
    
    [alertView show];

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
            [alertView setCancelButtonIndex:0];
            [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alertView bk_setDidDismissBlock:^(UIAlertView *alert, NSInteger index) {
                if (index == 0) {
                    pointAnn.title = [alertView textFieldAtIndex:0].text;
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    [realm transactionWithBlock:^{
                        model.name = [alertView textFieldAtIndex:0].text;
                        
                    }];
                    [self showAllTextDialog:@"建桩成功"];
                }
                else if (index == 1){
                    [_maMapView removeAnnotation:pointAnn];
                }
            }];
            
            [alertView show];
            [self saveData:model];
        }
        
        
    }];
    
    
}
- (void)searchRouteWithOrigin:(AMapGeoPoint *)origin destination:(AMapGeoPoint *)destination waypoints:(NSArray *)waypoints{
    
    NSLog(@"destination:lat:%f, lon:%f",destination.latitude,destination.longitude);
    NSLog(@"origin:lat:%f, lon:%f",origin.latitude,origin.longitude);
    //构造AMapDrivingRouteSearchRequest对象，设置驾车路径规划请求参数
    AMapDrivingRouteSearchRequest *request = [[AMapDrivingRouteSearchRequest alloc] init];
    request.waypoints = waypoints;
    request.origin = origin;
    request.destination = destination;
    request.strategy = 4;//距离优先
    request.requireExtension = YES;
    
    //发起路径搜索
    [_search AMapDrivingRouteSearch: request];
    
//    AMapWalkingRouteSearchRequest *requestW = [[AMapWalkingRouteSearchRequest alloc] init];
//    requestW.origin = origin;
//    requestW.destination = destination;
//    [_search AMapWalkingRouteSearch: requestW];
    
//    AMapBusLineNameSearchRequest *lineRequest = [[AMapBusLineNameSearchRequest alloc] init];
//    lineRequest.keywords = @"445";
//    lineRequest.city = @"beijing";
//    lineRequest.requireExtension = YES;
//    
//    //发起公交线路查询
//    [_search AMapBusLineNameSearch:lineRequest];
}
#pragma mark - 实现公交线路查询的回调函数
-(void)onBusLineSearchDone:(AMapBusLineBaseSearchRequest*)request response:(AMapBusLineSearchResponse *)response
{
    if(response.buslines.count == 0)
    {
        return;
    }
    
    //通过AMapBusLineSearchResponse对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %ld",(long)response.count];
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
    NSString *strLine = @"";
    for (AMapBusLine *p in response.buslines) {
        strLine = [NSString stringWithFormat:@"%@\nLine: %@", strLine, p.description];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strLine];
    NSLog(@"Line: %@", result);
}
#pragma mark - 实现路径搜索的回调函数
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if(response.route == nil)
    {
        return;
    }
    [_maMapView removeOverlays:_overlayArr];
    _overlayArr = [[NSMutableArray alloc] init];
    //通过AMapNavigationSearchResponse对象处理搜索结果
    NSString *route = [NSString stringWithFormat:@"Navi: %@", response.route];
    NSLog(@"%@", route);
    NSArray *arr = response.route.paths;
    if (arr.count > 0) {
        AMapPath *path = arr[0];
        [self.bottomView updateDistance:path.distance];
        for (AMapStep *step in path.steps) {
            NSUInteger count = 0;
            CLLocationCoordinate2D *coordinates = [CommonUtility coordinatesForString:step.polyline coordinateCount:&count parseToken:@";"];
            MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
            [_overlayArr addObject:commonPolyline];
            [_maMapView addOverlay: commonPolyline];
            
            
        }
    }
    
//    }
}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
}
#pragma mark - 显示toast
- (void)showAllTextDialog:(NSString *)str
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
    [self showPointWithCoordinate:_coordinate title:@"当前位置" subtitle:nil model:nil];
    [self showMe:self.showMeButton];
    
    
    
}
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error{

    
    NSLog(@"定位失败");
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    
}
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth = 6.f;
        polylineView.strokeColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.6];
        polylineView.lineJoinType = kMALineJoinRound;//连接类型
        polylineView.lineCapType = kMALineCapRound;//端点类型
        
        return polylineView;
    }
    return nil;
}

//- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
//{
//    /* 自定义定位精度对应的MACircleView. */
//    if (overlay == mapView.userLocationAccuracyCircle)
//    {
//        MACircleRenderer *accuracyCircleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
//        
//        accuracyCircleRenderer.lineWidth    = 2.f;
//        accuracyCircleRenderer.strokeColor  = [UIColor lightGrayColor];
//        accuracyCircleRenderer.fillColor    = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
//        
//        return accuracyCircleRenderer;
//    }
//    
//    return nil;
//}

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
            } draging:^{
                
            } end:^{
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
