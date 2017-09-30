//
//  TLChatViewController.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLChatViewController.h"
#import "TLProjectMacro.h"
#import "TLTextMessageCell.h"
#import "TLPhotoMessageCell.h"
#import "TLVoiceMessageCell.h"
#import "TLLocationMessageCell.h"
#import "TLChatInputView.h"
#import "TLRCManager.h"
#import "APIDebug.h"

@interface TLChatViewController ()

<UITableViewDelegate,
UITableViewDataSource,
TLRCManagerDelegate>

@property(nonatomic,strong)TLChatInputView *chatInputView;
@property(nonatomic,strong)NSMutableArray *messages;
@end

@implementation TLChatViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[TLRCManager shareManager] connectWithToken:@"jqAhQVLtdDAJsN+nYuGMg+SZkEN9cVfzRVKTg8tY0IOhDwJ1Cn3qxdbPXWTk4XVCfZLmci9yJ2QWgjEOhUtgXg=="];
    [TLRCManager shareManager].delegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    [self.view addSubview:self.chatInputView];
    [self.chatInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.height.mas_offset(@45);
    }];
    
    [self.view addSubview:self.chatTableView];
    [self.chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(0);
        make.bottom.equalTo(self.chatInputView.mas_top).offset(0);
    }];
    
    weakifySelf;
    //发送消息回调
    self.chatInputView.sendMsgAction =  ^(RCMessageContent *x){
        strongifySelf;
        [self sendMessage:x];
    };
    
    //navbar上的一个APIDebug调试，可注释掉
    [APIDebug configWithVC:self];
}

#pragma - mark tableviewDelegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RCMessage *msg = self.messages[indexPath.row];
    RCMessage *lastMsg = [self lasetMsgWithIndex:indexPath.row];
    
    TLMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierWithMsg:msg]];
    
    weakifySelf;
    cell.reSendAction = ^(RCMessage *msg){
        strongifySelf;
        msg.sentStatus = SentStatus_SENDING;
        [self retrySendMessage:msg];
    };
    
    cell.clickAvatar = ^(RCMessageDirection msgDirection){
        
    };
    
    [cell updateMessage:msg showDate:(msg.sentTime - lastMsg.sentTime > 60 * 5 * 1000)];
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCMessage *msg = self.messages[indexPath.row];
    RCMessage *lastMsg = [self lasetMsgWithIndex:indexPath.row];
    CGFloat height = [tableView fd_heightForCellWithIdentifier:[self cellIdentifierWithMsg:msg] cacheByIndexPath:indexPath configuration:^(TLMessageCell *cell) {
        [cell updateMessage:msg showDate:(msg.sentTime - lastMsg.sentTime > 60 * 5 * 1000)];
    }];
    return height;
}

#pragma - mark RCManagerDelegate

-(void)rcManagerReceiveMsg:(RCMessage *)msg{
    msg.sentStatus = SentStatus_RECEIVED;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self insertMessage:msg];
    });
}

#pragma - mark private
-(void)sendMessage:(id)message{
    RCMessage *msg = [[RCMessage alloc] initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:0 content:message];
    
    msg.sentStatus = SentStatus_SENDING;
    msg.receivedStatus = ReceivedStatus_READ;
    [self insertMessage:msg];
    [self retrySendMessage:msg];
}
- (void)insertMessage:(RCMessage *)message{
    if (!message.content) {
        return;
    }
    [self.messages addObject:message];
    
    [self.chatTableView insertRowsAtIndexPaths:@[[self lastMessageIndexPath]] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.chatTableView scrollToRowAtIndexPath:[self lastMessageIndexPath] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (void)retrySendMessage:(RCMessage *)message{
    [[TLRCManager shareManager] sendMessage:message successBlock:^(RCMessage *x){
        x.sentStatus = SentStatus_SENT;
        [self updateCellStatusWithMsg:x];
    } failedBlock:^(RCMessage *x){
        x.sentStatus = SentStatus_FAILED;
        [self updateCellStatusWithMsg:x];
    }];
}
-(void)updateCellStatusWithMsg:(RCMessage *)msg{
    NSInteger index = [self.messages indexOfObject:msg];
    TLMessageCell *cell = [self.chatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell setMsgStatus:msg.sentStatus];
}
-(void)scrollToBottom{
    if (self.messages.count) {
        [self.chatTableView scrollToRowAtIndexPath:[self lastMessageIndexPath] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
-(NSIndexPath *)lastMessageIndexPath{
    return [NSIndexPath indexPathForItem:self.messages.count - 1 inSection:0];
}
-(RCMessage *)lasetMsgWithIndex:(NSInteger)index{
    return index > 0 ? self.messages[index - 1] : nil;
}
-(NSString *)cellIdentifierWithMsg:(RCMessage *)msg{
    NSDictionary *dic = @{@"RCTextMessage":@"textcell",
                          @"RCVoiceMessage":@"voicecell",
                          @"RCImageMessage":@"photocell",
                          @"RCLocationMessage":@"locationcell"};
    return  dic[NSStringFromClass([msg.content class])];
}
#pragma - mark getter
-(NSMutableArray *)messages{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}
-(UITableView *)chatTableView{
    if (!_chatTableView) {
        _chatTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _chatTableView.delegate = self;
        _chatTableView.dataSource = self;
        _chatTableView.backgroundColor = UIColorFromRGB(0xebebeb);
        _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _chatTableView.backgroundColor = UIColorFromRGB(0xf8f8f8);
        _chatTableView.separatorColor = UIColorFromRGB(0xeeeeee);
        [_chatTableView registerClass:[TLTextMessageCell class] forCellReuseIdentifier:@"textcell"];
        [_chatTableView registerClass:[TLPhotoMessageCell class] forCellReuseIdentifier:@"photocell"];
        [_chatTableView registerClass:[TLVoiceMessageCell class] forCellReuseIdentifier:@"voicecell"];
        [_chatTableView registerClass:[TLLocationMessageCell class] forCellReuseIdentifier:@"locationcell"];
    }
    return _chatTableView;
}
-(TLChatInputView *)chatInputView{
    if (!_chatInputView) {
        _chatInputView = [[TLChatInputView alloc] initWithChatVc:self];
    }
    return _chatInputView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
