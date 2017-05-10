//
//  DummyDataSource.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 09/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "DummyDataSource.h"

@interface DummyDataSource ()
@property (strong, nonatomic) NSMutableArray *items;
@end

@implementation DummyDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:10];
        
        for (NSInteger i=0; i<20; i++) {
            [array addObject:[NSString stringWithFormat:@"%zd", i]];
        }
        
        [self.items addObject:array];
    }
    
    return self;
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return _items;
}

- (NSInteger)numberOfSections {
    return self.items.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return [self.items[section] count];
}

#pragma mark - UICollectionViewDataSourcePrefetching

// indexPaths are ordered ascending by geometric distance from the collection view
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths NS_AVAILABLE_IOS(10_0) {
    NSLog(@"prefetchItemsAtIndexPaths: %@", indexPaths);
    
    // preload
    
    NSIndexPath *indexPath = [indexPaths lastObject];
    if (indexPath.section == self.items.count-1
        && indexPath.item >= [[self.items lastObject] count]-1) {
        
        // load nex page
        NSMutableArray *array = [self.items lastObject];
        
        NSInteger currentCount = array.count;
        for (NSInteger i=0; i<10; i++) {
            [array addObject:[NSString stringWithFormat:@"%zd", currentCount+i]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [collectionView reloadData];
        });
    }
}

// indexPaths that previously were considered as candidates for pre-fetching, but were not actually used; may be a subset of the previous call to -collectionView:prefetchItemsAtIndexPaths:
- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths  NS_AVAILABLE_IOS(10_0) {
    NSLog(@"cancelPrefetchingForItemsAtIndexPaths: %@", indexPaths);
}

@end
