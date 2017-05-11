//
//  YH_ImageScrollView.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YH_ImageScrollView : UIScrollView
<UIScrollViewDelegate>

@property (nonatomic, strong, readonly) UIImageView *imageView;

@end
