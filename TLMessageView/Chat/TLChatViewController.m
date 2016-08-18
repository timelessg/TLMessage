//
//  TLChatViewController.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLChatViewController.h"
#import <Masonry.h>
#import "TLProjectMacro.h"
#import "TLTextMessageCell.h"
#import "TLPhotoMessageCell.h"
#import "TLVoiceMessageCell.h"
#import "TLChatInputView.h"
#import <UITableView+FDTemplateLayoutCell.h>

@interface TLChatViewController () <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *chatTableView;
@property(nonatomic,strong)TLChatInputView *inputView;
@property(nonatomic,strong)NSMutableArray *messages;
@property(nonatomic,strong)UITapGestureRecognizer *touchTap;
@end

@implementation TLChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.inputView];
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.height.mas_offset(@49);
    }];
    
    [self.view addSubview:self.chatTableView];
    [self.chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(0);
        make.bottom.equalTo(self.inputView.mas_top).offset(0);
    }];
    
    weakifySelf;
    self.inputView.sendMessageAction = ^(NSString *x){
        strongifySelf;
        [self sendMessage:x];
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma - mark tableviewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TLTextMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textcell"];
    
    RCMessage *msg = self.messages[indexPath.row];
    RCMessage *lastMsg = [self lasetMsgWithIndex:indexPath.row];
    [cell updateMessage:msg showDate:(msg.sentTime - lastMsg.sentTime > 60 * 5 * 1000)];

    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    weakifySelf;
    CGFloat height = [tableView fd_heightForCellWithIdentifier:@"textcell" cacheByIndexPath:indexPath configuration:^(TLTextMessageCell *cell) {
        strongifySelf;
        RCMessage *msg = self.messages[indexPath.row];
        RCMessage *lastMsg = [self lasetMsgWithIndex:indexPath.row];
        [cell updateMessage:msg showDate:(msg.sentTime - lastMsg.sentTime > 60 * 5 * 1000)];
    }];
    return height;
}

#pragma - mark private
-(void)sendMessage:(NSString *)message{
    RCTextMessage *textMessage = [RCTextMessage messageWithContent:message];
    RCMessage *msg = [[RCMessage alloc] initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:0 content:textMessage];
    msg.sentStatus = SentStatus_SENDING;
    msg.receivedStatus = ReceivedStatus_READ;
    [self insertMessage:msg];
}
- (void)insertMessage:(RCMessage *)message{
    [self.messages addObject:message];
    [self.chatTableView insertRowsAtIndexPaths:@[[self lastMessageIndexPath]] withRowAnimation:UITableViewRowAnimationBottom];
    [self.chatTableView scrollToRowAtIndexPath:[self lastMessageIndexPath] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
-(NSIndexPath *)lastMessageIndexPath{
    return [NSIndexPath indexPathForItem:self.messages.count - 1 inSection:0];
}
- (RCMessage *)lasetMsgWithIndex:(NSInteger)index{
    return index > 0 ? self.messages[index - 1] : nil;
}

#pragma mark - keybaordObserver
- (void)keyboardWillShow:(NSNotification *)sender{
    NSDictionary *userInfo = [sender userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(- keyboardRect.size.height);
    }];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
    CGFloat offsetY = self.chatTableView.contentSize.height - self.chatTableView.bounds.size.height + keyboardRect.size.height;
    if (offsetY > 0) {
        [self.chatTableView setContentOffset:CGPointMake(0, offsetY) animated:YES];
    }
    
    if (self.messages.count) {
        [self.chatTableView scrollToRowAtIndexPath:[self lastMessageIndexPath] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    [self.chatTableView addGestureRecognizer:self.touchTap];
}
- (void)keyboardWillHide:(NSNotification *)sender{
    NSDictionary *userInfo = [sender userInfo];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
    [UIView animateWithDuration:duration animations:^{
        [self.chatTableView beginUpdates];
        [self.view layoutIfNeeded];
        [self.chatTableView endUpdates];
    }];
    [self.chatTableView removeGestureRecognizer:self.touchTap];
}
- (void)tapHideKeyboard:(UITapGestureRecognizer *)tap{
    [self.inputView resignInputTextViewFirstResponder];
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
        _chatTableView.backgroundColor = UIColorFromRGB(0xf5fbfb);
        _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _chatTableView.backgroundColor = UIColorFromRGB(0xf8f8f8);
        _chatTableView.separatorColor = UIColorFromRGB(0xeeeeee);
        [_chatTableView registerClass:[TLTextMessageCell class] forCellReuseIdentifier:@"textcell"];
        [_chatTableView registerClass:[TLPhotoMessageCell class] forCellReuseIdentifier:@"photocell"];
        [_chatTableView registerClass:[TLVoiceMessageCell class] forCellReuseIdentifier:@"voicecell"];
    }
    return _chatTableView;
}
-(TLChatInputView *)inputView{
    if (!_inputView) {
        _inputView = [[TLChatInputView alloc] init];
    }
    return _inputView;
}
-(UITapGestureRecognizer *)touchTap{
    if (!_touchTap) {
        _touchTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard:)];
        _touchTap.cancelsTouchesInView = NO;
    }
    return _touchTap;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
