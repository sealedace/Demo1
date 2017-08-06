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
    
    [self.scrollView addSubview:({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.f, 220.f, CGRectGetWidth(screenBounds), 700.f)];
        view.backgroundColor = [UIColor colorWithHue:0.3 saturation:0.4 brightness:0.3 alpha:1.f];
        view;
    })];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(screenBounds), 200.f+740.f);
    
    self.imageArray = @[ @"cat1.jpg", @"cat2.jpg", @"cat3.jpg", @"cat4.jpg" ];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.pictureCollectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200.f);
}

#pragma mark - Category: YH_TransitionAnimator
- (void)yh_viewControllerWillBeginTransition:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom {
    if (animator.operation == UINavigationControllerOperationPush) {
        if (bFrom) {
            
        } else {
            UICollectionViewCell *cell = [self.pictureCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            [self yh_setToView:[cell.contentView viewWithTag:11] forTransitionAnimator:animator isFromViewController:bFrom];
        }
    } else if (animator.operation == UINavigationControllerOperationPop) {
        if (bFrom) {
            UIView *view = [self yh_toViewForTransitionAnimator:animator isFromViewController:NO];
            [self yh_setFromView:view forTransitionAnimator:animator isFromViewController:YES];
        }
    }
}

- (void)yh_viewControllerBeginTransitionAnimation:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom {
    if (animator.operation == UINavigationControllerOperationPush) {
        if (bFrom) {
            
        } else {
            [self yh_toViewForTransitionAnimator:animator isFromViewController:bFrom].hidden = YES;
        }
    } else if (animator.operation == UINavigationControllerOperationPop) {
        if (bFrom) {
            [self yh_fromViewForTransitionAnimator:animator isFromViewController:bFrom].hidden = YES;
        }
    }
}

- (void)yh_viewControllerEndTransitionAnimation:(YH_TransitionAnimator * _Nonnull)animator isFromViewController:(BOOL)bFrom {
    if (animator.operation == UINavigationControllerOperationPush) {
        if (bFrom) {
            
        } else {
            [self yh_toViewForTransitionAnimator:animator isFromViewController:bFrom].hidden = NO;
        }
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
