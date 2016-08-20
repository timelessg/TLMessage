//
//  TLPluginBoardView.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/19.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLPluginBoardView.h"
#import "TLProjectMacro.h"
#import <Masonry.h>

@interface TLPluginBoardView ()
@property(nonatomic,strong)NSMutableArray *btns;
@end

@implementation TLPluginBoardView

-(instancetype)initWithDelegate:(id<TLPluginBoardViewDelegate>)delegate{
    if (self = [super init]) {
        self.delegate = delegate;
        self.backgroundColor = [UIColor whiteColor];
        self.btns = [NSMutableArray array];
        NSArray *items = [self.delegate pluginBoardItems];
        for (int i = 0; i < items.count; i ++ ) {
            TLPluginBoardButton *btn = [[TLPluginBoardButton alloc] initWithItem:items[i]];
            btn.tag = 100 + i;
            [self addSubview:btn];
            [self.btns addObject:btn];
            [btn addTarget:self action:@selector(didClickItem:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}
-(void)didClickItem:(TLPluginBoardButton *)sender{
    if ([self.delegate respondsToSelector:@selector(pluginBoardDidClickItemIndex:)]) {
        [self.delegate pluginBoardDidClickItemIndex:sender.tag - 100];
    }
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat icoSpacingWidth = (self.frame.size.width - 60 * 4) / 5;
    CGFloat icoSpacingHeight = (self.frame.size.height - 90 * 2) / 3;
    
    for (int i = 0; i < self.btns.count; i ++ ) {
        TLPluginBoardButton *btn = self.btns[i];
        int k = i < 4 ? i : i - 4;
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset((k + 1) * icoSpacingWidth + 60 * k);
            make.top.equalTo(self.mas_top).offset(i < 4 ? icoSpacingHeight : icoSpacingHeight * 2 + 90);
            make.size.mas_offset(CGSizeMake(60, 90));
        }];
    }
}
@end

@implementation TLPluginBoardItem
-(instancetype)initWithIcoNamed:(NSString *)icoNamed title:(NSString *)title{
    if (self = [super init]) {
        self.icoNamed = icoNamed;
        self.title = title;
    }
    return self;
}
@end

@implementation TLPluginBoardButton
-(instancetype)initWithItem:(TLPluginBoardItem *)item{
    if (self = [super init]) {
        [self setImage:[UIImage imageNamed:item.icoNamed] forState:UIControlStateNormal];
        [self setTitle:item.title forState:UIControlStateNormal];
        [self setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGPoint center = self.imageView.center;
    center.x = self.frame.size.width / 2;
    center.y = self.imageView.frame.size.height / 2;
    self.imageView.center = center;
    
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.imageView.frame.size.height + 10;
    newFrame.size.width = self.frame.size.width;
    
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end