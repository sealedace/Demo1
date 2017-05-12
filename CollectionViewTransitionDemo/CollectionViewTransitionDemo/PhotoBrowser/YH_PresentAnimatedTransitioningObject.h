//
//  YH_PresentAnimatedTransitioningObject.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^YH_ContextBlock)(UIView * __nonnull fromView, UIView * __nonnull toView);

@interface YH_PresentAnimatedTransitioningObject : NSObject
<UIViewControllerAnimatedTransitioning>

@property (nonatomic, copy, nullable) YH_ContextBlock prepareForPresentActionHandler;
@property (nonatomic, copy, nullable) YH_ContextBlock duringPresentingActionHandler;
@property (nonatomic, copy, nullable) YH_ContextBlock didPresentedActionHandler;
@property (nonatomic, copy, nullable) YH_ContextBlock prepareForDismissActionHandler;
@property (nonatomic, copy, nullable) YH_ContextBlock duringDismissingActionHandler;
@property (nonatomic, copy, nullable) YH_ContextBlock didDismissedActionHandler;

@property (nonatomic, strong, nonnull) UIView *coverView;

- (nonnull YH_PresentAnimatedTransitioningObject *)yh_prepareForPresent;
- (nonnull YH_PresentAnimatedTransitioningObject *)yh_prepareForDismiss;

@end
