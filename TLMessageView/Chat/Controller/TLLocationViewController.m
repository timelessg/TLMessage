//
//  TLLocationViewController.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/23.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLLocationViewController.h"
#import <MapKit/MapKit.h>
#import <Masonry.h>
#import "TLProjectMacro.h"

@interface TLLocationViewController ()
<MKMapViewDelegate,
CLLocationManagerDelegate,
UITableViewDelegate,
UITableViewDataSource>
@property(nonatomic,strong)MKMapView *mapView;
@property(nonatomic,strong)CLLocationManager *locationManager;
@property(nonatomic,strong)MKUserLocation *userLocation;
@property(nonatomic,strong)MKPointAnnotation *annotation;
@property(nonatomic,strong)UITableView *listTableView;
@property(nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation TLLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendLocationMsg)];
    self.navigationItem.rightBarButtonItem = sendItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.height.mas_offset(@300);
    }];
    
    [self.view addSubview:self.listTableView];
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.top.equalTo(self.mapView.mas_bottom).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
    
    [self.locationManager requestWhenInUseAuthorization];

    if([CLLocationManager locationServicesEnabled]){
        [self.locationManager startUpdatingLocation];
    }
}
- (void)sendLocationMsg{
    if (!self.userLocation) {
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    UIImage *image = [self snapshot:self.mapView];
    RCLocationMessage *msg = [RCLocationMessage messageWithLocationImage:image location:self.userLocation.location.coordinate locationName:self.userLocation.subtitle];
    if ([self.delegate respondsToSelector:@selector(locationViewControllerSendMsg:)]) {
        [self.delegate locationViewControllerSendMsg:msg];
    }
}
- (UIImage *)snapshot:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
#pragma - mark tableviewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    CLPlacemark *item = self.dataSource[indexPath.row];
    cell.textLabel.text = item.name;
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
#pragma mark – CLLocationManagerDelegate
//成功回调
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000 ,2000);
    
    if (!oldLocation) {
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
        [self.mapView setRegion:adjustedRegion animated:YES];

    }
}
//失败回调
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    
}
#pragma - mark mapviewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count == 0 || error) {
            NSLog(@"找不到该位置");
            return;
        }
        // 当前地标
        CLPlacemark *pm = [placemarks firstObject];
        // 区域名称
        userLocation.title = pm.locality;
        // 详细名称
        userLocation.subtitle = pm.name;
        
        self.userLocation = userLocation;
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObject:pm];
        [self.listTableView reloadData];
    }];
}
-(MKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] init];
        _mapView = [[MKMapView alloc] init];
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = YES;
        _mapView.delegate = self;
    }
    return _mapView;
}
-(CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = kCLDistanceFilterNone;//距离筛选器，单位米（移动多少米才回调更新）
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest; //精确度
        _locationManager.delegate = self;
    }
    return _locationManager;
}
-(MKPointAnnotation *)annotation{
    if (!_annotation) {
        _annotation = [[MKPointAnnotation alloc] init];
    }
    return _annotation;
}
-(UITableView *)listTableView{
    if (!_listTableView) {
        _listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.backgroundColor = UIColorFromRGB(0xebebeb);
        _listTableView.backgroundColor = UIColorFromRGB(0xf8f8f8);
        _listTableView.separatorColor = UIColorFromRGB(0xeeeeee);
        [_listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _listTableView;
}
-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
