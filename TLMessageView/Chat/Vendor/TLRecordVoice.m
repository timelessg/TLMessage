//
//  TLRecordVoice.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/19.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLRecordVoice.h"
#import <AVFoundation/AVFoundation.h>
#import "TLRecordVoiceHUD.h"

@interface TLRecordVoice () <AVAudioRecorderDelegate>
@property(nonatomic,strong)AVAudioSession *audioSession;
@property(nonatomic,strong)AVAudioRecorder *audioRecorder;
@property(nonatomic,strong)NSTimer *timer;
@end

@implementation TLRecordVoice
-(instancetype)initWithDelegate:(id<TLRecorderVoiceDelegate>)delegate{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}
-(void)startRecord{
    [self configSession];
    [self configRecord];
    [self.audioRecorder record];
    
    [TLRecordVoiceHUD showRecording];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(observerVoiceVolume) userInfo:nil repeats:YES];
}
-(void)completeRecord{
    if (self.audioRecorder.currentTime > 2) {
        [TLRecordVoiceHUD dismiss];
        NSData *data = [[NSData alloc] initWithContentsOfURL:[self recordFilePath]];
        if ([self.delegate respondsToSelector:@selector(recorderVoiceSuccessWithVoiceData:duration:)]) {
            [self.delegate recorderVoiceSuccessWithVoiceData:data duration:self.audioRecorder.currentTime];
        }
    }else {
        [TLRecordVoiceHUD dismissWithRecordShort];
    }
    [self endRecord];
}
-(void)cancelRecord{
    [self endRecord];
    [TLRecordVoiceHUD dismiss];
}
- (void)endRecord{
    [self.audioRecorder deleteRecording];
    [self.audioRecorder stop];
    [self.timer invalidate];
}
- (void)observerVoiceVolume{
    [self.audioRecorder updateMeters];
    CGFloat lowPassResults = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    [TLRecordVoiceHUD updatePeakPower:lowPassResults];
}

-(void)configSession{
    self.audioSession = [AVAudioSession sharedInstance];
    
    NSError *error;
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (self.audioSession) {
        [self.audioSession setActive:YES error:nil];
    }
}
-(void)configRecord{
    NSDictionary *settings = @{AVFormatIDKey               : @(kAudioFormatLinearPCM),
                               AVSampleRateKey             : @8000.00f,
                               AVNumberOfChannelsKey       : @1,
                               AVLinearPCMBitDepthKey      : @16,
                               AVLinearPCMIsNonInterleaved : @NO,
                               AVLinearPCMIsFloatKey       : @NO,
                               AVLinearPCMIsBigEndianKey   : @NO};
    
    NSURL *tmpUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp"]];
    
    NSError *error;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:tmpUrl
                                            settings:settings
                                               error:&error];
    if (error) NSLog(@"%@",error);
    
    self.audioRecorder.meteringEnabled = YES;
    self.audioRecorder.delegate = self;
    [self.audioRecorder prepareToRecord];
}
-(NSURL *)recordFilePath{
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp"]];
}
@end
