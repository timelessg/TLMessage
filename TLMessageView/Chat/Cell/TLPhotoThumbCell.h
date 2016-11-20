//
//  TLPhotoThumbCell.h
//  TLMessageView
//
//  Created by 郭锐 on 16/8/25.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface TLPhotoThumbCell : UICollectionViewCell
@property(nonatomic,strong)PHAsset *item;
@property(nonatomic,copy)BOOL (^selectBlock)(PHAsset *x);
@end
