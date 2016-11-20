//
//  PHAsset+Extend.h
//  TLMessageView
//
//  Created by 郭锐 on 2016/11/20.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (Extend)
//选中状态
@property(nonatomic,assign)BOOL selected;
//原图
@property(nonatomic,assign)BOOL isOriginal;
@end
