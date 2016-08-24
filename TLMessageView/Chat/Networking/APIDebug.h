//
//  APIDebug.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/24.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

@interface APIDebug : NSObject
+(void)configWithVC:(UIViewController *)vc;
+(void)sendMsgWithContent:(NSString *)content
               objectName:(NSString *)objectName
                success:(void(^)())success
                failure:(void(^)(NSError *error))failure;
@end


@interface ActionSheet : UIActionSheet <UIActionSheetDelegate>
-(instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle action:(void(^)(NSInteger))action otherButtonTitles:(NSArray *)otherButtonTitles;
@end