//
//  TLPhotoPreviewViewController.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/25.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLPhotoPreviewViewController.h"
#import "TLProjectMacro.h"

@interface TLPhotoPreviewViewController ()
@property(nonatomic,strong)UIVisualEffectView *bottomView;
@property(nonatomic,strong)UIButton *sendBtn;
@property(nonatomic,strong)TLCountLabel *countLabel;
@property(nonatomic,strong)UIButton *selectBtn;
@property(nonatomic,strong)UIButton *sendOriginalImgBtn;
@end

@implementation TLPhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)sendPhotoAction:(UIButton *)sender{
    
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
        [_sendOriginalImgBtn setImage:[UIImage imageNamed:@"photo_preview_unselected"] forState:UIControlStateNormal];
        [_sendOriginalImgBtn setImage:[UIImage imageNamed:@"photo_preview_selected"] forState:UIControlStateSelected];
        [_sendOriginalImgBtn setTitle:@"原图" forState:UIControlStateNormal];
        [_sendOriginalImgBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [_sendOriginalImgBtn setTitleColor:UIColorFromRGB(0xcccccc) forState:UIControlStateSelected];
        _sendOriginalImgBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _sendOriginalImgBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    }
    return _sendOriginalImgBtn;
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