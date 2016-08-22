//
//  TLButton.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/22.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLButton.h"

@implementation TLButton
/**
 *  放大热区
 *
 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event{
    CGRect bounds = self.bounds;
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}
@end
