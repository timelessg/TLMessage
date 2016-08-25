//
//  TLChatEmojiBoard.h
//  TLMessageView
//
//  Created by 郭锐 on 2016/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSInteger emojiBoardHeight = 223;

@protocol TLChatEmojiBoardDelegate <NSObject>
-(void)chatEmojiBoarDidSelectEmoji:(NSString *)emoji;
-(void)chatEmojiBoarDidClickBackspace;
-(void)chatEmojiBoarDidClickSend;
@end

@interface TLChatEmojiBoard : UIView
@property(nonatomic,assign)BOOL show;
@property(nonatomic,assign)id <TLChatEmojiBoardDelegate> delegate;
@end
