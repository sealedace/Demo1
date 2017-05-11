//
//  YH_ImageScrollerViewController.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 11/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "YH_ImageScrollerViewController.h"
#import "YH_ImageScrollView.h"

@interface YH_ImageScrollerViewController ()
@property (nonatomic, strong, readwrite) YH_ImageScrollView *imageScrollView;
@property (nonatomic, weak, readwrite) UIImageView *imageView;
@property (nonatomic, strong, readwrite) CAShapeLayer *progressLayer;
@property (nonatomic, assign) BOOL dismissing;
@end

@implementation YH_ImageScrollerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.imageScrollView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self _prepareForReuse];
    
    if (self.fetchImageHandler) {
        self.imageView.image = self.fetchImageHandler();
    } else if (self.configureImageViewWithDownloadProgressHandler) {
        __weak typeof(self) weakSelf = self;
        self.configureImageViewWithDownloadProgressHandler(self.imageView, ^(NSInteger receivedSize, NSInteger expectedSize) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.dismissing || !strongSelf.view.window) {
                strongSelf.progressLayer.hidden = YES;
                return;
            }
            CGFloat progress = (receivedSize * 1.0f) / (expectedSize * 1.0f);
            if (0.0f >= progress || progress >= 1.0f) {
                strongSelf.progressLayer.hidden = YES;
                return;
            }
            strongSelf.progressLayer.hidden = NO;
            strongSelf.progressLayer.strokeEnd = progress;
            
        });
    } else if (self.configureImageViewHandler) {
        self.configureImageViewHandler(self.imageView);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.progressLayer.hidden = YES;
    self.dismissing = YES;
}

#pragma mark - Getters
- (YH_ImageScrollView *)imageScrollView {
    if (!_imageScrollView) {
        _imageScrollView = [YH_ImageScrollView new];
    }
    return _imageScrollView;
}

- (UIImageView *)imageView {
    return self.imageScrollView.imageView;
}

#pragma mark - Private

- (void)_prepareForReuse {
    self.imageView.image = nil;
    self.progressLayer.hidden = YES;
    self.progressLayer.strokeStart = 0;
    self.progressLayer.strokeEnd = 0;
    self.dismissing = NO;
}

@end
