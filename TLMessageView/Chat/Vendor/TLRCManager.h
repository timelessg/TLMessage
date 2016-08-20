//
//  TLRCManager.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/20.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

@protocol TLRCManagerDelegate <NSObject>
-(void)rcManagerReceiveMsg:(RCMessage *)msg;
@end

@interface TLRCManager : NSObject
@property(nonatomic,assign)id <TLRCManagerDelegate> delegate;
+(TLRCManager *)shareManager;
- (void)initEnv;
- (void)connectWithToken:(NSString*)token;
- (void)sendMessage:(RCMessage *)message
        successBlock:(void(^)())successBlock
         failedBlock:(void(^)())failedBlock;
@end
