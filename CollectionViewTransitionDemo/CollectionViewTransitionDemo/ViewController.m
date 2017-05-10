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

typedef NS_ENUM(NSInteger, LayoutType) {
    LayoutType_Waterfall = 0,
};

@interface ViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, YH_WaterFallFlowLayoutDelegate>

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
    
    self.collectionView.prefetchingEnabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    NSInteger randomNumber = 1+indexPath.item%4;
    NSString *imageName = [NSString stringWithFormat:@"cat%zd.jpg", randomNumber];
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
    cell.coverImageView.image = [UIImage imageNamed:imageName];
    
    cell.backgroundColor = [UIColor grayColor];
    
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

#pragma mark - Private
- (void)increaseColumn {
    if (self.numberOfColumns >= 5) {
        return;
    }
    
    self.numberOfColumns++;
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:self.collectionView.collectionViewLayout animated:YES];
    } completion:^(BOOL finished) {
    }];
}

- (void)decreaseColumn {
    if (self.numberOfColumns <= 1) {
        return;
    }
    
    self.numberOfColumns--;
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:self.collectionView.collectionViewLayout animated:YES];
        
    } completion:^(BOOL finished) {
    }];
}

@end
