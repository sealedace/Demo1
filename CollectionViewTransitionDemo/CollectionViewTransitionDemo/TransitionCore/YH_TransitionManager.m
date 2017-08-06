//
//  YH_TransitionManager.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "YH_TransitionManager.h"
#import <objc/runtime.h>

static char *TransitionManagerKey = "YH_TransitionManagerKey";

@interface YH_TransitionManager ()
<UINavigationControllerDelegate>
@property (strong, nonatomic) NSMutableDictionary *transitionRecords;
@end

@implementation YH_TransitionManager

#pragma mark - Getters
- (NSMutableDictionary *)transitionRecords {
    if (!_transitionRecords) {
        _transitionRecords = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return _transitionRecords;
}

- (NSString *)_transitionKeyWithFromController:(UIViewController * _Nonnull)from toController:(UIViewController * _Nonnull)to navigationOperation:(UINavigationControllerOperation)operation {
    
    NSString *transitionKey = [[NSString alloc] initWithFormat:@"%p_%p_%zd", from, to, operation];
    return transitionKey;
}

#pragma mark - Message Forwarding
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        signature = [self.yh_forwardedDelegate methodSignatureForSelector:aSelector];
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self respondsToSelector:anInvocation.selector]) {
        [super forwardInvocation:anInvocation];
    } else if ([self.yh_forwardedDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.yh_forwardedDelegate];
    }
}

#pragma mark - UINavigationControllerDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0) {
    
    NSString *transitionKey = [self _transitionKeyWithFromController:fromVC toController:toVC navigationOperation:operation];
    id<YH_ControllerAnimatedTransitioning> animator = self.transitionRecords[transitionKey];
    if (animator) {
        animator.operation = operation;
    }
    
    return animator;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController NS_AVAILABLE_IOS(7_0) {
    if ([animationController conformsToProtocol:@protocol(YH_ControllerAnimatedTransitioning)]) {
        id<YH_ControllerAnimatedTransitioning> animator = (id<YH_ControllerAnimatedTransitioning>)animationController;
        return animator.interactiveTransitioning;
    }
    return nil;
}

#pragma mark - Public
- (void)registerTransitionFromController:(UIViewController * _Nonnull)from
                            toController:(UIViewController * _Nonnull)to
                     navigationOperation:(UINavigationControllerOperation)operation
                                animator:(id <YH_ControllerAnimatedTransitioning> _Nonnull)animator {
    
    NSString *transitionKey = [self _transitionKeyWithFromController:from toController:to navigationOperation:operation];
    self.transitionRecords[transitionKey] = animator;
}

- (void)unregisterTransitionFromController:(UIViewController * _Nonnull)from
                              toController:(UIViewController * _Nonnull)to
                       navigationOperation:(UINavigationControllerOperation)operation {
    NSString *transitionKey = [self _transitionKeyWithFromController:from toController:to navigationOperation:operation];
    [self.transitionRecords removeObjectForKey:transitionKey];
}

- (id <YH_ControllerAnimatedTransitioning> _Nullable)getAnimatorWithFromController:(UIViewController * _Nonnull)from
                                                                      toController:(UIViewController * _Nonnull)to
                                                               navigationOperation:(UINavigationControllerOperation)operation {
    NSString *transitionKey = [self _transitionKeyWithFromController:from toController:to navigationOperation:operation];
    return self.transitionRecords[transitionKey];
}

@end

@implementation UINavigationController (YH_TransitionManager)

- (YH_TransitionManager *)yh_transitionManager {
    YH_TransitionManager *m = objc_getAssociatedObject(self, TransitionManagerKey);
    if (!m) {
        m = [[YH_TransitionManager alloc] init];
        objc_setAssociatedObject(self, TransitionManagerKey, m, OBJC_ASSOCIATION_RETAIN);
        self.delegate = m;
    }
    
    return m;
}

@end

