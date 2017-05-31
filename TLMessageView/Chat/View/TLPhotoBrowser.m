//
//  TLPhotoBrowser.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/21.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLPhotoBrowser.h"
#import "TLProjectMacro.h"

@interface TLPhotoBrowser () <UIActionSheetDelegate,TLImageScrollViewDelegate>
@end

@implementation TLPhotoBrowser
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = UIColorFromRGB(0x000000);
        
        [self addSubview:self.imageScrollView];
    }
    return self;
}
+(void)showOriginalImage:(UIImage *)originalImage{
    TLPhotoBrowser *browser = [[TLPhotoBrowser alloc] initWithFrame:kKeyWindow.bounds];
    browser.imageScrollView.img = originalImage;
    [browser show];
}
-(void)show{
    self.alpha = 0;
    [kKeyWindow addSubview:self];
    self.frame = kKeyWindow.bounds;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];    
}
-(void)imageScrollViewLongTap:(UILongPressGestureRecognizer *)sender{
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存" otherButtonTitles:nil];
    [sheet showInView:self];
}
-(void)imageScrollViewTap:(UITapGestureRecognizer *)sender{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
-(TLImageScrollView *)imageScrollView{
    if (!_imageScrollView) {
        _imageScrollView = [[TLImageScrollView alloc] initWithFrame:self.bounds];
        _imageScrollView.actionDelegate = self;
    }
    return _imageScrollView;
}
@end




@interface TLImageScrollView ()
@property(nonatomic,strong)UIImageView *photoView;
@end

@implementation TLImageScrollView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.minimumZoomScale = 0.8;
        self.maximumZoomScale = 2.0;
        
        [self addSubview:self.photoView];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        longPress.minimumPressDuration = 0.5;
        [self addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
        [doubleTap setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [tap setNumberOfTapsRequired:1];
        [self addGestureRecognizer:tap];
        
        [tap requireGestureRecognizerToFail:doubleTap];

    }
    return self;
}
-(void)doubleTapAction:(UITapGestureRecognizer *)sender{
    [UIView animateWithDuration:0.25 animations:^{
        if (self.zoomScale < 1) {
            self.zoomScale = 1.0f;
        }else if (self.zoomScale == 1){
            self.zoomScale = 2.0f;
        }else{
            self.zoomScale = 1.0f;
        }
    }];
}
-(void)longPressAction:(UILongPressGestureRecognizer *)sender{
    if ([self.actionDelegate respondsToSelector:@selector(imageScrollViewLongTap:)]) {
        [self.actionDelegate imageScrollViewLongTap:sender];
    }
}
-(void)tapAction:(UITapGestureRecognizer *)sender{
    if ([self.actionDelegate respondsToSelector:@selector(imageScrollViewTap:)]) {
        [self.actionDelegate imageScrollViewTap:sender];
    }
}
-(void)setScrollZoom:(CGFloat)zoom{
    self.zoomScale = 1;
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
-(void)setImg:(UIImage *)img{
    if (_img != img) {
        _img = img;
        self.photoView.image = img;
    }
}
-(UIImageView *)photoView{
    if (!_photoView) {
        _photoView = [[UIImageView alloc] initWithFrame:self.bounds];
        _photoView.userInteractionEnabled = YES;
        _photoView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _photoView;
}
@end
