//
//  TLChatViewController.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLChatViewController.h"
#import <Masonry.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import "TLProjectMacro.h"
#import "TLTextMessageCell.h"
#import "TLPhotoMessageCell.h"
#import "TLVoiceMessageCell.h"
#import "TLLocationMessageCell.h"
#import "TLChatInputView.h"
#import "TLPluginBoardView.h"
#import "TLRCManager.h"
#import "TLChatEmojiBoard.h"
#import "TLLocationViewController.h"

static NSInteger BoardHeight = 223;

@interface TLChatViewController ()
<UITableViewDelegate,
UITableViewDataSource,
TLPluginBoardViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
TLRCManagerDelegate,
TLChatEmojiBoardDelegate,
TLLocationViewControllerDelegate>
@property(nonatomic,strong)UITableView *chatTableView;
@property(nonatomic,strong)TLChatInputView *inputView;
@property(nonatomic,strong)TLPluginBoardView *pluginBoard;
@property(nonatomic,strong)TLChatEmojiBoard *emojiBoard;
@property(nonatomic,strong)NSMutableArray *messages;
@property(nonatomic,strong)UITapGestureRecognizer *touchTap;
@end

@implementation TLChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[TLRCManager shareManager] connectWithToken:@"jqAhQVLtdDAJsN+nYuGMg+SZkEN9cVfzRVKTg8tY0IOhDwJ1Cn3qxdbPXWTk4XVCfZLmci9yJ2QWgjEOhUtgXg=="];
    [TLRCManager shareManager].delegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.inputView];
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.bottom.equalTo(self.inputView.mas_top).offset(0);
    }];
    
    [self.view addSubview:self.pluginBoard];
    [self.pluginBoard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(BoardHeight);
        make.height.mas_offset(BoardHeight);
    }];
    
    [self.view addSubview:self.emojiBoard];
    [self.emojiBoard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(BoardHeight);
        make.height.mas_offset(BoardHeight);
    }];
    
    weakifySelf;
    self.inputView.sendTextMsgAction = ^(RCTextMessage *x){
        strongifySelf;
        [self sendMessage:x];
    };
    
    self.inputView.didClickVoiceKeybaord = ^(BOOL selected){
        strongifySelf;
        if (selected) {
            [self hidePluginAndEmojiBoard];
        }
    };
    
    self.inputView.sendVoiceMsgAction = ^(RCVoiceMessage *x){
        strongifySelf;
        [self sendMessage:x];
    };
    
    self.inputView.didClickPlugin = ^(){
        strongifySelf;
        [self.inputView resignInputTextViewFirstResponder];
        [self showPluginBoard:!self.pluginBoard.show hideInput:YES];
    };
    
    self.inputView.didClickEmoji = ^(BOOL selected){
        strongifySelf;
        if (!self.emojiBoard.show) {
            [self.inputView resignInputTextViewFirstResponder];
            [self showEmojiBoard:!self.emojiBoard.show hideInput:YES];
        }else{
            [self showEmojiBoard:!self.emojiBoard.show hideInput:NO];
            [self.inputView becomeInputTextViewFirstResponder];
        }
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
#pragma - mark pluginBoardViewDelegate

-(NSArray *)pluginBoardItems{
    TLPluginBoardItem *photo = [[TLPluginBoardItem alloc] initWithIcoNamed:@"actionbar_picture_icon" title:@"相册"];
    TLPluginBoardItem *can = [[TLPluginBoardItem alloc] initWithIcoNamed:@"actionbar_camera_icon" title:@"相机"];
    TLPluginBoardItem *local = [[TLPluginBoardItem alloc] initWithIcoNamed:@"actionbar_location_icon" title:@"位置"];
    TLPluginBoardItem *audio = [[TLPluginBoardItem alloc] initWithIcoNamed:@"actionbar_audio_call_icon" title:@"语音"];
    TLPluginBoardItem *file = [[TLPluginBoardItem alloc] initWithIcoNamed:@"actionbar_file_icon" title:@"文件"];
    TLPluginBoardItem *video = [[TLPluginBoardItem alloc] initWithIcoNamed:@"actionbar_video_call_icon" title:@"视频"];
    return @[photo,can,local,audio,file,video];
}
-(void)pluginBoardDidClickItemIndex:(NSInteger)itemIndex{
    switch (itemIndex) {
        case 0:
        {
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
            break;
        case 1:
        {
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }
            break;
        case 2:
        {
            TLLocationViewController *vc = [[TLLocationViewController alloc] initWithDelegate:self];
            [self.navigationController pushViewController:vc animated:YES];
        }
        default:
            break;
    }
}
#pragma - mark LocationViewControllerDelegate
-(void)locationViewControllerSendMsg:(RCLocationMessage *)msg{
    [self sendMessage:msg];
}

#pragma - mark emojiBoardViewDelegate
-(void)chatEmojiBoarDidSelectEmoji:(NSString *)emoji{
    [self.inputView appendEmoji:emoji];
}
-(void)chatEmojiBoarDidClickBackspace{
    [self.inputView backspace];
}
-(void)chatEmojiBoarDidClickSend{
    [self.inputView sendMessage];
}

#pragma - mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:^{
        RCImageMessage *msg = [RCImageMessage messageWithImage:image];
        [self sendMessage:msg];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [self.messages addObject:message];
    [self.chatTableView insertRowsAtIndexPaths:@[[self lastMessageIndexPath]] withRowAnimation:UITableViewRowAnimationBottom];
    
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
-(void)showPluginBoard:(BOOL)show hideInput:(BOOL)hideInput{
    self.pluginBoard.show = show;
    [self.pluginBoard mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(show ? 0 : BoardHeight);
    }];
    
    if (hideInput) {
        [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).offset(show ? - BoardHeight : 0);
        }];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.chatTableView beginUpdates];
        [self.view layoutIfNeeded];
        [self.chatTableView endUpdates];
    }];
    
    if (show) {
        [self chatTableViewScrollToBottomWithoffsetY:BoardHeight];
        if (self.emojiBoard.show) {
            [self showEmojiBoard:NO hideInput:NO];
        }
    }
}
- (void)showEmojiBoard:(BOOL)show hideInput:(BOOL)hideInput{
    self.emojiBoard.show = show;
    self.inputView.emojiKeyboardBtn.selected = show;
    [self.emojiBoard mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(show ? 0 : BoardHeight);
    }];
    
    if (hideInput) {
        [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).offset(show ? - BoardHeight : 0);
        }];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.chatTableView beginUpdates];
        [self.view layoutIfNeeded];
        [self.chatTableView endUpdates];
    }];
    
    if (show) {
        [self chatTableViewScrollToBottomWithoffsetY:BoardHeight];
        if (self.pluginBoard.show) {
            [self showPluginBoard:NO hideInput:NO];
        }
    }
}
- (void)tapHideKeyboard:(UITapGestureRecognizer *)tap{
    [self.inputView resignInputTextViewFirstResponder];
    [self hidePluginAndEmojiBoard];
    
    [self.chatTableView removeGestureRecognizer:self.touchTap];
}
- (void)hidePluginAndEmojiBoard{
    if (self.pluginBoard.show) {
        [self showPluginBoard:NO hideInput:YES];
    }
    
    if (self.emojiBoard.show) {
        [self showEmojiBoard:NO hideInput:YES];
    }
}
- (void)chatTableViewScrollToBottomWithoffsetY:(CGFloat)offsetY{
    if (offsetY > 0) {
        [self.chatTableView beginUpdates];
        [self.chatTableView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        [self.chatTableView endUpdates];
    }
    
    if (self.messages.count) {
        [self.chatTableView scrollToRowAtIndexPath:[self lastMessageIndexPath] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    [self.chatTableView addGestureRecognizer:self.touchTap];
}
-(NSIndexPath *)lastMessageIndexPath{
    return [NSIndexPath indexPathForItem:self.messages.count - 1 inSection:0];
}
-(RCMessage *)lasetMsgWithIndex:(NSInteger)index{
    return index > 0 ? self.messages[index - 1] : nil;
}
-(NSString *)cellIdentifierWithMsg:(RCMessage *)msg{
    NSDictionary *dic = @{@"RCTextMessage":@"textcell",@"RCVoiceMessage":@"voicecell",@"RCImageMessage":@"photocell",@"RCLocationMessage":@"locationcell"};
    return  dic[NSStringFromClass([msg.content class])];
}

-(void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    }
}
#pragma mark - keybaordObserver
- (void)keyboardWillShow:(NSNotification *)sender{
    [self hidePluginAndEmojiBoard];
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
    
    [self chatTableViewScrollToBottomWithoffsetY:offsetY];
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
-(TLChatInputView *)inputView{
    if (!_inputView) {
        _inputView = [[TLChatInputView alloc] init];
    }
    return _inputView;
}
-(TLPluginBoardView *)pluginBoard{
    if (!_pluginBoard) {
        _pluginBoard = [[TLPluginBoardView alloc] initWithDelegate:self];
    }
    return _pluginBoard;
}
-(TLChatEmojiBoard *)emojiBoard{
    if (!_emojiBoard) {
        _emojiBoard = [[TLChatEmojiBoard alloc] init];
        _emojiBoard.delegate = self;
    }
    return _emojiBoard;
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
