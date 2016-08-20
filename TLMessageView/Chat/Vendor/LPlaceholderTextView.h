//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPlaceholderTextView : UITextView
{
    UILabel *_placeholderLabel;
}


@property (strong, nonatomic) NSString *placeholderText;
@property (strong, nonatomic) UIColor *placeholderColor;
@property (assign, nonatomic) CGFloat maxTextViewHeight;
@end