//
//  YH_PhotoBrowserViewController.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "YH_PhotoBrowserViewController.h"
#import "YH_ImageScrollerViewController.h"
#import "YH_PresentAnimatedTransitioningObject.h"
#import "YH_ImageScrollView+internal.h"

static CGFloat kPhotoBrowserInterPageSpacing = 20.f;

static NSUInteger const kReusablePageCount = 3;

@interface YH_PhotoBrowserViewController ()
<UIViewControllerTransitioningDelegate,
UIPageViewControllerDelegate,
UIPageViewControllerDataSource>
@property (nonatomic) NSInteger numberOfPages;
@property (nonatomic) NSInteger currentPage;

@property (nonatomic, assign) CGFloat direction;
/// Blur background view
@property (nonatomic, strong) UIView *blurBackgroundView;

@property (nonatomic, strong) NSArray<YH_ImageScrollerViewController *> *reusableImageScrollerViewControllers;
@property (strong, nonatomic) YH_PresentAnimatedTransitioningObject *transitioningObject;

@property (nonatomic, strong) UIImageView *thumbDoppelgangerView;

// Gestures
@property (nonatomic, strong) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation YH_PhotoBrowserViewController

+ (void)setPageSpacing:(CGFloat)spacing {
    if (spacing > 0) {
        kPhotoBrowserInterPageSpacing = spacing;
    }
}

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<NSString *,id> *)options {
    
    NSMutableDictionary *dict = [(options ?: @{}) mutableCopy];
    [dict setObject:@(kPhotoBrowserInterPageSpacing) forKey:UIPageViewControllerOptionInterPageSpacingKey];
    
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:navigationOrientation
                                  options:dict];
    
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.transitioningDelegate = self;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.yh_dataSource respondsToSelector:@selector(numberOfPagesInViewController:)]) {
        self.numberOfPages = [self.yh_dataSource numberOfPagesInViewController:self];
    }
    
    // 设置为可见的控制器
    self.currentPage = (0 < self.currentPage && self.currentPage < self.numberOfPages ? self.currentPage : 0);
    
    YH_ImageScrollerViewController *firstImageScrollerViewController = [self _imageScrollerViewControllerForPage:self.currentPage];
    [self setViewControllers:@[firstImageScrollerViewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    
    // Blur background
    [self _addBlurBackgroundView];
    
//    self.view.layer.contents = (id)[[self _snapshotView:self.presentingViewController.view afterScreenUpdates:NO] CGImage];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.dataSource = self;
    self.delegate = self;
    
    [self _setupTransitioningObject];
    
    [self.view addGestureRecognizer:self.longPressGestureRecognizer];
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    [self.view addGestureRecognizer:self.singleTapGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.longPressGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    
}

#pragma mark - Getters
- (UITapGestureRecognizer *)singleTapGestureRecognizer {
    if (!_singleTapGestureRecognizer) {
        _singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTapAction:)];
    }
    return _singleTapGestureRecognizer;
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer {
    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTapAction:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapGestureRecognizer;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressAction:)];
    }
    return _longPressGestureRecognizer;
}

- (UIView *)blurBackgroundView {
    if (!_blurBackgroundView) {
        UIToolbar *view = [[UIToolbar alloc] initWithFrame:self.view.bounds];
        view.barStyle = UIBarStyleBlack;
        view.translucent = YES;
        view.clipsToBounds = YES;
        view.multipleTouchEnabled = NO;
        view.userInteractionEnabled = NO;
        _blurBackgroundView = view;
        
    }
    return _blurBackgroundView;
}

- (NSArray<YH_ImageScrollerViewController *> *)reusableImageScrollerViewControllers {
    if (!_reusableImageScrollerViewControllers) {
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:kReusablePageCount];
        for (NSInteger index = 0; index < kReusablePageCount; index++) {
            YH_ImageScrollerViewController *imageScrollerViewController = [YH_ImageScrollerViewController new];
            imageScrollerViewController.page = index;
            __weak typeof(self) weakSelf = self;
            imageScrollerViewController.imageScrollView.contentOffSetVerticalPercentHandler = ^(CGFloat percent) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.blurBackgroundView.alpha = 1.0f - percent;
            };
            imageScrollerViewController.imageScrollView.didEndDraggingInProperpositionHandler = ^(CGFloat direction){
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.direction = direction;
                [strongSelf dismissViewControllerAnimated:YES completion:nil];
            };
            [controllers addObject:imageScrollerViewController];
        }
        _reusableImageScrollerViewControllers = [[NSArray alloc] initWithArray:controllers];
    }
    return _reusableImageScrollerViewControllers;
}

- (YH_PresentAnimatedTransitioningObject *)transitioningObject {
    if (!_transitioningObject) {
        _transitioningObject = [YH_PresentAnimatedTransitioningObject new];
    }
    return _transitioningObject;
}

- (YH_ImageScrollerViewController *)currentScrollViewController {
    return self.reusableImageScrollerViewControllers[self.currentPage % kReusablePageCount];
}

- (UIView *)currentThumbView {
    if (!self.yh_dataSource) {
        return nil;
    }

    if (![self.yh_dataSource respondsToSelector:@selector(thumbViewForPageAtIndex:)]) {
        return  nil;
    }
    return [self.yh_dataSource thumbViewForPageAtIndex:self.currentPage];
}

- (UIImage *)currentThumbImage {
    UIView *currentThumbView = self.currentThumbView;
    if (!currentThumbView) {
        return nil;
    }
    if ([currentThumbView isKindOfClass:[UIImageView class]]) {
        return ((UIImageView *)self.currentThumbView).image;
    }
    if (currentThumbView.layer.contents) {
        return [[UIImage alloc] initWithCGImage:(__bridge CGImageRef _Nonnull)(currentThumbView.layer.contents)];
    }
    return nil;
}

- (UIImageView *)thumbDoppelgangerView {
    if (!_thumbDoppelgangerView) {
        _thumbDoppelgangerView = [UIImageView new];
    }
    return _thumbDoppelgangerView;
}

#pragma mark - Setters
- (void)setYh_startPage:(NSInteger)yh_startPage {
    _yh_startPage = yh_startPage;
    _currentPage = yh_startPage;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [self.transitioningObject yh_prepareForPresent];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [self.transitioningObject yh_prepareForDismiss];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
//    [self _showIndicator];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    YH_ImageScrollerViewController *imageScrollerViewController = pageViewController.viewControllers.firstObject;
    self.currentPage = imageScrollerViewController.page;
//    [self _updateIndicator];
//    [self _hideIndicator];
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(YH_ImageScrollerViewController *)viewController {
    return [self _imageScrollerViewControllerForPage:viewController.page - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(YH_ImageScrollerViewController *)viewController {
    return [self _imageScrollerViewControllerForPage:viewController.page + 1];
}

#pragma mark - Private
- (UIImage *)_snapshotView:(UIView *)view afterScreenUpdates:(BOOL)afterUpdates {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:afterUpdates];
    UIImage *outpu = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outpu;
}

- (void)_hideStatusBarIfNeeded {
    self.presentingViewController.view.window.windowLevel = UIWindowLevelStatusBar;
}

- (void)_showStatusBarIfNeeded {
    self.presentingViewController.view.window.windowLevel = UIWindowLevelNormal;
}

- (void)_addBlurBackgroundView {
    [self.view addSubview:self.blurBackgroundView];
    [self.view sendSubviewToBack:self.blurBackgroundView];
}

- (void)_setupTransitioningObject {
    __weak typeof(self) weakSelf = self;
    self.transitioningObject.prepareForPresentActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf _prepareForPresent];
    };
    self.transitioningObject.duringPresentingActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf _duringPresenting];
    };
    self.transitioningObject.didPresentedActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf _didPresent];
    };
    self.transitioningObject.prepareForDismissActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf _prepareForDismiss];
    };
    self.transitioningObject.duringDismissingActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf _duringDismissing];
    };
    self.transitioningObject.didDismissedActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf _didDidmiss];
    };
}

- (void)_prepareForPresent {
    YH_ImageScrollerViewController *currentScrollViewController = self.currentScrollViewController;
    currentScrollViewController.view.alpha = 0;
    self.blurBackgroundView.alpha = 0;
    UIView *thumbView = self.currentThumbView;
    if (!thumbView) {
        return;
    }
    
    CGRect newFrame = [thumbView.superview convertRect:thumbView.frame toView:self.view];
    self.thumbDoppelgangerView.frame = newFrame;
    self.thumbDoppelgangerView.image = self.currentThumbImage;
    self.thumbDoppelgangerView.contentMode = thumbView.contentMode;
    self.thumbDoppelgangerView.clipsToBounds = thumbView.clipsToBounds;
    self.thumbDoppelgangerView.backgroundColor = thumbView.backgroundColor;
    [self.view addSubview:self.thumbDoppelgangerView];
    
    thumbView.hidden = YES;
}

- (void)_duringPresenting {
    YH_ImageScrollerViewController *currentScrollViewController = self.currentScrollViewController;
    self.blurBackgroundView.alpha = 1;
    [self _hideStatusBarIfNeeded];
    
    if (!self.currentThumbView) {
        currentScrollViewController.view.alpha = 1;
        self.thumbDoppelgangerView.alpha = 0;
        return;
    }
    
    YH_ImageScrollView *imageScrollView = currentScrollViewController.imageScrollView;
    UIImageView *imageView = imageScrollView.imageView;
    CGRect newFrame = [imageView.superview convertRect:imageView.frame toView:self.view];
    
    if (CGRectEqualToRect(newFrame, CGRectZero)) {
        currentScrollViewController.view.alpha = 1;
        self.thumbDoppelgangerView.alpha = 0;
        return;
    }
    
    self.thumbDoppelgangerView.frame = newFrame;
}

- (void)_didPresent {
    self.currentScrollViewController.view.alpha = 1;
    [self.thumbDoppelgangerView removeFromSuperview];
    self.thumbDoppelgangerView.image = nil;
    self.thumbDoppelgangerView = nil;
//    [self _hideIndicator];
}

- (void)_prepareForDismiss {
    YH_ImageScrollerViewController *currentScrollViewController = self.currentScrollViewController;
    YH_ImageScrollView *imageScrollView = currentScrollViewController.imageScrollView;
    // 还原 zoom.
    if (imageScrollView.zoomScale != 1) {
        [imageScrollView setZoomScale:1 animated:NO];
    }
    // 如果内容很长的话（长微博），并且当前处于图片中间某个位置，没有超出顶部或者底部，需要特殊处理。
    CGFloat contentHeight = imageScrollView.contentSize.height;
    CGFloat scrollViewHeight = CGRectGetHeight(imageScrollView.bounds);
    if (contentHeight > scrollViewHeight) {
        CGFloat offsetY = imageScrollView.contentOffset.y;
        if (offsetY < 0) {
            return;
        }
        if (offsetY + scrollViewHeight > contentHeight) {
            return;
        }
        // 无 thumbView, 并且内容长度超过屏幕，非滑动退出模式。替换图片。
        if (0 == self.direction && !self.currentThumbView) {
            UIImage *image = [self _snapshotView:self.view afterScreenUpdates:NO];
            imageScrollView.imageView.image = image;
        }
        // 还原到页面顶部
        [imageScrollView setContentOffset:CGPointZero animated:NO];
    }
    
    self.currentThumbView.hidden = YES;
}

- (void)_duringDismissing {
    [self _showStatusBarIfNeeded];
    self.blurBackgroundView.alpha = 0;
    
    YH_ImageScrollerViewController *currentScrollViewController = self.currentScrollViewController;
    YH_ImageScrollView *imageScrollView = currentScrollViewController.imageScrollView;
    UIImageView *imageView = imageScrollView.imageView;
    UIImage *currentImage = imageView.image;
    // 图片未加载，默认 CrossDissolve 动画。
    if (!currentImage) {
        return;
    }
    
    // present 之前显示的图片视图。
    UIView *thumbView = self.currentThumbView;
    CGRect destFrame;
    if (thumbView) {
        imageView.clipsToBounds = thumbView.clipsToBounds;
        imageView.contentMode = thumbView.contentMode;
        // 还原到起始位置然后 dismiss.
        destFrame = [thumbView.superview convertRect:thumbView.frame toView:currentScrollViewController.view];
        // 把 contentInset 考虑进来。
        CGFloat verticalInset = imageScrollView.contentInset.top + imageScrollView.contentInset.bottom;
        destFrame = CGRectMake(CGRectGetMinX(destFrame), CGRectGetMinY(destFrame) - verticalInset, CGRectGetWidth(destFrame), CGRectGetHeight(destFrame));
    } else {
        // 移动到屏幕外然后 dismiss.
        if (0 == self.direction) {
            // 非滑动退出，中间
            destFrame = CGRectMake(CGRectGetWidth(imageScrollView.bounds) / 2, CGRectGetHeight(imageScrollView.bounds) / 2, 0, 0);
            // 图片渐变
            imageScrollView.alpha = 0;
        } else {
            CGFloat width = CGRectGetWidth(imageScrollView.imageView.bounds);
            CGFloat height = CGRectGetHeight(imageScrollView.imageView.bounds);
            if (0 < self.direction) {
                // 向上
                destFrame = CGRectMake(0, -height, width, height);
            } else {
                // 向下
                destFrame = CGRectMake(0, CGRectGetHeight(imageScrollView.bounds), width, height);
            }
        }
    }
    
    imageView.frame = destFrame;
}

- (void)_didDidmiss {
    self.currentThumbView.hidden = NO;
}

- (YH_ImageScrollerViewController * _Nullable)_imageScrollerViewControllerForPage:(NSInteger)page {
    if (page >= self.numberOfPages || page < 0) {
        return nil;
    }
    
    YH_ImageScrollerViewController *imageScrollerViewController = self.reusableImageScrollerViewControllers[page%kReusablePageCount];
    
    if (!self.yh_dataSource) {
        [NSException raise:@"`YH_PhotoBrowserDataSource` not set!" format:@""];
    }
    
    __weak typeof(self) weakSelf = self;
    imageScrollerViewController.page = page;
    
    if ([self.yh_dataSource respondsToSelector:@selector(viewController:imageForPageAtIndex:)]) {
        imageScrollerViewController.fetchImageHandler = ^UIImage *(void) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            return [strongSelf.yh_dataSource viewController:strongSelf imageForPageAtIndex:page];
        };
    } else if ([self.yh_dataSource respondsToSelector:@selector(viewController:presentImageView:forPageAtIndex:progressHandler:)]) {
        imageScrollerViewController.configureImageViewWithDownloadProgressHandler = ^(UIImageView *imageView, YH_ImageDownloadProgressHandler handler) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.yh_dataSource viewController:strongSelf presentImageView:imageView forPageAtIndex:page progressHandler:handler];
        };
    }
    
    return imageScrollerViewController;
}

#pragma mark - Gesture handlers
- (void)_handleSingleTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    if (!self.yh_delegate) {
        return;
    }
    
    if ([self.yh_delegate respondsToSelector:@selector(viewController:didSingleTapedPageAtIndex:presentedImage:)]) {
        [self.yh_delegate viewController:self didSingleTapedPageAtIndex:self.currentPage presentedImage:self.currentScrollViewController.imageScrollView.imageView.image];
    }
    
}

- (void)_handleDoubleTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint location = [sender locationInView:self.view];
    YH_ImageScrollView *imageScrollView = self.currentScrollViewController.imageScrollView;
    [imageScrollView _handleZoomForLocation:location];
}

- (void)_handleLongPressAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    if (!self.yh_delegate) {
        return;
    }
    
    if ([self.yh_delegate respondsToSelector:@selector(viewController:didLongPressedPageAtIndex:presentedImage:)]) {
        [self.yh_delegate viewController:self didLongPressedPageAtIndex:self.currentPage presentedImage:self.currentScrollViewController.imageScrollView.imageView.image];
    }
    
}

@end
