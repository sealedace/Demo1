//
//  DemoSectionHeader.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 09/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "DemoSectionHeader.h"

@implementation DemoSectionHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (IBAction)rightButtonPressed:(id)sender {
    !self.rightButtonPressed ?: self.rightButtonPressed();
}

- (IBAction)leftButtonPressed:(id)sender {
    !self.leftButtonPressed ?: self.leftButtonPressed();
}

@end
