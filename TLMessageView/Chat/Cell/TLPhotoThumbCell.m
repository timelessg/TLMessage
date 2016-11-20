//
//  TLPhotoThumbCell.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/25.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLPhotoThumbCell.h"
#import "TLProjectMacro.h"
#import "TLButton.h"
#import "PHAsset+Extend.h"

@interface TLPhotoThumbCell ()
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)TLButton *selectBtn;
@property(nonatomic,strong)PHImageRequestOptions *options;
@end

@implementation TLPhotoThumbCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}
-(void)setupView{
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.contentView addSubview:self.selectBtn];
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(5);
        make.right.equalTo(self.contentView.mas_right).offset(-5);
    }];
}
-(void)setItem:(PHAsset *)item{
    _item = item;
    self.selectBtn.selected = item.selected;
    [[PHImageManager defaultManager] requestImageForAsset:item targetSize:CGSizeMake(UI_SCREEN_HEIGHT / 4, UI_SCREEN_HEIGHT / 4) contentMode:PHImageContentModeDefault options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.imageView.image = result;
    }];
}
-(void)selectAction:(UIButton *)sender{
    self.item.selected = !sender.selected;
    if (self.selectBlock && self.selectBlock(self.item)){
        sender.selected = !sender.selected;
    }
}
-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}
-(TLButton *)selectBtn{
    if (!_selectBtn) {
        _selectBtn = [TLButton buttonWithType:UIButtonTypeCustom];
        [_selectBtn setImage:[UIImage imageNamed:@"photopicker_state_normal"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"photopicker_state_selected"] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}
-(PHImageRequestOptions *)options{
    if (!_options) {
        _options = [[PHImageRequestOptions alloc] init];
    }
    return _options;
}
@end
