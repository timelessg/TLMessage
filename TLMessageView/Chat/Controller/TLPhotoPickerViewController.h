//
//  TLPhotoPickerViewController.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/25.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol TLPhotoPickerDelegate <NSObject>
-(void)didSendPhotos:(NSArray *)photos;
@end

@interface TLPhotoPickerViewController : UIViewController
@property(nonatomic,assign)id <TLPhotoPickerDelegate> delegate;
-(instancetype)initWithDelegate:(id <TLPhotoPickerDelegate>)delegate;
@end


@interface TLCountLabel : UILabel

@end