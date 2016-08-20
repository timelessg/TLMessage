//
//  TLRecordVoice.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/19.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TLRecorderVoiceDelegate <NSObject>
-(void)recorderVoiceFailure;
-(void)recorderVoiceSuccessWithVoiceData:(NSData *)voiceData duration:(long)duration;
@end

@interface TLRecordVoice : NSObject
@property(nonatomic,assign)id <TLRecorderVoiceDelegate> delegate;
-(instancetype)initWithDelegate:(id <TLRecorderVoiceDelegate>)delegate;
-(void)startRecord;
-(void)completeRecord;
-(void)cancelRecord;
@end
