//
//  TLChatInputView.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLChatViewController.h"
#import "TLProjectMacro.h"

@interface TLChatInputView : UIView
-(instancetype)initWithChatVc:(TLChatViewController *)vc;
@property(nonatomic,copy)void (^sendMsgAction)(RCMessageContent *x);
//@property(nonatomic,copy)void (^sendVoiceMsgAction)(RCVoiceMessage *x);
//@property(nonatomic,copy)void (^sendLocationMsgAction)(RCLocationMessage *x);
//@property(nonatomic,copy)void (^sendImageMsgAction)(RCImageMessage *x);
//@property(nonatomic,copy)void (^didClickVoiceKeybaord)(BOOL selected);
//@property(nonatomic,copy)void (^didClickPlugin)(BOOL selected);
//@property(nonatomic,copy)void (^didClickEmoji)(BOOL selected);
//@property(nonatomic,assign)BOOL inputTextViewIsFirstResponder;
//-(void)resignInputTextViewFirstResponder;
//-(void)becomeInputTextViewFirstResponder;
//-(void)appendEmoji:(NSString *)emoji;
//-(void)backspace;
//-(void)sendMessage;
@end
