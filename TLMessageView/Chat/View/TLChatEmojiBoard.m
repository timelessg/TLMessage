//
//  TLChatEmojiBoard.m
//  TLMessageView
//
//  Created by 郭锐 on 2016/8/18.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLChatEmojiBoard.h"
#import "TLProjectMacro.h"
#import "TLButton.h"

@interface TLChatEmojiBoard () <UIScrollViewDelegate>
@property(nonatomic,strong)UIScrollView *pageScrollView;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)UIButton *emojiSwitchBtn;
@property(nonatomic,strong)UIButton *sendBtn;
@property(nonatomic,strong)UIPageControl *pageControl;
@property(nonatomic,strong)NSMutableArray *pageViews;
@property(nonatomic,strong)NSArray *emojis;
@end

@implementation TLChatEmojiBoard
{
    BOOL hasLayout;
}
-(instancetype)init{
    if (self = [super init]) {
        [self addSubview:self.pageScrollView];
        [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(0);
            make.right.equalTo(self.mas_right).offset(0);
            make.top.equalTo(self.mas_top).offset(0);
        }];
        
        [self addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(0);
            make.right.equalTo(self.mas_right).offset(0);
            make.top.equalTo(self.pageScrollView.mas_bottom).offset(0);
            make.bottom.equalTo(self.mas_bottom).offset(0);
            make.height.mas_offset(@37);
        }];
        
        [self.bottomView addSubview:self.emojiSwitchBtn];
        [self.emojiSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomView.mas_left).offset(0);
            make.top.equalTo(self.bottomView.mas_top).offset(0);
            make.bottom.equalTo(self.bottomView.mas_bottom).offset(0);
            make.width.equalTo(self.emojiSwitchBtn.mas_height);
        }];
        
        [self.bottomView addSubview:self.sendBtn];
        [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bottomView.mas_right).offset(0);
            make.top.equalTo(self.bottomView.mas_top).offset(0);
            make.bottom.equalTo(self.bottomView.mas_bottom).offset(0);
            make.width.mas_offset(@52);
        }];
        
        self.pageViews = [NSMutableArray array];
        for (int i = 0; i < self.emojis.count; i ++ ) {
            NSArray *emojiArray = self.emojis[i];
            UIView *pageView = [[UIView alloc] init];
            [self.pageScrollView addSubview:pageView];
            [self.pageViews addObject:pageView];
            
            for (int j = 0; j < emojiArray.count; j ++ ) {
                TLButton *emojiBtn = [TLButton buttonWithType:UIButtonTypeCustom];
                [emojiBtn setTitle:emojiArray[j] forState:UIControlStateNormal];
                [pageView addSubview:emojiBtn];
                [emojiBtn addTarget:self action:@selector(didClickEmoji:) forControlEvents:UIControlEventTouchUpInside];
                if (j == emojiArray.count - 1) {
                    [emojiBtn setImage:[UIImage imageNamed:@"emoji_btn_delete"] forState:UIControlStateNormal];
                    emojiBtn.tag = 99;
                }
            }
        }
        
        self.pageControl.numberOfPages = self.emojis.count;
        [self addSubview:self.pageControl];
        [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX).offset(0);
            make.bottom.equalTo(self.pageScrollView.mas_bottom).offset(0);
        }];
    }
    return self;
}
-(void)didClickEmoji:(UIButton *)sender{
    if (sender.tag == 99) {
        if ([self.delegate respondsToSelector:@selector(chatEmojiBoarDidClickBackspace)]) {
            [self.delegate chatEmojiBoarDidClickBackspace];
        }
    }else{
        NSString *emoji = sender.titleLabel.text;
        if ([self.delegate respondsToSelector:@selector(chatEmojiBoarDidSelectEmoji:)]) {
            [self.delegate chatEmojiBoarDidSelectEmoji:emoji];
        }
    }
}
-(void)didClickSend:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(chatEmojiBoarDidClickSend)]) {
        [self.delegate chatEmojiBoarDidClickSend];
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (hasLayout) {
        return;
    }
    hasLayout = YES;
    
    CGSize emojiBtnSize = CGSizeMake(30, 34);
    
    //横向间距
    CGFloat emojiHorizontalSpacing = (self.frame.size.width - 50 - emojiBtnSize.width * 8) / 7.0;
    //纵向间距
    CGFloat emojiVerticalSpacing = (self.pageScrollView.frame.size.height - 25 - self.pageControl.frame.size.height - emojiBtnSize.height * 3) / 2.0;
    
    UIView *lastView = nil;
    for (int i = 0; i < self.pageViews.count; i ++ ) {
        UIView *pageView = self.pageViews[i];
        
        if (!lastView) {
            [pageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.pageScrollView.mas_left).offset(0);
            }];
        }else{
            [pageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(lastView.mas_right).offset(0);
            }];
            if (i == self.pageViews.count - 1) {
                [pageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.pageScrollView.mas_right).offset(0);
                }];
            }
        }
        
        [pageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.pageScrollView.mas_top).offset(0);
            make.bottom.equalTo(self.pageScrollView.mas_bottom).offset(0);
            make.height.equalTo(self.pageScrollView.mas_height);
            make.width.equalTo(self.mas_width);
        }];
        
        UIView *lastBtn = nil;
        for (int j = 0; j < pageView.subviews.count; j ++ ) {
            UIButton *emojiBtn = pageView.subviews[j];
            if (j % 8 == 0) {
                [emojiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(pageView.mas_left).offset(25);
                    if (lastBtn) {
                        make.top.equalTo(lastBtn.mas_bottom).offset(emojiVerticalSpacing);
                    }else{
                        make.top.equalTo(pageView.mas_top).offset(25);
                    }
                }];
                
            }else{
                [emojiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(lastBtn.mas_right).offset(emojiHorizontalSpacing);
                    make.top.equalTo(lastBtn.mas_top).offset(0);
                }];
            }
            [emojiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_offset(emojiBtnSize);
            }];
            lastBtn = emojiBtn;
        }
        lastView = pageView;
    }
}
-(NSArray *)emojis{
    if (!_emojis) {
        _emojis = @[
                    @[@"😊",@"😨",@"😍",@"😳",@"😎",@"😭",@"😌",@"😵",@"😴",@"😢",@"😅",@"😡",@"😜",@"😀",@"😲",@"😟",@"😤",@"😞",@"😫",@"😣",@"😈",@"😉",@"😯",@""],
                    @[@"😕",@"😰",@"😋",@"😝",@"😓",@"😀",@"😂",@"😘",@"😒",@"😏",@"😶",@"😱",@"😖",@"😩",@"😔",@"😑",@"😚",@"😪",@"😇",@"🙊",@"👊",@"👎",@"☝️",@""],
                    @[@"✌️",@"😬",@"😷",@"🙈",@"👌",@"👋",@"✊",@"💪",@"😆",@"☺️",@"🙉",@"👍",@"🙏",@"✋",@"☀️",@"☕️",@"⛄️",@"📚",@"🎁",@"🎉",@"🍦",@"☁️",@"❄️",@""],
                    @[@"⚡️",@"💰",@"🎂",@"🎓",@"🍖",@"☔️",@"⛅️",@"✏️",@"💩",@"🎄",@"🍷",@"🎤",@"🏀",@"🀄️",@"💣",@"📢",@"🌍",@"🍫",@"🎲",@"🏂",@"💡",@"💤",@"🚫",@""],
                    @[@"🌻",@"🍻",@"🎵",@"🏡",@"💢",@"📞",@"🚿",@"🍚",@"👪",@"👼",@"💊",@"🔫",@"🌹",@"🐶",@"💄",@"👫",@"👽",@"💋",@"🌙",@"🍉",@"🐷",@"💔",@"👻",@""],
                    @[@"😈",@"💍",@"🌲",@"🐴",@"👑",@"🔥",@"⭐️",@"⚽️",@"🕖",@"⏰",@"😁",@"🚀",@"⏳",@""]
                    ];
    }
    return _emojis;
}
-(UIScrollView *)pageScrollView{
    if (!_pageScrollView) {
        _pageScrollView = [[UIScrollView alloc] init];
        _pageScrollView.pagingEnabled = YES;
        _pageScrollView.backgroundColor = UIColorFromRGB(0xf8f8f8);
        _pageScrollView.showsHorizontalScrollIndicator = NO;
        _pageScrollView.delegate = self;
    }
    return _pageScrollView;
}
-(UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0x888888);
        _pageControl.pageIndicatorTintColor = UIColorFromRGB(0xb9b9b9);
    }
    return _pageControl;
}
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = UIColorFromRGB(0xffffff);
    }
    return _bottomView;
}
-(UIButton *)emojiSwitchBtn{
    if (!_emojiSwitchBtn) {
        _emojiSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emojiSwitchBtn setImage:[UIImage imageNamed:@"emoji_btn_normal"] forState:UIControlStateNormal];
        _emojiSwitchBtn.backgroundColor = UIColorFromRGB(0xf8f8f8);
    }
    return _emojiSwitchBtn;
}
-(UIButton *)sendBtn{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:UIColorFromRGB(0x9d9d9d) forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _sendBtn.backgroundColor = UIColorFromRGB(0xf8f8f8);
        [_sendBtn addTarget:self action:@selector(didClickSend:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}
@end
