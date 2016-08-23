//
//  TLPhotoMessageCell.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLPhotoMessageCell.h"
#import <UIImageView+WebCache.h>
#import "TLPhotoBrowser.h"

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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickImage)];
        [self.photoImageView addGestureRecognizer:tap];
        
    }
    return self;
}
-(void)didClickImage{
    RCImageMessage *imgMessage = (RCImageMessage *)self.message.content;
    
    if (imgMessage.originalImage) {
        [TLPhotoBrowser showOriginalImage:imgMessage.originalImage];
    }else{
        [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:imgMessage.imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [TLPhotoBrowser showOriginalImage:image];
        }];
    }
}

-(void)updateMessage:(RCMessage *)message showDate:(BOOL)showDate{
    [super updateMessage:message showDate:showDate];
    RCImageMessage *imgMessage = (RCImageMessage *)message.content;
    self.photoImageView.image = imgMessage.thumbnailImage;
    
    CGSize size = CGSizeMake(150, 150);
    
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:self.bubbleImageView.image];
    imageViewMask.frame = CGRectMake(0, 0, size.width, size.height);
    self.photoImageView.layer.mask = imageViewMask.layer;
    
    [self.photoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(size);
    }];
}
-(UIImageView *)photoImageView{
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] init];
        _photoImageView.layer.masksToBounds = YES;
        _photoImageView.userInteractionEnabled = YES;
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_photoImageView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _photoImageView;
}
@end