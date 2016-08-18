//
//  TLVoiceMessageCell.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLVoiceMessageCell.h"

@interface TLVoiceMessageCell ()
@property(nonatomic,strong)UIImageView *voicePlayingImageView;
@end

@implementation TLVoiceMessageCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.bubbleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_offset(CGSizeMake(100, 50));
        }];
        
        [self.bubbleImageView addSubview:self.voicePlayingImageView];
        [self.voicePlayingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bubbleImageView.mas_left).offset(10);
            make.centerY.equalTo(self.bubbleImageView.mas_centerY).offset(0);
        }];
    }
    return self;
}
-(UIImageView *)voicePlayingImageView{
    if (!_voicePlayingImageView) {
        
    }
    return _voicePlayingImageView;
}
@end
