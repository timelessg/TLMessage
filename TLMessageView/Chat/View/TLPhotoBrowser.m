//
//  TLPhotoBrowser.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/21.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLPhotoBrowser.h"
#import "TLProjectMacro.h"
#import <Masonry.h>

@implementation TLPhotoBrowser
+(void)showOriginalImage:(UIImage *)originalImage{
    UIView *bgView = [[UIView alloc] init];
    bgView.alpha = 0;
    bgView.userInteractionEnabled = YES;
    bgView.backgroundColor = UIColorFromRGB(0x000000);
    [kKeyWindow addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(kKeyWindow);
    }];
    
    UIImageView *photoView = [[UIImageView alloc] init];
    photoView.image = originalImage;
    [bgView addSubview:photoView];
    
    [photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(kKeyWindow);
        make.width.mas_equalTo(kKeyWindow.mas_width).priorityHigh(0);
        make.height.mas_equalTo(originalImage.size.height * kKeyWindow.bounds.size.width / originalImage.size.width).priorityHigh(0);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        bgView.alpha = 1;
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [bgView addGestureRecognizer:tap];
}
+(void)dismiss:(UITapGestureRecognizer *)sender{
    [UIView animateWithDuration:0.25 animations:^{
        sender.view.alpha = 0;
    } completion:^(BOOL finished) {
        [sender.view removeFromSuperview];
    }];
}
@end
