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
@end
