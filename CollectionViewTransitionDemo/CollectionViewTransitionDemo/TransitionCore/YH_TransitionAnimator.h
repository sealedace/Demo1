//
//  YH_TransitionAnimator.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 15/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "YH_TransitionManager.h"

@interface YH_TransitionAnimator : NSObject
<YH_ControllerAnimatedTransitioning>
@property (readonly, weak, nonatomic) id <UIViewControllerContextTransitioning> _Nullable transitionContext;

@end
