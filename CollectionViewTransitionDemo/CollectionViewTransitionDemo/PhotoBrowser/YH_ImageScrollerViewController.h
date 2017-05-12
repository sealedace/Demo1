//
//  YH_ImageScrollerViewController.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YH_ImageScrollView;

typedef void(^YH_ImageDownloadProgressHandler)(NSInteger receivedSize, NSInteger expectedSize);

@interface YH_ImageScrollerViewController : UIViewController

@property (nonatomic, assign) NSInteger page;
/// Return the image for current imageView
@property (nonatomic, copy) UIImage *(^fetchImageHandler)(void);
/// Configure image for current imageView
@property (nonatomic, copy) void (^configureImageViewHandler)(UIImageView *imageView);

/// Configure image for current imageView with progress
@property (nonatomic, copy) void (^configureImageViewWithDownloadProgressHandler)(UIImageView *imageView, YH_ImageDownloadProgressHandler handler);

@property (nonatomic, strong, readonly) YH_ImageScrollView *imageScrollView;

@end
