//
//  TLTextMessageCell.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLTextMessageCell.h"

@interface TLTextMessageCell ()
@property(nonatomic,strong)UILabel *messageLabel;
@property(nonatomic,strong)UILongPressGestureRecognizer *longPress;
@end

@implementation TLTextMessageCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.bubbleImageView addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsMake(10, 15, 10, 15));
        }];
        
        self.bubbleImageView.userInteractionEnabled = YES;
        self.messageLabel.userInteractionEnabled = YES;
        [self.messageLabel addGestureRecognizer:self.longPress];
    }
    return self;
}
-(void)updateDirection:(RCMessageDirection)direction{
    [super updateDirection:direction];
    [self.messageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        if (direction == MessageDirection_RECEIVE) {
            make.edges.mas_offset(UIEdgeInsetsMake(10, 15, 10, 10));
        }else{
            make.edges.mas_offset(UIEdgeInsetsMake(10, 10, 10, 15));
        }
    }];
}
-(void)updateMessage:(RCMessage *)message showDate:(BOOL)showDate{
    [super updateMessage:message showDate:showDate];
    
    RCTextMessage* textMessage = (RCTextMessage*)message.content;
    self.messageLabel.text = textMessage.content;
}
-(void)longPressAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.bubbleImageView layoutIfNeeded];
        
        [self becomeFirstResponder];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyAction)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:@[copyItem]];
        
        [menu setTargetRect:self.bubbleImageView.frame inView:self.contentView];
        menu.arrowDirection = UIMenuControllerArrowDown;
        [menu setMenuVisible:YES animated:YES];
    }
}
-(void)copyAction {
    [UIPasteboard generalPasteboard].string = self.messageLabel.text;
}
-(BOOL)canBecomeFirstResponder {
    return YES;
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(copyAction)) {
        return YES;
    }
    return NO;
}
-(UILabel *)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:15];
        _messageLabel.textColor = UIColorFromRGB(0x333333);
        _messageLabel.numberOfLines = 0;
    }
    return _messageLabel;
}
-(UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    }
    return _longPress;
}
@end
