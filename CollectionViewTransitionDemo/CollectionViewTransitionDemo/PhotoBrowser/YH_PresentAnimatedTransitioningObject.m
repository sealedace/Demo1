//
//  YH_PresentAnimatedTransitioningObject.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "YH_PresentAnimatedTransitioningObject.h"

@interface YH_PresentAnimatedTransitioningObject ()
@property (nonatomic, assign) BOOL isPresenting;
@end

@implementation YH_PresentAnimatedTransitioningObject

#pragma mark - Public methods

- (nonnull YH_PresentAnimatedTransitioningObject *)yh_prepareForPresent {
    self.isPresenting = YES;
    return self;
}

- (nonnull YH_PresentAnimatedTransitioningObject *)yh_prepareForDismiss {
    self.isPresenting = NO;
    return self;
}

#pragma mark - Private methods

- (UIViewAnimationOptions)_animationOptions {
    return 7 << 16;
}

- (void)_runAnimations:(void (^)(void))animations completion:(void (^)(BOOL flag))completion {
    [UIView animateWithDuration:0.25 delay:0 options:[self _animationOptions] animations:animations completion:completion];
}

- (void)_runPresentAnimationsWithContainer:(UIView *)container from:(UIView *)fromView to:(UIView *)toView completion:(void (^)(BOOL flag))completion {
    self.coverView.frame = container.frame;
    self.coverView.alpha = 0;
    [container addSubview:self.coverView];
    toView.frame = container.bounds;
    [container addSubview:toView];
    
    if (self.prepareForPresentActionHandler) {
        self.prepareForPresentActionHandler(fromView, toView);
    }
    __weak typeof(self) weak_self = self;
    [self _runAnimations:^{
        __strong typeof(weak_self) strong_self = weak_self;
        strong_self.coverView.alpha = 1;
        if (strong_self.duringPresentingActionHandler) {
            strong_self.duringPresentingActionHandler(fromView, toView);
        }
    } completion:^(BOOL flag) {
        __strong typeof(weak_self) strong_self = weak_self;
        if (strong_self.didPresentedActionHandler) {
            strong_self.didPresentedActionHandler(fromView, toView);
        }
        completion(flag);
    }];
}

- (void)_runDismissAnimationsWithContainer:(UIView *)container from:(UIView *)fromView to:(UIView *)toView completion:(void (^)(BOOL flag))completion {
    [container addSubview:fromView];
    if (self.prepareForDismissActionHandler) {
        self.prepareForDismissActionHandler(fromView, toView);
    }
    __weak typeof(self) weakSelf = self;
    [self _runAnimations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.coverView.alpha = 0;
        if (strongSelf.duringDismissingActionHandler) {
            strongSelf.duringDismissingActionHandler(fromView, toView);
        }
    } completion:^(BOOL flag) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.didDismissedActionHandler) {
            strongSelf.didDismissedActionHandler(fromView, toView);
        }
        completion(flag);
    }];
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = [transitionContext containerView];
    if (!container) {
        return;
    }
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (!fromController) {
        return;
    }
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (!toController) {
        return;
    }
    
    if (self.isPresenting) {
        [self _runPresentAnimationsWithContainer:container from:fromController.view to:toController.view completion:^(BOOL flag) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        [self _runDismissAnimationsWithContainer:container from:fromController.view to:toController.view completion:^(BOOL flag) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

#pragma mark - Accessor

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _coverView;
}

@end
