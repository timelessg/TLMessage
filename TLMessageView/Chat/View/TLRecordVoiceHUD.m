//
//  TLRecordVoiceHUD.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/19.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLRecordVoiceHUD.h"
#import "TLProjectMacro.h"

@interface TLRecordVoiceHUD ()
@end

@implementation TLRecordVoiceHUD
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGBA(0x000000, 0.5);
        self.layer.cornerRadius = 4.0f;
        
        [self addSubview:self.recordTipImage];
        [self.recordTipImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(20);
            make.centerX.equalTo(self.mas_centerX).offset(0);
            make.size.mas_offset(CGSizeMake(90, 90));
        }];
        
        [self addSubview:self.statusBtn];
        [self.statusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(7);
            make.right.equalTo(self.mas_right).offset(-7);
            make.bottom.equalTo(self.mas_bottom).offset(-7);
            make.height.mas_offset(22);
        }];
        
        self.tag = 999;
    }
    return self;
}
+(void)updatePeakPower:(CGFloat)peakPower{
    TLRecordVoiceHUD *hud = [kKeyWindow viewWithTag:999];
    if (!hud){
        hud = [[TLRecordVoiceHUD alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        hud.center = kKeyWindow.center;
        [kKeyWindow addSubview:hud];
    };
    
    NSDictionary *dic = @{@[@0,@0.125]:@"voice_1",@[@0.126,@0.250]:@"voice_2",@[@0.251,@0.375]:@"voice_3",@[@0.376,@0.500]:@"voice_4",@[@0.501,@0.625]:@"voice_5",@[@0.626,@0.750]:@"voice_6",@[@0.751,@0.875]:@"voice_7",@[@0.876,@1]:@"voice_8"};
    
    NSString *value;
    for (NSArray *key in dic) {
        if (peakPower < [key[1] floatValue] && peakPower > [key[0] floatValue]) {
            value =  dic[key];
            break;
        }
    }
    if (!value) {
        return;
    }
    
    hud.recordTipImage.image = [UIImage imageNamed:value];
}
+(void)showRecording{
    TLRecordVoiceHUD *hud = [kKeyWindow viewWithTag:999];
    if (!hud){
        hud = [[TLRecordVoiceHUD alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        hud.center = kKeyWindow.center;
        [kKeyWindow addSubview:hud];
        
        hud.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^{
            hud.alpha = 1;
        }];
    };
    
    hud.statusBtn.selected = NO;
    [hud.statusBtn setTitle:@"手指上划，取消发送" forState:UIControlStateNormal];
}
+(void)showWCancel{
    TLRecordVoiceHUD *hud = [kKeyWindow viewWithTag:999];    
    hud.recordTipImage.image = [UIImage imageNamed:@"return"];
    hud.statusBtn.selected = YES;
    [hud.statusBtn setTitle:@"松开手指，取消发送" forState:UIControlStateNormal];
}
+(void)dismiss{
    TLRecordVoiceHUD *hud = [kKeyWindow viewWithTag:999];
    [UIView animateWithDuration:0.1 animations:^{
        hud.alpha = 0;
    } completion:^(BOOL finished) {
        [hud removeFromSuperview];
    }];
}
+(void)dismissWithRecordShort{
    TLRecordVoiceHUD *hud = [kKeyWindow viewWithTag:999];
    hud.recordTipImage.image = [UIImage imageNamed:@"return"];
    [hud.statusBtn setTitle:@"录音时间短" forState:UIControlStateNormal];
    hud.statusBtn.selected = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            hud.alpha = 0;
        } completion:^(BOOL finished) {
            [hud removeFromSuperview];
        }];
    });
}
-(UIImageView *)recordTipImage{
    if (!_recordTipImage) {
        _recordTipImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_1"]];
    }
    return _recordTipImage;
}
-(UIButton *)statusBtn{
    if (!_statusBtn) {
        _statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _statusBtn.userInteractionEnabled = NO;
        _statusBtn.titleLabel.font = [UIFont systemFontOfSize:13.5];
        [_statusBtn setBackgroundImage:[UIImage imageNamed:@"red_background"] forState:UIControlStateSelected];
    }
    return _statusBtn;
}
@end
