//
//  ViewController.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 09/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "ViewController.h"

#import "DummyDataSource.h"
#import "DemoCollectionViewCell.h"
#import "DemoSectionHeader.h"

#import "YH_WaterFallFlowLayout.h"
#import "YH_PhotoBrowserViewController.h"

typedef NS_ENUM(NSInteger, LayoutType) {
    LayoutType_Waterfall = 0,
};

@interface ViewController ()
<UICollectionViewDataSource, YH_WaterFallFlowLayoutDelegate,
YH_PhotoBrowserDelegate, YH_PhotoBrowserDataSource>

@property (strong, nonatomic) DummyDataSource *dataSource;
@property (nonatomic) NSInteger numberOfColumns;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) YH_WaterFallFlowLayout *collectionViewLayout;

@end

@implementation ViewController

- (DummyDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [[DummyDataSource alloc] init];
    }
    return _dataSource;
}

- (YH_WaterFallFlowLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        self.numberOfColumns = 1;
        _collectionViewLayout = [[YH_WaterFallFlowLayout alloc] init];
        _collectionViewLayout.sectionInset = UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f);
        _collectionViewLayout.itemSpacing = 10.f;
    }
    return _collectionViewLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:self.collectionViewLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
    }
    return _collectionView;
}

- (void)loadView {
    [super loadView];
    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([DemoCollectionViewCell class])
                                                    bundle:[NSBundle mainBundle]]
          forCellWithReuseIdentifier:NSStringFromClass([DemoCollectionViewCell class])];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(DemoSectionHeader.class)
                                                    bundle:[NSBundle mainBundle]]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:NSStringFromClass(DemoSectionHeader.class)];

    self.collectionView.prefetchDataSource = self.dataSource;
    
    self.collectionView.prefetchingEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Water Fall";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataSource numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource numberOfItemsInSection:section];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DemoCollectionViewCell *cell = [collectionView  dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DemoCollectionViewCell class])
                                                                              forIndexPath:indexPath];
    cell.nameLabel.text = [NSString stringWithFormat:@"%zd-%zd", indexPath.section, indexPath.item];
    cell.coverImageView.image = [self.dataSource dataAtIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DemoSectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                       withReuseIdentifier:NSStringFromClass(DemoSectionHeader.class)
                                                                              forIndexPath:indexPath];
        
        __weak typeof(self) weakSelf = self;
        header.rightButtonPressed = ^{
            [weakSelf increaseColumn];
        };
        header.leftButtonPressed = ^{
            [weakSelf decreaseColumn];
        };
        
        return header;
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YH_PhotoBrowserViewController *vc = [[YH_PhotoBrowserViewController alloc] init];
    vc.yh_delegate = self;
    vc.yh_dataSource = self;
    vc.yh_startPage = indexPath.item;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - YH_WaterFallFlowLayoutDelegate
- (NSUInteger)collectionView:(UICollectionView *)collectionView layout:(YH_WaterFallFlowLayout *)collectionViewLayout numberOfColumnsInSection:(NSUInteger)section {
    // 指定section布局的列数
    return self.numberOfColumns;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(YH_WaterFallFlowLayout *)collectionViewLayout heightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 随机给定高度
    
    CGFloat itemHeight=0.0;
    
    if (indexPath.item%3 == 0) {
        
        itemHeight=200.0;
        
    } else if(indexPath.item%2 == 0) {
        
        itemHeight=300.0;
        
    } else {
        
        itemHeight=150.0;
    }
    
    return itemHeight;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(YH_WaterFallFlowLayout *)collectionViewLayout sizeForSupplementaryViewInSection:(NSUInteger)section kind:(NSString *)kind {
    
    if (section == 0 && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), 50.f);
    }
    
    return CGSizeZero;
}

- (BOOL)shouldStickHeaderToTopInSection:(NSUInteger)section {
    if (section == 0) {
        return YES;
    }
    
    return NO;
}

#pragma mark - YH_PhotoBrowserDataSource

- (NSInteger)numberOfPagesInViewController:(YH_PhotoBrowserViewController *)viewController {
    return [self.dataSource numberOfItemsInSection:0];
}

- (UIImage *)viewController:(YH_PhotoBrowserViewController *)viewController imageForPageAtIndex:(NSInteger)index {
    
    return [self.dataSource dataAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (UIView *)thumbViewForPageAtIndex:(NSInteger)index {
    
    DemoCollectionViewCell *cell = (DemoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.coverImageView;
    
//    if (self.thumb) {
//        return self.imageViews[index];
//    }
}

#pragma mark - YH_PhotoBrowserDelegate

//- (void)viewController:(PBViewController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)viewController:(PBViewController *)viewController didLongPressedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
//    NSLog(@"didLongPressedPageAtIndex: %@", @(index));
//}

#pragma mark - Private
- (void)increaseColumn {
    if (self.numberOfColumns >= 5) {
        return;
    }
    
    self.numberOfColumns++;
    
    [self.collectionViewLayout notifyCollectionViewRelayoutAnimated:YES];
}

- (void)decreaseColumn {
    if (self.numberOfColumns <= 1) {
        return;
    }
    
    self.numberOfColumns--;
    
    [self.collectionViewLayout notifyCollectionViewRelayoutAnimated:YES];
}

@end
