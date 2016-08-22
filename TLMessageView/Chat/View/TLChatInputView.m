//
//  TLChatInputView.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLChatInputView.h"
#import "TLProjectMacro.h"
#import <Masonry.h>
#import "LPlaceholderTextView.h"
#import "TLRecordVoice.h"
#import "TLRecordVoiceHUD.h"

@interface TLChatInputView () <UITextViewDelegate,TLRecorderVoiceDelegate>
@property(nonatomic,strong)LPlaceholderTextView *inputTextView;
@property(nonatomic,strong)UIButton *voiceKeybaordBtn;
@property(nonatomic,strong)UIButton *emojiKeyboardBtn;
@property(nonatomic,strong)UIButton *moreBtn;
@property(nonatomic,strong)UIButton *tapVoiceBtn;
@property(nonatomic,strong)TLRecordVoice *recorder;

@end

@implementation TLChatInputView
-(instancetype)init{
    if (self = [super init]) {
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
        
        [self addSubview:self.moreBtn];
        [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.emojiKeyboardBtn.mas_right).offset(10);
            make.right.equalTo(self.mas_right).offset(-10);
            make.top.equalTo(self.mas_top).offset(0);
            make.size.mas_offset(CGSizeMake(30, 44));
        }];
    }
    return self;
}
-(void)recorderVoiceSuccessWithVoiceData:(NSData *)voiceData duration:(long)duration{
    if (self.sendVoiceMsgAction) self.sendVoiceMsgAction([RCVoiceMessage messageWithAudio:voiceData duration:duration]);
}
-(void)recorderVoiceFailure{
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage];
        return NO;
    }
    
    if ([textView.text length] > 300) {
        self.inputTextView.text = [textView.text substringWithRange:NSMakeRange(0, 300)];
    }else{
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.inputTextView.contentSize.height + 12);
        }];
    }
    
    return YES;
}
-(void)appendEmoji:(NSString *)emoji{
    NSMutableString *text = [self.inputTextView.text mutableCopy];
    [text appendString:emoji];
    self.inputTextView.text = [text copy];
    
    if (text.length > 300) {
        self.inputTextView.text = [text substringWithRange:NSMakeRange(0, 300)];
    }else{
        self.inputTextView.text = [text copy];
    }
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.inputTextView.contentSize.height + 12);
    }];
}
-(void)backspace{
    NSMutableString *text = [self.inputTextView.text mutableCopy];
    if (text.length) {
        [text deleteCharactersInRange:NSMakeRange(text.length - 2, 2)];
    }
    self.inputTextView.text = [text copy];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.inputTextView.contentSize.height + 12);
    }];
}
- (void)sendMessage{
    NSString *text = self.inputTextView.text;
    if ([text isEqualToString:@""] || !text) {
        return;
    }
    if (self.sendTextMsgAction) self.sendTextMsgAction([RCTextMessage messageWithContent:text]);
    
    self.inputTextView.text = @"";
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.inputTextView.contentSize.height + 12);
    }];
}
-(void)switchVoice:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.tapVoiceBtn.hidden = !sender.selected;
    sender.selected ? [self.inputTextView resignFirstResponder] : [self.inputTextView becomeFirstResponder];
    if (self.didClickVoiceKeybaord) self.didClickVoiceKeybaord(sender.selected);
}
-(void)didClickMoreAcion:(UIButton *)sender{
    if (self.didClickPlugin) self.didClickPlugin();
}
-(void)didClickEmojiAction:(UIButton *)sender{
    if (self.didClickEmoji) self.didClickEmoji();
}
-(void)resignInputTextViewFirstResponder{
    [self.inputTextView resignFirstResponder];
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
-(UIButton *)moreBtn{
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setImage:[UIImage imageNamed:@"icon_+"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(didClickMoreAcion:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
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
        _inputTextView.maxTextViewHeight = 60;
        _inputTextView.layer.cornerRadius = 4.0f;
        _inputTextView.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
        _inputTextView.layer.borderWidth = 0.5;
        [_inputTextView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _inputTextView;
}
@end
