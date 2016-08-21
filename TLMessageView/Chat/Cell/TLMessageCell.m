//
//  TLMessageCell.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLMessageCell.h"

@interface TLMessageCell ()
@end

@implementation TLMessageCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.constraints = [NSMutableArray array];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.dateTimeLabel];
        [self.dateTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(0);
            make.left.equalTo(self.contentView.mas_left).offset(0);
            make.right.equalTo(self.contentView.mas_right).offset(0);
            make.height.mas_offset(0);
        }];
        
        [self.contentView addSubview:self.avatarImageView];
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.dateTimeLabel.mas_bottom).offset(8);
            make.size.mas_offset(CGSizeMake(30, 30));
            SMAS(make.left.equalTo(self.contentView.mas_left).offset(10));
        }];
        
        [self.contentView addSubview:self.bubbleImageView];
        [self.bubbleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_top).offset(0);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-8);
            SMAS(make.left.equalTo(self.avatarImageView.mas_right).offset(7));
            SMAS(make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-78));
        }];
        
        [self.contentView addSubview:self.statusView];
        [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bubbleImageView.mas_centerY).offset(0);
            make.size.mas_offset(CGSizeMake(38, 38));
            SMAS(make.left.equalTo(self.bubbleImageView.mas_right).offset(0));
        }];
        
        [self.statusView addSubview:self.activityIndicator];
        [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.statusView.mas_centerY).offset(0);
            make.centerX.equalTo(self.statusView.mas_centerX).offset(0);
            make.size.mas_offset(CGSizeMake(10, 10));
        }];
        
        [self.statusView addSubview:self.retryBtn];
        [self.retryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.statusView.mas_centerY).offset(0);
            make.centerX.equalTo(self.statusView.mas_centerX).offset(0);
        }];
    }
    return self;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    self.msgStatus = self.message.sentStatus;
}
-(void)updateDirection:(RCMessageDirection)direction{
    [self removeAllConstraints];
    
    NSString *bubbleNamed = direction == MessageDirection_RECEIVE ? @"chat_from_bg_normal" : @"chat_to_bg_normal";
    self.bubbleImageView.image = [[UIImage imageNamed:bubbleNamed] stretchableImageWithLeftCapWidth:15 topCapHeight:25];
    
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (direction == MessageDirection_RECEIVE) {
            SMAS(make.left.equalTo(self.contentView.mas_left).offset(10));
        }else{
            SMAS(make.right.equalTo(self.contentView.mas_right).offset(-10));
        }
    }];
    
    [self.bubbleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (direction == MessageDirection_RECEIVE) {
            SMAS(make.left.equalTo(self.avatarImageView.mas_right).offset(7));
            SMAS(make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-78));
        }else{
            SMAS(make.right.equalTo(self.avatarImageView.mas_left).offset(-7));
            SMAS(make.left.greaterThanOrEqualTo(self.contentView.mas_left).offset(78));
        }
    }];
    
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (direction == MessageDirection_RECEIVE) {
            SMAS(make.left.equalTo(self.bubbleImageView.mas_right).offset(0));
        }else{
            SMAS(make.right.equalTo(self.bubbleImageView.mas_left).offset(0));
        }
    }];
}
-(void)updateDate:(NSInteger)date showDate:(BOOL)showDate{
    if (!showDate) {
        [self.dateTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
        self.dateTimeLabel.hidden = YES;
        return;
    }
    
    self.dateTimeLabel.hidden = NO;
    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:date / 1000];
    NSString *dateStr;  //年月日
    
    if ([lastDate year] == [[NSDate date] year]) {
        NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
        dateStr = days <= 2 ? [lastDate stringYearMonthDayCompareToday] : [lastDate stringMonthDay];
    }else{
        dateStr = [lastDate stringYearMonthDay];
    }
    
    [self.dateTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(18);
    }];
    
    self.dateTimeLabel.text = [NSString stringWithFormat:@"%@ %02d:%02d",dateStr,(int)[lastDate hour],(int)[lastDate minute]];
}
-(void)updateMessage:(RCMessage *)message showDate:(BOOL)showDate{
    [self updateDirection:message.messageDirection];
    [self updateDate:message.sentTime showDate:showDate];
    self.message = message;
    self.msgStatus = message.sentStatus;    
}
-(void)setMsgStatus:(RCSentStatus)msgStatus{
    if (msgStatus == SentStatus_SENT) {
        self.retryBtn.hidden = YES;
        self.activityIndicator.hidden = YES;
    }
    self.retryBtn.hidden = msgStatus != SentStatus_FAILED;
    if (msgStatus == SentStatus_SENDING) {
        [self.activityIndicator startAnimating];
        self.activityIndicator.hidden = NO;
    }else{
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
    }
}
-(void)removeAllConstraints{
    for (MASConstraint *constraint in self.constraints) {
        [constraint uninstall];
    }
}
-(UILabel *)dateTimeLabel{
    if (!_dateTimeLabel) {
        _dateTimeLabel = [[UILabel alloc] init];
        _dateTimeLabel.textColor = UIColorFromRGB(0x999999);
        _dateTimeLabel.font = [UIFont systemFontOfSize:9];
        _dateTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dateTimeLabel;
}
-(UIImageView *)avatarImageView{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatfrom_doctor_icon"]];
        _avatarImageView.layer.cornerRadius = 15;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.userInteractionEnabled = YES;
    }
    return _avatarImageView;
}
-(UIView *)statusView{
    if (!_statusView) {
        _statusView = [[UIView alloc] init];
    }
    return _statusView;
}
-(UIButton *)retryBtn{
    if (!_retryBtn) {
        _retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retryBtn setImage:[UIImage imageNamed:@"news_failinsend"] forState:UIControlStateNormal];
    }
    return _retryBtn;
}
-(UIActivityIndicatorView *)activityIndicator{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _activityIndicator.color = UIColorFromRGB(0x999999);
    }
    return _activityIndicator;
}
-(UIImageView *)bubbleImageView{
    if (!_bubbleImageView) {
        _bubbleImageView = [[UIImageView alloc] init];
    }
    return _bubbleImageView;
}
-(UIImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sharp"]];
    }
    return _arrowImageView;
}
@end
