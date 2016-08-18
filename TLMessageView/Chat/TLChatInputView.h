//
//  TLChatInputView.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLChatInputView : UIView
@property(nonatomic,copy)void (^sendMessageAction)(NSString *x);
-(void)resignInputTextViewFirstResponder;
@end
