//
//  TLLocationViewController.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/23.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>

@protocol TLLocationViewControllerDelegate <NSObject>
-(void)locationViewControllerSendMsg:(RCLocationMessage *)msg;
@end

@interface TLLocationViewController : UIViewController
@property(nonatomic,assign)id <TLLocationViewControllerDelegate> delegate;
@end
