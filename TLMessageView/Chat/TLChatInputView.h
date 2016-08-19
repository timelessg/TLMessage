//
//  TLChatInputView.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>

@interface TLChatInputView : UIView
@property(nonatomic,copy)void (^sendTextMsgAction)(RCTextMessage *x);
@property(nonatomic,copy)void (^sendVoiceMsgAction)(RCVoiceMessage *x);
-(void)resignInputTextViewFirstResponder;
@end
