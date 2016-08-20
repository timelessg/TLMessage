//
//  TLPhotoMessageCell.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLPhotoMessageCell.h"
#import <UIImageView+WebCache.h>

@interface TLPhotoMessageCell ()
@property(nonatomic,strong)UIImageView *photoImageView;
@end

@implementation TLPhotoMessageCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.bubbleImageView addSubview:self.photoImageView];
        [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.bubbleImageView);
        }];
    }
    return self;
}
-(void)updateMessage:(RCMessage *)message showDate:(BOOL)showDate{
    [super updateMessage:message showDate:showDate];
    RCImageMessage *imgMessage = (RCImageMessage *)message.content;
    self.photoImageView.image = imgMessage.thumbnailImage;    
}
-(UIImageView *)photoImageView{
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] init];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _photoImageView;
}
- (void)makeMaskView:(UIView *)view withImage:(UIImage *)image{
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 0.0f, 0.0f);
    view.layer.mask = imageViewMask.layer;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self makeMaskView:self.photoImageView withImage:self.bubbleImageView.image];
}
@end