//
//  DemoProductViewController.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 15/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "DemoProductViewController.h"
#import "YH_TransitionAnimator.h"

@interface DemoProductViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) UICollectionView *pictureCollectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *imageArray;
@end

@implementation DemoProductViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    self.pictureCollectionView = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0.f;
        layout.itemSize = CGSizeMake(CGRectGetWidth(screenBounds), 200.f);
        layout.minimumLineSpacing = 10.f;
        layout.sectionInset = UIEdgeInsetsZero;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,
                                                                                              CGRectGetMaxY(self.navigationController.navigationBar.frame),
                                                                                              CGRectGetWidth(self.view.frame),
                                                                                              200.f)
                                                              collectionViewLayout:layout];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        collectionView.pagingEnabled = YES;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView;
    });
    
    [self.scrollView addSubview:self.pictureCollectionView];
    
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds)-CGRectGetMaxY(self.navigationController.navigationBar.frame));
    
    self.imageArray = @[ @"cat1.jpg", @"cat2.jpg", @"cat3.jpg", @"cat4.jpg" ];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.pictureCollectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200.f);
}

#pragma mark - Category: YH_TransitionAnimator
- (void)yh_viewControllerBeginTransitionAnimation:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom {
    if (animator.operation == UINavigationControllerOperationPush) {
        if (bFrom) {
            
        } else {
            [self yh_toViewForTransitionAnimator:animator].hidden = YES;
        }
    } else if (animator.operation == UINavigationControllerOperationPop) {
        
    }
}

- (void)yh_viewControllerEndTransitionAnimation:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom {
    if (animator.operation == UINavigationControllerOperationPush) {
        
    } else if (animator.operation == UINavigationControllerOperationPop) {
        
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                                           forIndexPath:indexPath];
    UIImageView *iv = [cell.contentView viewWithTag:11];
    if (!iv) {
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        iv.tag = 11;
        [cell.contentView addSubview:iv];
    }
    
    iv.image = [UIImage imageNamed:self.imageArray[indexPath.item]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate



@end
