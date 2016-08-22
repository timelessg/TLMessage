//
//  TLRCManager.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/20.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLRCManager.h"

static NSString *RongCloundKey = @"y745wfm844a4v";

@interface TLRCManager () <RCIMClientReceiveMessageDelegate, RCConnectionStatusChangeDelegate>

@end

@implementation TLRCManager
+(TLRCManager *)shareManager{
    static dispatch_once_t onceToken;
    static TLRCManager *player;
    dispatch_once(&onceToken, ^{
        player = [[TLRCManager alloc] init];
    });
    return player;
}
- (instancetype) init{
    if (self = [super init]) {
        [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
        [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
    }
    return self;
}

- (void) initEnv{
    [[RCIMClient sharedRCIMClient] initWithAppKey:RongCloundKey];
}

- (void) disconnect{
    [[RCIMClient sharedRCIMClient] logout];
}

- (void) connectWithToken:(NSString*)token{
    if (!token) return;
    [[RCIMClient sharedRCIMClient] connectWithToken:token success:^(NSString *userId) {
        NSLog(@"****************************************");
        NSLog(@"Rong connectWithToken success");
        NSLog(@"Rong uid is:%@", userId);
        NSLog(@"****************************************");
    } error:^(RCConnectErrorCode status) {
        NSLog(@"💥Rong connectWithToken error:%ld", status);
    } tokenIncorrect:^{
        NSLog(@"💥Rong connectWithToken incorrect");
    }];
}
- (void) sendMessage:(RCMessage *)message
        successBlock:(void(^)(RCMessage *))successBlock
         failedBlock:(void(^)(RCMessage *))failedBlock
{
    [[RCIMClient sharedRCIMClient] sendMessage:message.conversationType targetId:message.targetId content:message.content pushContent:nil pushData:nil success:^(long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (successBlock) {
                successBlock(message);
            }
        });
    } error:^(RCErrorCode nErrorCode, long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failedBlock) {
                failedBlock(message);
            }
        });
    }];
}
- (void)onReceived:(RCMessage *)message
              left:(int)nLeft
            object:(id)object{
    if (message.conversationType == ConversationType_PRIVATE) {
        if ([self.delegate respondsToSelector:@selector(rcManagerReceiveMsg:)]) {
            [self.delegate rcManagerReceiveMsg:message];
        }
    }
}

- (void)onConnectionStatusChanged:(RCConnectionStatus)status
{
    NSLog(@"Rong cloud status:%ld", status);
}
@end
