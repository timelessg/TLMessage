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
@property(nonatomic,strong)UIButton *emojiKeyboardBtn;
@property(nonatomic,strong)UIButton *moreBtn;
@property(nonatomic,copy)void (^sendTextMsgAction)(RCTextMessage *x);
@property(nonatomic,copy)void (^sendVoiceMsgAction)(RCVoiceMessage *x);
@property(nonatomic,copy)void (^didClickVoiceKeybaord)(BOOL selected);
@property(nonatomic,copy)void (^didClickPlugin)(BOOL selected);
@property(nonatomic,copy)void (^didClickEmoji)(BOOL selected);
@property(nonatomic,assign)BOOL inputTextViewIsFirstResponder;
-(void)resignInputTextViewFirstResponder;
-(void)becomeInputTextViewFirstResponder;
-(void)appendEmoji:(NSString *)emoji;
-(void)backspace;
-(void)sendMessage;
@end
