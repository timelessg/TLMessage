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
@end

@implementation TLTextMessageCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.bubbleImageView addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsMake(10, 15, 10, 15));
        }];
    }
    return self;
}
-(void)updateMessage:(RCMessage *)message showDate:(BOOL)showDate{
    [super updateMessage:message showDate:showDate];
    
    RCTextMessage* textMessage = (RCTextMessage*)message.content;
    self.messageLabel.text = textMessage.content;
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
@end
