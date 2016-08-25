//
//  TLChatInputView.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLChatInputView.h"
#import "LPlaceholderTextView.h"
#import "TLRecordVoice.h"
#import "TLRecordVoiceHUD.h"
#import "TLPluginBoardView.h"
#import "TLChatEmojiBoard.h"
#import "TLLocationViewController.h"
#import "TLPhotoPickerViewController.h"

typedef NS_ENUM(NSUInteger, BoardAction) {
    BoardActionChangeEmojiBoard = 1,
    BoardActionChangePluginBoard,
    BoardActionShowKeyBoard,
    BoardActionHideAllBoard
};

//最大输入字数
static NSInteger maxInputLength = 300;
//输入框最大高度
static CGFloat   maxInputTextViewHeight = 60.0f;

@interface TLChatInputView ()
<UITextViewDelegate,
TLRecorderVoiceDelegate,
TLPluginBoardViewDelegate,
TLChatEmojiBoardDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
TLLocationViewControllerDelegate,
TLPhotoPickerDelegate>

@property(nonatomic,weak)TLChatViewController *chatVc;
@property(nonatomic,strong)UIButton *voiceKeybaordBtn;
@property(nonatomic,strong)UIButton *emojiKeyboardBtn;
@property(nonatomic,strong)UIButton *pluginBoardBtn;

@property(nonatomic,strong)LPlaceholderTextView *inputTextView;
@property(nonatomic,strong)UIButton *tapVoiceBtn;
@property(nonatomic,strong)TLRecordVoice *recorder;
@property(nonatomic,strong)UIView *line;

@property(nonatomic,strong)TLPluginBoardView *pluginBoard;
@property(nonatomic,strong)TLChatEmojiBoard *emojiBoard;

@property(nonatomic,strong)UITapGestureRecognizer *touchTap;
@property(nonatomic,strong)PHImageRequestOptions *options;
@end

@implementation TLChatInputView
{
    //记录上一次chattableview的contentoffset以便只在其变化时修改
    CGFloat _lastContentOffset;
}
-(void)dealloc{
    [self removeObserver:self forKeyPath:@"emojiBtnSelected"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(instancetype)initWithChatVc:(TLChatViewController *)vc{
    if (self = [super init]) {
        self.chatVc = vc;
        
        self.backgroundColor = UIColorFromRGB(0xf4f4f4);
        
        [self addSubview:self.voiceKeybaordBtn];
        [self.voiceKeybaordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(10);
            make.top.equalTo(self.mas_top).offset(0);
            make.size.mas_offset(CGSizeMake(30, 44));
        }];
        
        [self addSubview:self.inputTextView];
        [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.voiceKeybaordBtn.mas_right).offset(10);
            make.top.equalTo(self.mas_top).offset(6);
            make.bottom.equalTo(self.mas_bottom).offset(-6);
        }];
        
        [self addSubview:self.tapVoiceBtn];
        [self.tapVoiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.voiceKeybaordBtn.mas_right).offset(10);
            make.top.equalTo(self.mas_top).offset(6);
            make.bottom.equalTo(self.mas_bottom).offset(-6);
            make.width.equalTo(self.inputTextView.mas_width).offset(0);
        }];
        
        [self addSubview:self.emojiKeyboardBtn];
        [self.emojiKeyboardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.inputTextView.mas_right).offset(10);
            make.top.equalTo(self.mas_top).offset(0);
            make.size.mas_offset(CGSizeMake(30, 44));
        }];
        
        [self addSubview:self.pluginBoardBtn];
        [self.pluginBoardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.emojiKeyboardBtn.mas_right).offset(10);
            make.right.equalTo(self.mas_right).offset(-10);
            make.top.equalTo(self.mas_top).offset(0);
            make.size.mas_offset(CGSizeMake(30, 44));
        }];
        
        [self addSubview:self.line];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(0);
            make.right.equalTo(self.mas_right).offset(0);
            make.bottom.equalTo(self.mas_bottom).offset(0);
            make.height.mas_offset(@0.5);
        }];
        
        [self.chatVc.view addSubview:self.pluginBoard];
        [self.pluginBoard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.chatVc.view.mas_left).offset(0);
            make.right.equalTo(self.chatVc.view.mas_right).offset(0);
            make.bottom.equalTo(self.chatVc.view.mas_bottom).offset(pluginBoardHeight);
            make.height.mas_offset(pluginBoardHeight);
        }];
        
        [self.chatVc.view addSubview:self.emojiBoard];
        [self.emojiBoard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.chatVc.view.mas_left).offset(0);
            make.right.equalTo(self.chatVc.view.mas_right).offset(0);
            make.bottom.equalTo(self.chatVc.view.mas_bottom).offset(emojiBoardHeight);
            make.height.mas_offset(emojiBoardHeight);
        }];
        
        [self.voiceKeybaordBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
    }
    return self;
}
#pragma mark - Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([object isEqual:self.voiceKeybaordBtn]) {
        self.tapVoiceBtn.hidden = !self.voiceKeybaordBtn.selected;
    }
}
- (void)keyboardWillShow:(NSNotification *)sender{
    NSDictionary *userInfo = [sender userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat offsetY = self.chatVc.chatTableView.contentSize.height - self.chatVc.chatTableView.bounds.size.height + keyboardRect.size.height;
    [self changeBoard:BoardActionShowKeyBoard height:keyboardRect.size.height offsetY:offsetY];
}

#pragma mark - TLPluginBoardViewDelegate
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
            TLPhotoPickerViewController *vc = [[TLPhotoPickerViewController alloc] initWithDelegate:self];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.chatVc presentViewController :nav animated:YES completion:nil];
        }
            break;
        case 1:
        {
//            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }
            break;
        case 2:
        {
            TLLocationViewController *vc = [[TLLocationViewController alloc] initWithDelegate:self];
            [self.chatVc.navigationController pushViewController:vc animated:YES];
        }
        default:
            break;
    }
}

#pragma - mark LocationViewControllerDelegate
-(void)locationViewControllerSendMsg:(RCLocationMessage *)msg{
    if (self.sendMsgAction) self.sendMsgAction(msg);
}

#pragma - mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.chatVc dismissViewControllerAnimated:YES completion:^{
        RCImageMessage *msg = [RCImageMessage messageWithImage:image];
        if (self.sendMsgAction) self.sendMsgAction(msg);
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.chatVc dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - recorderVoiceDelegate
-(void)recorderVoiceSuccessWithVoiceData:(NSData *)voiceData duration:(long)duration{
    if (self.sendMsgAction) self.sendMsgAction([RCVoiceMessage messageWithAudio:voiceData duration:duration]);
}
-(void)recorderVoiceFailure{
    
}

#pragma mark - textViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage];
        return NO;
    }
    
    if ([textView.text length] > maxInputLength) {
        self.inputTextView.text = [textView.text substringWithRange:NSMakeRange(0, maxInputLength)];
    }else{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.inputTextView.contentSize.height + 12);
        }];
    }
    
    return YES;
}
#pragma mark - 
-(void)didSendPhotos:(NSArray *)photos{
    for (PHAsset *item in photos) {
        [[PHImageManager defaultManager] requestImageForAsset:item targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            RCImageMessage *msg = [RCImageMessage messageWithImage:result];
            if (self.sendMsgAction) self.sendMsgAction(msg);
        }];
    }
}

#pragma mark - buttonActions
-(void)switchVoice:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.tapVoiceBtn.hidden = !sender.selected;
    sender.selected ? [self.inputTextView resignFirstResponder] : [self.inputTextView becomeFirstResponder];
    if (sender.selected) {
        [self hidePluginAndEmojiBoard];
    }
}
-(void)didClickMoreAcion:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.emojiKeyboardBtn.selected = NO;
    [self changeBoard:BoardActionChangeEmojiBoard height:pluginBoardHeight offsetY:pluginBoardHeight];
    
}
-(void)didClickEmojiAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self changeBoard:BoardActionChangePluginBoard height:emojiBoardHeight offsetY:emojiBoardHeight];
        self.voiceKeybaordBtn.selected = NO;
    }else{
        [self.inputView becomeInputTextViewFirstResponder];
    }
}

#pragma - mark tapVoiceBtnAction

-(void)beginRecordVoice:(UIButton *)sender{
    [self.recorder startRecord];
    sender.backgroundColor = UIColorFromRGB(0x333333);
}
-(void)endRecordVoice:(UIButton *)sender{
    [self.recorder completeRecord];
    sender.backgroundColor = UIColorFromRGB(0xdddddd);
}
-(void)cancelRecordVoice:(UIButton *)sender{
    [self.recorder cancelRecord];
    sender.backgroundColor = UIColorFromRGB(0xdddddd);
}
-(void)remindDragExit:(UIButton *)sender{
    [TLRecordVoiceHUD showWCancel];
    sender.backgroundColor = UIColorFromRGB(0xdddddd);
}
-(void)remindDragEnter:(UIButton *)sender{
    [TLRecordVoiceHUD showRecording];
    sender.backgroundColor = UIColorFromRGB(0x333333);
}

#pragma mark - private
//处理几种键盘隐藏显示逻辑。。略复杂待优化
-(void)changeBoard:(BoardAction)board height:(CGFloat)height offsetY:(CGFloat)offsetY{
    BOOL showKeyBoard = NO;
    switch (board) {
        case BoardActionChangeEmojiBoard: {
            self.pluginBoard.show = !self.pluginBoard.show;
            self.emojiBoard.show = NO;
            showKeyBoard = NO;
            [self.inputView resignInputTextViewFirstResponder];
            break;
        }
        case BoardActionChangePluginBoard: {
            self.emojiBoard.show = !self.emojiBoard.show;
            self.pluginBoard.show = NO;
            showKeyBoard = NO;
            [self.inputView resignInputTextViewFirstResponder];
            break;
        }
        case BoardActionShowKeyBoard: {
            self.emojiBoard.show = NO;
            self.pluginBoard.show = NO;
            showKeyBoard = YES;
            self.emojiKeyboardBtn.selected = NO;
            self.voiceKeybaordBtn.selected = NO;
            break;
        }
        case BoardActionHideAllBoard: {
            self.emojiBoard.show = NO;
            self.pluginBoard.show = NO;
            showKeyBoard = NO;
            break;
        }
    }
    
    BOOL pluginShow = self.pluginBoard.show;
    BOOL emojiSshow = self.emojiBoard.show;
    
    BOOL showBoard = pluginShow || emojiSshow || showKeyBoard;
    
    [self.pluginBoard mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatVc.view.mas_bottom).offset(pluginShow ? 0 : height);
    }];
    
    [self.emojiBoard mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatVc.view.mas_bottom).offset(emojiSshow ? 0 : height);
    }];
    
    [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatVc.view.mas_bottom).offset(showBoard ? - height : 0);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.chatVc.chatTableView beginUpdates];
        [self.chatVc.view layoutIfNeeded];
        [self.chatVc.chatTableView endUpdates];
    }];
    
    if (_lastContentOffset != offsetY && offsetY > 0) {
        [self.chatVc.chatTableView beginUpdates];
        [self.chatVc.chatTableView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        [self.chatVc.chatTableView endUpdates];
    }
    
    [self.chatVc scrollToBottom];
    
    _lastContentOffset = offsetY;
    
    [self.chatVc.chatTableView addGestureRecognizer:self.touchTap];
}
-(void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self.chatVc presentViewController:picker animated:YES completion:nil];
    }
}
-(void)appendEmoji:(NSString *)emoji{
    NSMutableString *text = [self.inputTextView.text mutableCopy];
    [text appendString:emoji];
    self.inputTextView.text = [text copy];
    
    self.inputTextView.text = text.length > maxInputLength ? [text substringWithRange:NSMakeRange(0, maxInputLength)] : [text copy];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.inputTextView.contentSize.height + 12);
    }];
}
-(void)backspace{
    [self.inputTextView deleteBackward];
}
- (void)sendMessage{
    NSString *text = self.inputTextView.text;
    if ([text isEqualToString:@""] || !text) {
        return;
    }
    if (self.sendMsgAction) self.sendMsgAction([RCTextMessage messageWithContent:text]);
    
    self.inputTextView.text = @"";
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.inputTextView.contentSize.height + 12);
    }];
}

-(void)resignInputTextViewFirstResponder{
    if (self.inputTextView.isFirstResponder){
        [self.inputTextView resignFirstResponder];
    }
}
-(void)becomeInputTextViewFirstResponder{
    if (!self.inputTextView.isFirstResponder){
        [self.inputTextView becomeFirstResponder];
    }
}
-(BOOL)inputTextViewIsFirstResponder{
    return self.inputTextView.isFirstResponder;
}
- (void)tapHideKeyboard:(UITapGestureRecognizer *)tap{
    [self.inputView resignInputTextViewFirstResponder];
    [self hidePluginAndEmojiBoard];
    [self.chatVc.chatTableView removeGestureRecognizer:self.touchTap];
}
- (void)hidePluginAndEmojiBoard{
    self.emojiKeyboardBtn.selected = NO;
    [self changeBoard:BoardActionHideAllBoard height:emojiBoardHeight offsetY:0];
}


-(PHImageRequestOptions *)options{
    if (!_options) {
        _options = [[PHImageRequestOptions alloc] init];
    }
    return _options;
}
#pragma mark - gatter
-(UITapGestureRecognizer *)touchTap{
    if (!_touchTap) {
        _touchTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard:)];
        _touchTap.cancelsTouchesInView = NO;
    }
    return _touchTap;
}
-(TLRecordVoice *)recorder{
    if (!_recorder) {
        _recorder = [[TLRecordVoice alloc] initWithDelegate:self];
    }
    return _recorder;
}
-(UIButton *)voiceKeybaordBtn{
    if (!_voiceKeybaordBtn) {
        _voiceKeybaordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceKeybaordBtn setImage:[UIImage imageNamed:@"icon_duijiang"] forState:UIControlStateNormal];
        [_voiceKeybaordBtn setImage:[UIImage imageNamed:@"icon_kyb"] forState:UIControlStateSelected];
        [_voiceKeybaordBtn addTarget:self action:@selector(switchVoice:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceKeybaordBtn;
}
-(UIButton *)emojiKeyboardBtn{
    if (!_emojiKeyboardBtn) {
        _emojiKeyboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emojiKeyboardBtn setImage:[UIImage imageNamed:@"icon_xiaolian"] forState:UIControlStateNormal];
        [_emojiKeyboardBtn setImage:[UIImage imageNamed:@"icon_kyb"] forState:UIControlStateSelected];
        [_emojiKeyboardBtn addTarget:self action:@selector(didClickEmojiAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiKeyboardBtn;
}
-(UIButton *)pluginBoardBtn{
    if (!_pluginBoardBtn) {
        _pluginBoardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pluginBoardBtn setImage:[UIImage imageNamed:@"icon_+"] forState:UIControlStateNormal];
        [_pluginBoardBtn addTarget:self action:@selector(didClickMoreAcion:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pluginBoardBtn;
}
-(UIButton *)tapVoiceBtn{
    if (!_tapVoiceBtn) {
        _tapVoiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tapVoiceBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_tapVoiceBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        _tapVoiceBtn.backgroundColor = UIColorFromRGB(0xdddddd);
        _tapVoiceBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _tapVoiceBtn.hidden = YES;
        _tapVoiceBtn.layer.cornerRadius = 4.0;
        _tapVoiceBtn.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
        _tapVoiceBtn.layer.borderWidth = 0.5;
        [_tapVoiceBtn addTarget:self action:@selector(beginRecordVoice:) forControlEvents:UIControlEventTouchDown];
        [_tapVoiceBtn addTarget:self action:@selector(endRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
        [_tapVoiceBtn addTarget:self action:@selector(cancelRecordVoice:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [_tapVoiceBtn addTarget:self action:@selector(remindDragExit:) forControlEvents:UIControlEventTouchDragExit];
        [_tapVoiceBtn addTarget:self action:@selector(remindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    }
    return _tapVoiceBtn;
}
-(LPlaceholderTextView *)inputTextView{
    if (!_inputTextView) {
        _inputTextView = [[LPlaceholderTextView alloc] init];
        _inputTextView.font = [UIFont systemFontOfSize:13];
        _inputTextView.tintColor = UIColorFromRGB(0x999999);
        _inputTextView.placeholderText = @"聊点什么吧";
        _inputTextView.placeholderColor = UIColorFromRGB(0x999999);
        _inputTextView.layer.cornerRadius = 4.0;
        _inputTextView.delegate = self;
        _inputTextView.returnKeyType = UIReturnKeySend;
        _inputTextView.maxTextViewHeight = maxInputTextViewHeight;
        _inputTextView.layer.cornerRadius = 4.0f;
        _inputTextView.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
        _inputTextView.layer.borderWidth = 0.5;
        [_inputTextView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _inputTextView;
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
-(UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = UIColorFromRGB(0xcccccc);
    }
    return _line;
}
@end
