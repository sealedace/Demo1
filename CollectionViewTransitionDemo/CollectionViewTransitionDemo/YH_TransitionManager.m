//
//  YH_TransitionManager.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "YH_TransitionManager.h"

@implementation YH_TransitionManager

+ (instancetype)sharedInstance {
    static YH_TransitionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YH_TransitionManager alloc] init];
    });
    
    return instance;
}

@end

@implementation UINavigationController (YH_TransitionManager)


@end

