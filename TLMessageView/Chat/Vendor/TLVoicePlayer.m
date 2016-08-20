//
//  TLVoicePlayer.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/19.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLVoicePlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface TLVoicePlayer () <AVAudioPlayerDelegate>
@property (nonatomic,strong)AVAudioPlayer *player;
@property (nonatomic,copy)void (^didFinishBlock)(void);
@end

@implementation TLVoicePlayer
+(TLVoicePlayer *)sharePlayer{
    static dispatch_once_t onceToken;
    static TLVoicePlayer *player;
    dispatch_once(&onceToken, ^{
        player = [[TLVoicePlayer alloc] init];
    });
    return player;
}
-(instancetype)init{
    if (self = [super init]) {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    }
    return self;
}
-(void)playVoiceWithData:(NSData *)data didFinish:(void (^)(void))didFinish{
    if (self.player) {
        [self.player stop];
        self.player.delegate = nil;
        self.player = nil;
    }
    self.didFinishBlock = didFinish;
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    self.player.volume = 1.0f;
    if (error) NSLog(@"%@", error);
    self.player.delegate = self;
    [self.player play];
}
-(void)endPlay{
    if (self.player && self.player.isPlaying) {
        [self.player stop];
    }
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (self.didFinishBlock) self.didFinishBlock();
}
@end
