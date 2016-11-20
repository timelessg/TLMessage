//
//  TLPhotoPreviewViewController.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/25.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLPhotoPreviewViewController.h"
#import "TLProjectMacro.h"
#import "PHAsset+Extend.h"

@interface TLPhotoPreviewViewController ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
TLImageScrollViewDelegate>
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)UICollectionViewFlowLayout *colletionLayout;
@property(nonatomic,strong)UIVisualEffectView *bottomView;
@property(nonatomic,strong)UIVisualEffectView *navView;
@property(nonatomic,strong)UIButton *sendBtn;
@property(nonatomic,strong)TLCountLabel *countLabel;
@property(nonatomic,strong)UIButton *selectBtn;
@property(nonatomic,strong)UIButton *sendOriginalImgBtn;
@property(nonatomic,strong)UIButton *backBtn;
@property(nonatomic,strong)PHAsset *selectedAsset;
@property(nonatomic,strong)NSArray *assets;
@end

@implementation TLPhotoPreviewViewController
{
    BOOL _showNav;
    NSInteger _currentIndex;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
-(instancetype)initWithSelectedAsset:(PHAsset *)selectedAsset assets:(NSArray *)asstes{
    if (self = [super init]) {
        self.selectedAsset = selectedAsset;
        self.assets = asstes;
        _currentIndex = [self.assets indexOfObject:selectedAsset];
        self.selectBtn.selected = selectedAsset.selected;
        self.sendOriginalImgBtn.selected = selectedAsset.isOriginal;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.collectionView.contentOffset = CGPointMake(_currentIndex * self.collectionView.bounds.size.width, 0);
    
    [self.view addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_offset(@69);
    }];
    
    [self.navView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.navView.mas_left).offset(10);
        make.centerY.equalTo(self.navView.mas_centerY).offset(0);
    }];
    
    [self.navView addSubview:self.selectBtn];
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.navView.mas_right).offset(-10);
        make.centerY.equalTo(self.navView.mas_centerY).offset(0);
    }];
    
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.mas_offset(@44);
    }];
    
    [self.bottomView addSubview:self.sendOriginalImgBtn];
    [self.sendOriginalImgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView.mas_left).offset(10);
        make.centerY.equalTo(self.bottomView.mas_centerY).offset(0);
    }];
    
    [self.bottomView addSubview:self.sendBtn];
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView.mas_right).offset(-10);
        make.centerY.equalTo(self.bottomView.mas_centerY).offset(0);
    }];
}
-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)sendPhotoAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(sendPhotos)]) {
        [self.delegate sendPhotos];
    }
}
-(void)selectAction:(UIButton *)sender{
    PHAsset *currentAsset = self.assets[_currentIndex];
    currentAsset.selected = !currentAsset.selected;
    sender.selected = currentAsset.selected;
    if (currentAsset.selected) {
        [self.delegate selectedPhoto:currentAsset];
    }else{
        [self.delegate removePhoto:currentAsset];
    }
}
-(void)sendOriginalImgAction:(UIButton *)sender{
    PHAsset *currentAsset = self.assets[_currentIndex];
    currentAsset.isOriginal = !currentAsset.isOriginal;
    sender.selected = currentAsset.isOriginal;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TLPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imgScrollView.actionDelegate = self;
    cell.asset = self.assets[indexPath.row];
    return cell;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assets.count;
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.view.bounds.size.width + 20, self.view.bounds.size.height);
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat itemWidth = self.collectionView.frame.size.width;
    if (offsetX >= 0){
        NSInteger index = offsetX / itemWidth;
        _currentIndex = index;
        PHAsset *currentAsset = self.assets[_currentIndex];
        self.sendOriginalImgBtn.selected = currentAsset.isOriginal;
        self.selectBtn.selected = currentAsset.selected;
    }
}
-(void)imageScrollViewTap:(UITapGestureRecognizer *)sender{
    [self.navView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(_showNav ? 0 : -69);
    }];
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(_showNav ? 0 : 44);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            _showNav = !_showNav;
        }
    }];
}
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(- 10, 0, self.view.bounds.size.width + 20, self.view.bounds.size.height + 1) collectionViewLayout:self.colletionLayout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = YES;
        [_collectionView registerClass:[TLPhotoPreviewCell class] forCellWithReuseIdentifier:@"cell"];
        self.colletionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _collectionView;
}
-(UICollectionViewFlowLayout *)colletionLayout{
    if (!_colletionLayout) {
        _colletionLayout = [[UICollectionViewFlowLayout alloc] init];
        _colletionLayout.minimumInteritemSpacing = 0;
        _colletionLayout.minimumLineSpacing = 0;
        _colletionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _colletionLayout;
}
-(UIVisualEffectView *)navView{
    if (!_navView) {
        _navView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    }
    return _navView;
}
-(UIVisualEffectView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    }
    return _bottomView;
}
-(UIButton *)sendBtn{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitleColor:UIColorFromRGB(0x007AFF) forState:UIControlStateNormal];
        [_sendBtn setTitleColor:UIColorFromRGB(0xa3cdff) forState:UIControlStateDisabled];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_sendBtn addTarget:self action:@selector(sendPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}
-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
-(UIButton *)selectBtn{
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setImage:[UIImage imageNamed:@"photo_preview_unselected"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"photo_preview_selected"] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
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
-(UIButton *)sendOriginalImgBtn{
    if (!_sendOriginalImgBtn) {
        _sendOriginalImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendOriginalImgBtn setImage:[UIImage imageNamed:@"unselected_full"] forState:UIControlStateNormal];
        [_sendOriginalImgBtn setImage:[UIImage imageNamed:@"selected_full"] forState:UIControlStateSelected];
        [_sendOriginalImgBtn setTitle:@"原图" forState:UIControlStateNormal];
        [_sendOriginalImgBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [_sendOriginalImgBtn setTitleColor:UIColorFromRGB(0xcccccc) forState:UIControlStateSelected];
        _sendOriginalImgBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _sendOriginalImgBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_sendOriginalImgBtn addTarget:self action:@selector(sendOriginalImgAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendOriginalImgBtn;
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end




@implementation TLCountLabel
-(instancetype)init{
    if (self = [super init]) {
        self.clipsToBounds = YES;
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = UIColorFromRGB(0xff514e);
        self.font = [UIFont systemFontOfSize:15];
        self.textColor = UIColorFromRGB(0xffffff);
    }
    return self;
}
-(CGSize)intrinsicContentSize{
    CGSize size = [super intrinsicContentSize];
    return CGSizeMake(MAX(size.width + 8, size.height + 4), size.height + 4);
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.layer.cornerRadius = self.frame.size.height / 2.0;
}
@end





@implementation TLPhotoPreviewCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        if (!self.imgScrollView) {
            self.imgScrollView = [[TLImageScrollView alloc] initWithFrame:self.bounds];
            [self addSubview:self.imgScrollView];
        }
    }
    return self;
}
-(void)setAsset:(PHAsset *)asset{
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:[[PHImageRequestOptions alloc] init] resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.imgScrollView.img = result;
    }];
}
@end
