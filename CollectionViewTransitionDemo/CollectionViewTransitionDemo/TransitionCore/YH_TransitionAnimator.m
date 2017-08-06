//
//  YH_TransitionAnimator.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 15/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "YH_TransitionAnimator.h"
#import "UIViewController+YH_TransitionAnimator.h"

static NSTimeInterval const kAnimationDuration = 1.3f;

@interface YH_TransitionAnimator()
{
    UINavigationControllerOperation _operation;
    __strong id<UIViewControllerInteractiveTransitioning> _interactiveTransitioning;
}
@property (weak, nonatomic) id  <UIViewControllerContextTransitioning> _Nullable transitionContext;

@end

@implementation YH_TransitionAnimator

#pragma mark - YH_ControllerAnimatedTransitioning

- (void)setOperation:(UINavigationControllerOperation)operation {
    _operation = operation;
}

- (UINavigationControllerOperation) operation {
    return _operation;
}

- (id<UIViewControllerInteractiveTransitioning>)interactiveTransitioning {
    return _interactiveTransitioning;
}

- (void)setInteractiveTransitioning:(id<UIViewControllerInteractiveTransitioning>)interactiveTransitioning {
    _interactiveTransitioning = interactiveTransitioning;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    UINavigationControllerOperation operation = self.operation;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    UIView *fromControllerView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toControllerView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    [toControllerView layoutIfNeeded];
    
    if ([fromViewController respondsToSelector:@selector(yh_viewControllerWillBeginTransition:isFromViewController:)]) {
        [fromViewController yh_viewControllerWillBeginTransition:self isFromViewController:YES];
    }
    
    if ([toViewController respondsToSelector:@selector(yh_viewControllerWillBeginTransition:isFromViewController:)]) {
        [toViewController yh_viewControllerWillBeginTransition:self isFromViewController:NO];
    }
    
    UIView *fromView = ({
        UIView *view = nil;
        view = [fromViewController yh_fromViewForTransitionAnimator:self isFromViewController:YES];
        
        view;
    });
    UIView *toView = ({
        UIView *view = nil;
        view = [toViewController yh_toViewForTransitionAnimator:self isFromViewController:NO];
        
        view;
    });
    
    if (operation == UINavigationControllerOperationPush) {
        [containerView addSubview:toViewController.view];
        
        CGRect fromRect = [containerView convertRect:fromView.frame fromView:fromView.superview];
        CGRect toRect = [containerView convertRect:toView.frame fromView:toView.superview];
        UIImageView *animatingImageView = [[UIImageView alloc] initWithFrame:fromRect];
        [containerView addSubview:animatingImageView];
        
        if ([fromView respondsToSelector:@selector(image)]) {
            UIImage *image = [fromView performSelector:@selector(image)];
            animatingImageView.contentMode = fromView.contentMode;
            animatingImageView.clipsToBounds = fromView.clipsToBounds;
            animatingImageView.image = image;
        }
        
        if ([fromViewController respondsToSelector:@selector(yh_viewControllerBeginTransitionAnimation:isFromViewController:)]) {
            [fromViewController yh_viewControllerBeginTransitionAnimation:self isFromViewController:YES];
        }
        
        if ([toViewController respondsToSelector:@selector(yh_viewControllerBeginTransitionAnimation:isFromViewController:)]) {
            [toViewController yh_viewControllerBeginTransitionAnimation:self isFromViewController:NO];
        }
        
        toControllerView.alpha = 0.f;
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             toControllerView.alpha = 1.f;
                             animatingImageView.frame = toRect;
                         }
                         completion:^(BOOL finished) {
                             [self _completeTransition:transitionContext];
                             [animatingImageView removeFromSuperview];
                         }];
        
    } else if (operation == UINavigationControllerOperationPop) {
        
        [containerView insertSubview:toViewController.view belowSubview:fromControllerView];
        
        CGRect fromRect = [containerView convertRect:fromView.frame fromView:fromView.superview];
        CGRect toRect = [containerView convertRect:toView.frame fromView:toView.superview];
        UIImageView *animatingImageView = [[UIImageView alloc] initWithFrame:fromRect];
        [containerView addSubview:animatingImageView];
        
        if ([fromView respondsToSelector:@selector(image)]) {
            UIImage *image = [fromView performSelector:@selector(image)];
            animatingImageView.contentMode = fromView.contentMode;
            animatingImageView.clipsToBounds = fromView.clipsToBounds;
            animatingImageView.image = image;
        }
        
        if ([fromViewController respondsToSelector:@selector(yh_viewControllerBeginTransitionAnimation:isFromViewController:)]) {
            [fromViewController yh_viewControllerBeginTransitionAnimation:self isFromViewController:YES];
        }
        
        if ([toViewController respondsToSelector:@selector(yh_viewControllerBeginTransitionAnimation:isFromViewController:)]) {
            [toViewController yh_viewControllerBeginTransitionAnimation:self isFromViewController:NO];
        }
        
        toControllerView.alpha = 0.f;
        fromControllerView.alpha = 1.f;
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             toControllerView.alpha = 1.f;
                             fromControllerView.alpha = 0.f;
                             animatingImageView.frame = toRect;
                         }
                         completion:^(BOOL finished) {
                             [self _completeTransition:transitionContext];
                             [animatingImageView removeFromSuperview];
                         }];
        
//        [containerView addSubview:toControllerView];
//        [self _completeTransition:transitionContext];
    }
}

// This is a convenience and if implemented will be invoked by the system when the transition context's completeTransition: method is invoked.
- (void)animationEnded:(BOOL) transitionCompleted {
    
}

#pragma mark - Private
- (void)_completeTransition:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if ([fromViewController respondsToSelector:@selector(yh_viewControllerEndTransitionAnimation:isFromViewController:)]) {
        [fromViewController yh_viewControllerEndTransitionAnimation:self isFromViewController:YES];
    }
    
    if ([toViewController respondsToSelector:@selector(yh_viewControllerEndTransitionAnimation:isFromViewController:)]) {
        [toViewController yh_viewControllerEndTransitionAnimation:self isFromViewController:NO];
    } 
    
    // unregister
    [toViewController.navigationController.yh_transitionManager unregisterTransitionFromController:fromViewController
                                                                                      toController:toViewController
                                                                               navigationOperation:self.operation];
    
    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
}

@end
