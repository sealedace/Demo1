//
//  YH_PhotoBrowserViewController.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YH_PhotoBrowserViewController;

@protocol YH_PhotoBrowserDelegate <NSObject>


@end

@protocol YH_PhotoBrowserDataSource <NSObject>

- (NSInteger)numberOfPagesInViewController:(nonnull YH_PhotoBrowserViewController *)viewController;

@optional

/// Return the image, implement one of this or follow method
- (nonnull UIImage *)viewController:(nonnull YH_PhotoBrowserViewController *)viewController imageForPageAtIndex:(NSInteger)index;

/// Configure the imageView's image, implement one of this or upper method
- (void)viewController:(nonnull YH_PhotoBrowserViewController *)viewController presentImageView:(nonnull UIImageView *)imageView forPageAtIndex:(NSInteger)index progressHandler:(nullable void (^)(NSInteger receivedSize, NSInteger expectedSize))progressHandler;

/// Use for dismiss animation, will be an UIImageView in general.
- (nullable UIView *)thumbViewForPageAtIndex:(NSInteger)index;

@end

@interface YH_PhotoBrowserViewController : UIPageViewController

@property (weak, nonatomic, nullable) id <YH_PhotoBrowserDelegate> yh_delegate;
@property (weak, nonatomic, nullable) id <YH_PhotoBrowserDataSource> yh_dataSource;

@property (nonatomic) NSInteger yh_startPage;

+ (void)setPageSpacing:(CGFloat)spacing;

@end
