//
//  DummyDataSource.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 09/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DummyDataSource : NSObject
<UICollectionViewDataSourcePrefetching>

- (NSInteger)numberOfSections;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

//- (void)loadNew;
//
//- (void)loadMore;


@end
