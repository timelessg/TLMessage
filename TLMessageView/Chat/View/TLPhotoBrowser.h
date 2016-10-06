//
//  TLPhotoBrowser.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/21.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLImageScrollView;

@protocol TLImageScrollViewDelegate <NSObject>
@optional
-(void)imageScrollViewLongTap:(UILongPressGestureRecognizer *)sender;
-(void)imageScrollViewTap:(UITapGestureRecognizer *)sender;
@end

@interface TLPhotoBrowser : UIView
@property(nonatomic,strong)TLImageScrollView *imageScrollView;
+(void)showOriginalImage:(UIImage *)originalImage;
@end


@interface TLImageScrollView : UIScrollView <UIScrollViewDelegate>
@property(nonatomic,assign)id <TLImageScrollViewDelegate> actionDelegate;
@property(nonatomic,strong)UIImage *img;
@end
