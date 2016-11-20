//
//  PHAsset+Extend.m
//  TLMessageView
//
//  Created by 郭锐 on 2016/11/20.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "PHAsset+Extend.h"
#import <objc/runtime.h>

static char selectedKey;
static char originalKey;

@implementation PHAsset (Extend)
-(void)setSelected:(BOOL)selected{
    objc_setAssociatedObject(self, &selectedKey, @(selected), OBJC_ASSOCIATION_ASSIGN);
}
-(BOOL)selected{
    return [objc_getAssociatedObject(self, &selectedKey) boolValue];
}
-(void)setIsOriginal:(BOOL)isOriginal{
    objc_setAssociatedObject(self, &originalKey, @(isOriginal), OBJC_ASSOCIATION_ASSIGN);
}
-(BOOL)isOriginal{
    return [objc_getAssociatedObject(self, &originalKey) boolValue];
}
@end
