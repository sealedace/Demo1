//
//  YH_ImageScrollView.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "YH_ImageScrollView.h"
#import "YH_ImageScrollView+internal.h"

@interface YH_ImageScrollView ()
<UIGestureRecognizerDelegate>
@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, weak) id <NSObject> notification;
/// direction: > 0 up, < 0 dwon, == 0 others(no swipe, e.g. tap).
@property (nonatomic, assign) CGFloat direction;
@property (nonatomic, assign) BOOL dismissing;

@end

@implementation YH_ImageScrollView

- (void)dealloc {
    [self _removeObserver];
    [self _removeNotificationIfNeeded];
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.frame = [UIScreen mainScreen].bounds;
    self.multipleTouchEnabled = YES;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = YES;
//    self.alwaysBounceVertical = YES;
    self.alwaysBounceHorizontal = YES;
    self.minimumZoomScale = 1.0f;
    self.maximumZoomScale = 1.0f;
    self.delegate = self;
    
    [self addSubview:self.imageView];
    [self _addObserver];
    [self _addNotificationIfNeeded];
    
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self _updateFrame];
    [self _recenterImage];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (!self.window) {
        [self _updateUserInterfaces];
    }
}

#pragma mark - Getters
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:@"image"]) {
        return;
    }
    if (![object isEqual:self.imageView]) {
        return;
    }
    if (!self.imageView.image) {
        return;
    }
    
    [self _updateUserInterfaces];
}

#pragma mark - internal Methods

- (void)_handleZoomForLocation:(CGPoint)location {
    CGPoint touchPoint = [self.superview convertPoint:location toView:self.imageView];
    if (self.zoomScale > 1) {
        [self setZoomScale:1 animated:YES];
    } else if (self.maximumZoomScale > 1) {
        CGFloat newZoomScale = self.maximumZoomScale;
        CGFloat horizontalSize = CGRectGetWidth(self.bounds) / newZoomScale;
        CGFloat verticalSize = CGRectGetHeight(self.bounds) / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - horizontalSize / 2.0f, touchPoint.y - verticalSize / 2.0f, horizontalSize, verticalSize) animated:YES];
    }
}

#pragma mark - Private methods

- (void)_addObserver {
    [self.imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_removeObserver {
    [self.imageView removeObserver:self forKeyPath:@"image"];
}

- (void)_addNotificationIfNeeded {
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        return;
    }
    
    __weak typeof(self) weak_self = self;
    self.notification = [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self _updateFrame];
        [strong_self _recenterImage];
    }];
}

- (void)_removeNotificationIfNeeded {
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self.notification];
}

- (void)_updateUserInterfaces {
    [self setZoomScale:1.0f animated:YES];
    [self _updateFrame];
    [self _recenterImage];
    [self _setMaximumZoomScale];
    self.alwaysBounceVertical = YES;
}

- (void)_updateFrame {
    self.frame = [UIScreen mainScreen].bounds;
    
    UIImage *image = self.imageView.image;
    if (!image) {
        return;
    }
    
    CGSize properSize = [self _properPresentSizeForImage:image];
    self.imageView.frame = CGRectMake(0, 0, properSize.width, properSize.height);
    self.contentSize = properSize;
}

- (CGSize)_properPresentSizeForImage:(UIImage *)image {
    CGFloat ratio = CGRectGetWidth(self.bounds) / image.size.width;
    return CGSizeMake(CGRectGetWidth(self.bounds), ceil(ratio * image.size.height));
}

- (void)_recenterImage {
    CGFloat contentWidth = self.contentSize.width;
    CGFloat horizontalDiff = CGRectGetWidth(self.bounds) - contentWidth;
    CGFloat horizontalAddition = horizontalDiff > 0.f ? horizontalDiff : 0.f;
    
    CGFloat contentHeight = self.contentSize.height;
    CGFloat verticalDiff = CGRectGetHeight(self.bounds) - contentHeight;
    CGFloat verticalAdditon = verticalDiff > 0 ? verticalDiff : 0.f;
    
    self.imageView.center = CGPointMake((contentWidth + horizontalAddition) / 2.0f, (contentHeight + verticalAdditon) / 2.0f);
}

- (void)_setMaximumZoomScale {
    CGSize imageSize = self.imageView.image.size;
    CGFloat selfWidth = CGRectGetWidth(self.bounds);
    CGFloat selfHeight = CGRectGetHeight(self.bounds);
    if (imageSize.width <= selfWidth && imageSize.height <= selfHeight) {
        self.maximumZoomScale = 1.0f;
    } else {
        self.maximumZoomScale = MAX(MIN(imageSize.width / selfWidth, imageSize.height / selfHeight), 3.0f);
    }
}

- (CGFloat)_contentOffSetVerticalPercent {
    return [self _rawContentOffSetVerticalPercent];
}

/// +/- percent.
- (CGFloat)_rawContentOffSetVerticalPercent {
    CGFloat percent = 0;
    
    CGFloat contentHeight = self.contentSize.height;
    CGFloat scrollViewHeight = CGRectGetHeight(self.bounds);
    CGFloat offsetY = self.contentOffset.y;
    
    if (offsetY < 0) {
        percent = MAX(offsetY / (scrollViewHeight / 3.0), -1.0f);
    } else {
        if (contentHeight < scrollViewHeight) {
            percent = MIN(offsetY / (scrollViewHeight / 3.0), 1.0f);
        } else {
            offsetY += scrollViewHeight;
            CGFloat contentHeight = self.contentSize.height;
            if (offsetY > contentHeight) {
                percent = MIN((offsetY - contentHeight) / (scrollViewHeight / 3.0f), 1.0f);
            }
        }
    }
    
    return percent;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.dismissing) {
        return;
    }
    if (!self.contentOffSetVerticalPercentHandler) {
        return;
    }
    
    CGFloat offsetVerticalPercent = [self _contentOffSetVerticalPercent];

//    NSLog(@"offsetVerticalPercent: %f", offsetVerticalPercent);
    
    self.contentOffSetVerticalPercentHandler(offsetVerticalPercent);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self _recenterImage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    if (!decelerate) {
//        return;
//    }
//    
//    NSLog(@"direction: %f", self.direction);
//    
//    // 停止时有相反方向滑动操作时取消退出操作
//    CGFloat rawPercent = [self _rawContentOffSetVerticalPercent];
//    
//    if (rawPercent * self.direction < 0) {
//        return;
//    }
//    
//    if (self.direction > -1.f && fabs(rawPercent) <= 0.3f) {
//        return;
//    }
//    
//    if (self.didEndDraggingInProperpositionHandler && self.direction < 0) {
//        // 取消回弹效果，所以计算 imageView 的 frame 的时候需要注意 contentInset.
//        scrollView.bounces = NO;
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//        self.didEndDraggingInProperpositionHandler(self.direction);
//        self.dismissing = YES;
//        return;
//    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    self.direction = velocity.y;
    
    NSLog(@"direction: %f", self.direction);
    
    // 停止时有相反方向滑动操作时取消退出操作
    CGFloat rawPercent = [self _rawContentOffSetVerticalPercent];
    
    if (rawPercent * self.direction < 0) {
        return;
    }
    
    if (self.direction > -.5f && fabs(rawPercent) <= 0.3f) {
        return;
    }
    
    if (self.didEndDraggingInProperpositionHandler && self.direction < 0) {
        // 取消回弹效果，所以计算 imageView 的 frame 的时候需要注意 contentInset.
        scrollView.bounces = NO;
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, -scrollView.contentOffset.x, 0, 0);
        
        *targetContentOffset = scrollView.contentOffset;
        
        self.didEndDraggingInProperpositionHandler(self.direction);
        self.dismissing = YES;
        return;
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.dismissing) {
        return;
    }
    if (scrollView.zoomScale < 1) {
        [scrollView setZoomScale:1.0f animated:YES];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
