//
//  TLPluginBoardView.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/19.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSInteger pluginBoardHeight = 223;

@protocol TLPluginBoardViewDelegate <NSObject>
-(NSArray *)pluginBoardItems;
-(void)pluginBoardDidClickItemIndex:(NSInteger)itemIndex;
@end

@interface TLPluginBoardView : UIView
@property(nonatomic,assign)BOOL show;
@property(nonatomic,assign)id <TLPluginBoardViewDelegate> delegate;
-(instancetype)initWithDelegate:(id <TLPluginBoardViewDelegate>)delegate;
@end

@interface TLPluginBoardItem : NSObject
-(instancetype)initWithIcoNamed:(NSString *)icoNamed title:(NSString *)title;
@property(nonatomic,copy)NSString *icoNamed;
@property(nonatomic,copy)NSString *title;
@end

@interface TLPluginBoardButton : UIButton
-(instancetype)initWithItem:(TLPluginBoardItem *)item;
@end