//
//  TLPhotoBrowser.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/21.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLPhotoBrowser.h"
#import "TLProjectMacro.h"

@interface TLPhotoBrowser () <UIActionSheetDelegate,UIScrollViewDelegate>
@property(nonatomic,strong)UIScrollView *bgScrollView;
@property(nonatomic,strong)UIImageView *photoView;
@property(nonatomic,assign)CGFloat lastscale;
@end

@implementation TLPhotoBrowser
-(instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image{
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0;
        self.userInteractionEnabled = YES;
        self.backgroundColor = UIColorFromRGB(0x000000);
        
        [self addSubview:self.bgScrollView];
        self.bgScrollView.frame = self.bounds;
        
        self.photoView.image = image;
        [self.bgScrollView addSubview:self.photoView];
        self.photoView.frame = self.bounds;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [tap setNumberOfTapsRequired:1];
        [self.photoView addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveImage:)];
        longPress.minimumPressDuration = 0.5;
        [self.photoView addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapZoom:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [self.photoView addGestureRecognizer:doubleTapGestureRecognizer];
        
        [tap requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        
    }
    return self;
}
+(void)showOriginalImage:(UIImage *)originalImage{
    TLPhotoBrowser *browser = [[TLPhotoBrowser alloc] initWithFrame:kKeyWindow.bounds image:originalImage];
    [browser show];
}
-(void)show{
    [kKeyWindow addSubview:self];
    self.frame = kKeyWindow.bounds;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
}
-(void)dismiss:(UITapGestureRecognizer *)sender{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
-(void)saveImage:(UILongPressGestureRecognizer *)sender{
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存" otherButtonTitles:nil];
    [sheet showInView:self];
}
-(void)setScrollZoom:(CGFloat)zoom{
    self.bgScrollView.zoomScale = 1;
}
-(void)doubleTapZoom:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:0.25 animations:^{
        if (self.bgScrollView.zoomScale < 1) {
            self.bgScrollView.zoomScale = 1.0f;
        }else if (self.bgScrollView.zoomScale == 1){
            self.bgScrollView.zoomScale = 2.0f;
        }else{
            self.bgScrollView.zoomScale = 1.0f;
        }
    }];
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    self.photoView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                            scrollView.contentSize.height * 0.5 + offsetY);
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.photoView;
}
-(UIImageView *)photoView{
    if (!_photoView) {
        _photoView = [[UIImageView alloc] init];
        _photoView.userInteractionEnabled = YES;
        _photoView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _photoView;
}
-(UIScrollView *)bgScrollView{
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc] init];
        _bgScrollView.delegate = self;
        _bgScrollView.minimumZoomScale = 0.8;
        _bgScrollView.maximumZoomScale = 2.0;
    }
    return _bgScrollView;
}
@end
