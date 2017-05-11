//
//  YH_WaterFallFlowLayout.h
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 09/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YH_WaterFallFlowLayout;

@protocol YH_WaterFallFlowLayoutDelegate <UICollectionViewDelegate>
@required
- (NSUInteger)collectionView:(UICollectionView *)collectionView layout:(YH_WaterFallFlowLayout *)collectionViewLayout numberOfColumnsInSection:(NSUInteger)section;
@optional
// 下面两个方法选一个实现
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(YH_WaterFallFlowLayout *)collectionViewLayout heightItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(YH_WaterFallFlowLayout *)collectionViewLayout heightItemAtIndexPath:(NSIndexPath *)indexPath withWidth:(CGFloat)cellWidth;

// Sometimes you would prefer your cells to mantain an specific aspect ratio. In these cases, you and implement the following method and
// leave PDKTCollectionViewWaterfallLayout do cells size calculations
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(YH_WaterFallFlowLayout *)collectionViewLayout aspectRatioForIndexPath:(NSIndexPath *)indexPath;


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(YH_WaterFallFlowLayout *)collectionViewLayout itemSpacingInSection:(NSUInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(YH_WaterFallFlowLayout *)collectionViewLayout sectionInsetForSection:(NSUInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(YH_WaterFallFlowLayout *)collectionViewLayout sizeForSupplementaryViewInSection:(NSUInteger)section kind:(NSString *)kind;
- (BOOL)shouldStickHeaderToTopInSection:(NSUInteger)section;

@end

@interface YH_WaterFallFlowLayout : UICollectionViewLayout

@property (weak, nonatomic) id<YH_WaterFallFlowLayoutDelegate> delegate;

@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;


- (void)notifyCollectionViewRelayoutAnimated:(BOOL)animated;

@end

#pragma mark - UICollectionView(YH_WaterFallFlowLayout)

@interface UICollectionView (YH_WaterFallFlowLayout)

@end
