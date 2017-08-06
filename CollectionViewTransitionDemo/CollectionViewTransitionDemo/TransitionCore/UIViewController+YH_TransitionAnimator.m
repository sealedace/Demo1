//
//  UIViewController+YH_TransitionAnimator.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 16/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "UIViewController+YH_TransitionAnimator.h"
#import <objc/runtime.h>

static char *YH_viewsForTransitionAnimationKey = "YH_viewsForTransitionAnimationKey";

static NSString * const YH_fromViewForTransitionKey = @"YH_fromViewForTransitionKey";
static NSString * const YH_toViewForTransitionKey = @"YH_toViewForTransitionKey";

@implementation UIViewController (YH_TransitionAnimator)

- (NSMutableDictionary * _Nonnull)yh_viewsForTransitionAnimation {
    NSMutableDictionary *dic = objc_getAssociatedObject(self, YH_viewsForTransitionAnimationKey);
    if (!dic) {
        dic = [[NSMutableDictionary alloc] initWithCapacity:1];
        objc_setAssociatedObject(self, YH_viewsForTransitionAnimationKey, dic, OBJC_ASSOCIATION_RETAIN);
    }
    
    return dic;
}

- (void)yh_setFromView:(UIView *)view forTransitionAnimator:(YH_TransitionAnimator *)animator isFromViewController:(BOOL)bFrom {
    NSString *key = [[NSString alloc] initWithFormat:@"%p_%@", animator, YH_fromViewForTransitionKey];
    self.yh_viewsForTransitionAnimation[key] = view;
}

- (UIView * _Nullable)yh_fromViewForTransitionAnimator:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom{
    NSString *key = [[NSString alloc] initWithFormat:@"%p_%@", animator, YH_fromViewForTransitionKey];
    return self.yh_viewsForTransitionAnimation[key];
}

- (void)yh_setToView:(UIView *)view forTransitionAnimator:(YH_TransitionAnimator *)animator isFromViewController:(BOOL)bFrom {
    NSString *key = [[NSString alloc] initWithFormat:@"%p_%@", animator, YH_toViewForTransitionKey];
    self.yh_viewsForTransitionAnimation[key] = view;
}

- (UIView * _Nullable)yh_toViewForTransitionAnimator:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom {
    NSString *key = [[NSString alloc] initWithFormat:@"%p_%@", animator, YH_toViewForTransitionKey];
    return self.yh_viewsForTransitionAnimation[key];
}

- (void)yh_viewControllerWillBeginTransition:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom {
    
}

- (void)yh_viewControllerBeginTransitionAnimation:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom {
    
}

//- (void)yh_viewControllerWillEndTransition:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom {
//    
//}

- (void)yh_viewControllerEndTransitionAnimation:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom {
    
}

@end
