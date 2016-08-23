//
//  TLLocationMessageCell.m
//  TLMessageView
//
//  Created by 郭锐 on 16/8/23.
//  Copyright © 2016年 com.garry.message. All rights reserved.
//

#import "TLLocationMessageCell.h"
#import <MapKit/MapKit.h>

@interface TLLocationMessageCell ()
@property(nonatomic,strong)UIImageView *previewImageView;
@property(nonatomic,strong)UILabel *placeLabel;
@end

@implementation TLLocationMessageCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {        
        [self.bubbleImageView addSubview:self.previewImageView];
        [self.previewImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.bubbleImageView).priorityHigh(1);
        }];
        
        [self.previewImageView addSubview:self.placeLabel];
        [self.placeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.previewImageView.mas_left).offset(0);
            make.right.equalTo(self.previewImageView.mas_right).offset(0);
            make.bottom.equalTo(self.previewImageView.mas_bottom).offset(0);
            make.height.mas_offset(30);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickLocation)];
        [self.previewImageView addGestureRecognizer:tap];
    }
    return self;
}
-(void)didClickLocation{
    RCLocationMessage *locMessage = (RCLocationMessage *)self.message.content;
    
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:locMessage.location addressDictionary:nil]];
    toLocation.name = locMessage.locationName;
    NSDictionary *launchOptions = [NSDictionary
                                   dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                   forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]];
    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                   launchOptions:launchOptions];
}
-(void)updateMessage:(RCMessage *)message showDate:(BOOL)showDate{
    [super updateMessage:message showDate:showDate];
    RCLocationMessage *locMessage = (RCLocationMessage *)message.content;
    self.previewImageView.image = locMessage.thumbnailImage;
    self.placeLabel.text = locMessage.locationName;
    
    CGSize size = CGSizeMake(187.5, 150);
    
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:self.bubbleImageView.image];
    imageViewMask.frame = CGRectMake(0, 0, size.width, size.height);
    self.previewImageView.layer.mask = imageViewMask.layer;
    
    [self.previewImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(size);
    }];
}
-(UIImageView *)previewImageView{
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.layer.masksToBounds = YES;
        _previewImageView.userInteractionEnabled = YES;
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _previewImageView;
}
-(UILabel *)placeLabel{
    if (!_placeLabel) {
        _placeLabel = [[UILabel alloc] init];
        _placeLabel.font = [UIFont systemFontOfSize:14];
        _placeLabel.textColor = UIColorFromRGB(0xffffff);
        _placeLabel.backgroundColor = UIColorFromRGBA(0x000000, 0.7);
        _placeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _placeLabel;
}
@end
