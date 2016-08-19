//
//  TLRecordVoiceHUD.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/19.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLRecordVoiceHUD : UIView
@property(nonatomic,strong)UIButton *statusBtn;
@property(nonatomic,strong)UIImageView *recordTipImage;

+(void)updatePeakPower:(CGFloat)peakPower;
+(void)showRecording;
+(void)showWCancel;
+(void)dismissWithRecordShort;
+(void)dismiss;
@end
