//
//  SearchTableViewController.m
//  BerryMaps
//
//  Created by Berry on 16/4/14.
//  Copyright © 2016年 BerryBeans. All rights reserved.
//

#import "SearchTableViewController.h"

static NSString *cellIdentifier = @"cellIdentifier";
@interface SearchTableViewController () <AMapSearchDelegate>
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) NSString *keyworks;
@property (nonatomic, assign) double    lat;
@property (nonatomic, assign) double    lon;
@property (nonatomic, copy)   NSString  *myCity;

@end

@implementation SearchTableViewController
- (instancetype)initWithKeyworks:(NSString *)keyworks locationWithLat:(double)lat lon:(double)lon
{
    self = [super init];
    if (self) {
        _keyworks = keyworks;
        _lat = lat;
        _lon = lon;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setupView{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.bounces = NO;
    
    
    [AMapSearchServices sharedServices].apiKey = @"cca661f233e4d01fac6e27e1f98b6bf5";
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    //反编码
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:_lat longitude:_lon];
    regeo.requireExtension = YES;
    //发起逆地理编码
    [self.search AMapReGoecodeSearch:regeo];
}
- (void)searchAroundPoi{
    
//    
//    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
//    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
//    request.location = [AMapGeoPoint locationWithLatitude:_lat longitude:_lon];
//    request.keywords = _keyworks;
//    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
//    // POI的类型共分为20种大类别，分别为：
//    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
//    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
//    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
//    request.types = @"餐饮服务|生活服务|汽车服务";
//    request.sortrule = 0;
//    request.requireExtension = YES;
//    
//    //发起周边搜索
//    [_search AMapPOIAroundSearch: request];
    
    
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.keywords = _keyworks;
    tipsRequest.city = _myCity;
    
    //发起输入提示搜索
    [_search AMapInputTipsSearch: tipsRequest];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArr == nil) {
        return 0;
    }
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    AMapTip *pointModel = self.dataArr[indexPath.row];
    cell.textLabel.text = pointModel.name;
    cell.detailTextLabel.text = pointModel.district;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AMapPOI *pointModel = self.dataArr[indexPath.row];
    if (_selectedBlock) {
        _selectedBlock(pointModel);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        return;
    }
    
    //通过 AMapPOISearchResponse 对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %ld",(long)response.count];
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
    NSString *strPoi = @"";
    for (AMapPOI *p in response.pois) {
        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.name];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strPoi];
    NSLog(@"Place: %@", result);
}
-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response
{
    if(response.tips.count == 0)
    {
        return;
    }
    self.dataArr = response.tips;
    [self.tableView reloadData];
    //通过AMapInputTipsSearchResponse对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %ld", (long)response.count];
    NSString *strtips = @"";
    for (AMapTip *p in response.tips) {
        strtips = [NSString stringWithFormat:@"%@\nTip: %@", strtips, p.description];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@", strCount, strtips];
    NSLog(@"InputTips: %@", result);
}
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        _myCity = response.regeocode.addressComponent.city;
        [self searchAroundPoi];

    }
}
@end
