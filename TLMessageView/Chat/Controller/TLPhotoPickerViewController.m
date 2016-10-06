//
//  TLPhotoPickerViewController.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/25.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLPhotoPickerViewController.h"
#import "TLProjectMacro.h"
#import "TLPhotoThumbCell.h"
#import "TLPhotoPreviewViewController.h"

@interface TLPhotoPickerViewController ()

<UICollectionViewDelegate,
UICollectionViewDataSource>

@property(nonatomic,strong)UICollectionView *photoCollectionView;
@property(nonatomic,strong)UICollectionViewFlowLayout *colletionLayout;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)UIView *line;
@property(nonatomic,strong)UIButton *previewBtn;
@property(nonatomic,strong)UIButton *sendBtn;
@property(nonatomic,strong)TLCountLabel *countLabel;
@property(nonatomic,strong)NSMutableArray *dataSource;
@property(nonatomic,strong)NSMutableArray *selectPhotos;
@end

@implementation TLPhotoPickerViewController
-(instancetype)initWithDelegate:(id<TLPhotoPickerDelegate>)delegate{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"照相机胶卷";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];

    [self.view addSubview:self.photoCollectionView];
    [self.photoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photoCollectionView.mas_bottom).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.height.mas_offset(@40);
    }];
    
    [self.bottomView addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView.mas_left).offset(0);
        make.right.equalTo(self.bottomView.mas_right).offset(0);
        make.top.equalTo(self.bottomView.mas_top).offset(0);
        make.height.mas_offset(@0.5);
    }];
    
    [self.bottomView addSubview:self.previewBtn];
    [self.previewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView.mas_left).offset(0);
        make.top.equalTo(self.bottomView.mas_top).offset(0);
        make.bottom.equalTo(self.bottomView.mas_bottom).offset(0);
        make.width.mas_offset(@50);
    }];
    
    [self.bottomView addSubview:self.sendBtn];
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView.mas_right).offset(0);
        make.top.equalTo(self.bottomView.mas_top).offset(0);
        make.bottom.equalTo(self.bottomView.mas_bottom).offset(0);
        make.width.mas_offset(@50);
    }];
    
    [self.bottomView addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.sendBtn.mas_left).offset(0);
        make.centerY.equalTo(self.sendBtn.mas_centerY).offset(0);
    }];
    
    [self loadPhotos];
}
- (void)cancel{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)loadPhotos{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"在设置中允许照片访问" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    for (NSInteger i = 0; i < assetsFetchResults.count; i++) {
        PHAsset *asset = assetsFetchResults[i];
        if (asset.mediaType == PHAssetMediaTypeImage) {
            [self.dataSource addObject:asset];
        }
    }
    [self.photoCollectionView reloadData];
}
-(void)sendPhotoAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(didSendPhotos:)]) {
            [self.delegate didSendPhotos:self.selectPhotos];
        }
    }];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TLPhotoThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.item = self.dataSource[indexPath.row];
    weakifySelf;
    cell.selectBlock = ^(PHAsset *x){
        strongifySelf;
        if (self.selectPhotos.count > 8 && x.selected) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"最多只能选择9张照片" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return NO;
        }else{
            x.selected ? [self.selectPhotos addObject:x] : [self.selectPhotos removeObject:x];
            self.countLabel.text = @(self.selectPhotos.count).stringValue;
            self.countLabel.hidden = !self.selectPhotos.count;
            self.sendBtn.enabled = self.selectPhotos.count;
            self.previewBtn.enabled = self.selectPhotos.count;
            return YES;
        }
    };
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *item = self.dataSource[indexPath.row];
    TLPhotoPreviewViewController *vc = [[TLPhotoPreviewViewController alloc] initWithSelectedAsset:item assets:self.dataSource];
    [self.navigationController pushViewController:vc animated:YES];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (UI_SCREEN_WIDTH - 25) / 4;
    return CGSizeMake(width, width);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}
-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
-(NSMutableArray *)selectPhotos{
    if (!_selectPhotos) {
        _selectPhotos = [NSMutableArray array];
    }
    return _selectPhotos;
}
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        
    }
    return _bottomView;
}
-(UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = UIColorFromRGB(0xcccccc);
    }
    return _line;
}
-(UIButton *)previewBtn{
    if (!_previewBtn) {
        _previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_previewBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        [_previewBtn setTitleColor:UIColorFromRGB(0xcccccc) forState:UIControlStateDisabled];
        [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        _previewBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _previewBtn.enabled = NO;
    }
    return _previewBtn;
}
-(UIButton *)sendBtn{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitleColor:UIColorFromRGB(0x007AFF) forState:UIControlStateNormal];
        [_sendBtn setTitleColor:UIColorFromRGB(0xa3cdff) forState:UIControlStateDisabled];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_sendBtn addTarget:self action:@selector(sendPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        _sendBtn.enabled = NO;
    }
    return _sendBtn;
}
-(TLCountLabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[TLCountLabel alloc] init];
        _countLabel.backgroundColor = UIColorFromRGB(0x007AFF);
        _countLabel.textColor = UIColorFromRGB(0xffffff);
        _countLabel.font = [UIFont systemFontOfSize:15];
        _countLabel.hidden = YES;
    }
    return _countLabel;
}
-(UICollectionView *)photoCollectionView{
    if (!_photoCollectionView) {
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT) collectionViewLayout:self.colletionLayout];
        _photoCollectionView.delegate = self;
        _photoCollectionView.dataSource = self;
        _photoCollectionView.showsVerticalScrollIndicator = NO;
        _photoCollectionView.scrollsToTop = YES;
        _photoCollectionView.alwaysBounceVertical = YES;
        [_photoCollectionView registerClass:[TLPhotoThumbCell class] forCellWithReuseIdentifier:@"cell"];
        _photoCollectionView.backgroundColor = UIColorFromRGB(0xFFFAFAFA);
    }
    return _photoCollectionView;
}
-(UICollectionViewFlowLayout *)colletionLayout{
    if (!_colletionLayout) {
        _colletionLayout = [[UICollectionViewFlowLayout alloc]init];
    }
    return _colletionLayout;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
