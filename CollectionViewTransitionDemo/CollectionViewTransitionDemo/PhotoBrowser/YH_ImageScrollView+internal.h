//
//  YH_ImageScrollView+internal.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#ifndef YH_ImageScrollView_internal_h
#define YH_ImageScrollView_internal_h

#import "YH_ImageScrollView.h"

@interface YH_ImageScrollView ()

- (void)_handleZoomForLocation:(CGPoint)location;

/// Scrolling content offset'y percent.
@property (nonatomic, copy) void(^contentOffSetVerticalPercentHandler)(CGFloat);

/// loosen hand with decelerate
/// direction: > 0 up, < 0 dwon, == 0 others(no swipe, e.g. tap).
@property (nonatomic, copy) void(^didEndDraggingInProperpositionHandler)(CGFloat direction);

@end

#endif /* YH_ImageScrollView_internal_h */
