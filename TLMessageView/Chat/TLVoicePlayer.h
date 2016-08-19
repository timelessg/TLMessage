//
//  TLVoicePlayer.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/19.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TLVoicePlayer : NSObject
+(TLVoicePlayer *)sharePlayer;
-(void)playVoiceWithData:(NSData *)data didFinish:(void (^)(void))didFinish;
-(void)endPlay;
@end
