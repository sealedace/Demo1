//
//  YH_TransitionManager.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YH_TransitionManager : NSObject

+ (instancetype)sharedInstance;

@end

@interface UINavigationController (YH_TransitionManager)

//- (void)setTransitioningDelegate:(id<UIViewControllerTransitioningDelegate>)transitioningDelegate;

@end
