//
//  DemoSectionHeader.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 09/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoSectionHeader : UICollectionReusableView
@property (copy, nonatomic) dispatch_block_t rightButtonPressed;
@property (copy, nonatomic) dispatch_block_t leftButtonPressed;

@end
