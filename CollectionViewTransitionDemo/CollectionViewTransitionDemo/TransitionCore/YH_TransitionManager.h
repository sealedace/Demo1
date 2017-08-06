//
//  YH_TransitionManager.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+YH_TransitionAnimator.h"

@protocol YH_ControllerAnimatedTransitioning <UIViewControllerAnimatedTransitioning>
@property (nonatomic) UINavigationControllerOperation operation;
@property (strong, nonatomic, nullable) id <UIViewControllerInteractiveTransitioning> interactiveTransitioning;

@end


@interface YH_TransitionManager : NSObject
// for forwarding message
@property (weak, nonatomic, nullable) NSObject <UINavigationControllerDelegate> *yh_forwardedDelegate;

- (void)registerTransitionFromController:(UIViewController * _Nonnull)from
                            toController:(UIViewController * _Nonnull)to
                     navigationOperation:(UINavigationControllerOperation)operation
                                animator:(id <YH_ControllerAnimatedTransitioning> _Nonnull)animator;

- (void)unregisterTransitionFromController:(UIViewController * _Nonnull)from
                              toController:(UIViewController * _Nonnull)to
                       navigationOperation:(UINavigationControllerOperation)operation;

- (id <YH_ControllerAnimatedTransitioning> _Nullable)getAnimatorWithFromController:(UIViewController * _Nonnull)from
                                                                      toController:(UIViewController * _Nonnull)to
                                                               navigationOperation:(UINavigationControllerOperation)operation;

@end

@interface UINavigationController (YH_TransitionManager)
@property (readonly, strong, nonatomic, nonnull) YH_TransitionManager *yh_transitionManager;

@end
