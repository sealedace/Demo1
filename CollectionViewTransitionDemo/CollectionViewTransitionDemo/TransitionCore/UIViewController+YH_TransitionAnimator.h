//
//  UIViewController+YH_TransitionAnimator.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 16/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YH_TransitionAnimator;

@interface UIViewController (YH_TransitionAnimator)

- (void)yh_viewControllerWillBeginTransition:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom;

- (void)yh_viewControllerBeginTransitionAnimation:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom;

//- (void)yh_viewControllerWillEndTransition:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom;

- (void)yh_viewControllerEndTransitionAnimation:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom;

- (void)yh_setFromView:(UIView * _Nullable)view forTransitionAnimator:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom;

- (void)yh_setToView:(UIView * _Nullable)view forTransitionAnimator:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom;

- (UIView * _Nullable)yh_fromViewForTransitionAnimator:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom;

- (UIView * _Nullable)yh_toViewForTransitionAnimator:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom;

@end
