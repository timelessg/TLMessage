//
//  TLVoiceMessageCell.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLVoiceMessageCell.h"
#import "TLVoicePlayer.h"

@interface TLVoiceMessageCell ()
@property(nonatomic,strong)UIImageView *voicePlayingImageView;
@property(nonatomic,strong)UILabel *voiceDurationLabel;
@end

@implementation TLVoiceMessageCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.bubbleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_offset(CGSizeMake(80, 40));
        }];
        
        [self.bubbleImageView addSubview:self.voicePlayingImageView];
        [self.voicePlayingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            SMAS(make.left.equalTo(self.bubbleImageView.mas_left).offset(10));
            make.centerY.equalTo(self.bubbleImageView.mas_centerY).offset(0);
            make.size.mas_offset(CGSizeMake(20, 20));
        }];
        
        [self.bubbleImageView addSubview:self.voiceDurationLabel];
        [self.voiceDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            SMAS(make.right.equalTo(self.bubbleImageView.mas_right).offset(5));
            make.centerY.equalTo(self.bubbleImageView.mas_centerY).offset(0);
        }];
        
        self.bubbleImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *playTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playRecord)];
        [self.bubbleImageView addGestureRecognizer:playTap];
    }
    return self;
}
-(void)playRecord{
    void (^didFinishPlay)(void) = ^(){
        [self.voicePlayingImageView stopAnimating];
        self.isPlaying = NO;
        [[TLVoicePlayer sharePlayer] endPlay];
    };
    
    if (!self.isPlaying) {
        [self.voicePlayingImageView startAnimating];
        self.isPlaying = YES;
        [[TLVoicePlayer sharePlayer] playVoiceWithData:((RCVoiceMessage *)self.message.content).wavAudioData didFinish:didFinishPlay];
    }else{
        didFinishPlay();
    }
}
-(void)updateDirection:(RCMessageDirection)direction{
    [super updateDirection:direction];
    
    [self.voicePlayingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (direction == MessageDirection_RECEIVE) {
            SMAS(make.left.equalTo(self.bubbleImageView.mas_left).offset(10));
        }else{
            SMAS(make.right.equalTo(self.bubbleImageView.mas_right).offset(-10));
        }
    }];
    
    [self.voiceDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (direction == MessageDirection_RECEIVE) {
            SMAS(make.right.equalTo(self.bubbleImageView.mas_right).offset(-10));
        }else{
            SMAS(make.left.equalTo(self.bubbleImageView.mas_left).offset(10));
        }
    }];
}
-(void)updateMessage:(RCMessage *)message showDate:(BOOL)showDate{
    [super updateMessage:message showDate:showDate];
    
    self.voicePlayingImageView.animationImages = message.messageDirection == MessageDirection_RECEIVE ? @[[UIImage imageNamed:@"from_voice_1"],[UIImage imageNamed:@"from_voice_2"],[UIImage imageNamed:@"from_voice_3"]] : @[[UIImage imageNamed:@"to_voice_1"],[UIImage imageNamed:@"to_voice_2"],[UIImage imageNamed:@"to_voice_3"]];
    
    self.voicePlayingImageView.image = message.messageDirection == MessageDirection_RECEIVE ? [UIImage imageNamed:@"from_voice"] : [UIImage imageNamed:@"to_voice"];
    
    self.voiceDurationLabel.text = [NSString stringWithFormat:@"%ld''",((RCVoiceMessage *)message.content).duration];
}
-(UIImageView *)voicePlayingImageView{
    if (!_voicePlayingImageView) {
        _voicePlayingImageView = [[UIImageView alloc] init];
        _voicePlayingImageView.userInteractionEnabled = YES;
        _voicePlayingImageView.animationDuration = 1;
        _voicePlayingImageView.animationRepeatCount = 0;
    }
    return _voicePlayingImageView;
}
-(UILabel *)voiceDurationLabel{
    if (!_voiceDurationLabel) {
        _voiceDurationLabel = [[UILabel alloc] init];
        _voiceDurationLabel.textColor = UIColorFromRGB(0x4182b5);
        _voiceDurationLabel.font = [UIFont systemFontOfSize:15];
    }
    return _voiceDurationLabel;
}
@end
