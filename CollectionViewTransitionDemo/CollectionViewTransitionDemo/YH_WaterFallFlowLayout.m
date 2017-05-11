//
//  YH_WaterFallFlowLayout.m
//  CollectionViewTransitionDemo
//
//  Created by gaoqiang xu on 09/05/2017.
//  Copyright © 2017 YOHO. All rights reserved.
//

#import "YH_WaterFallFlowLayout.h"

@interface YH_WaterFallFlowLayout ()
@property (nonatomic) NSInteger itemCount;
@property (nonatomic, strong) NSMutableArray *columnHeights;
@property (nonatomic, strong) NSMutableArray *itemAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryViewsAttibutes;


@end

@implementation YH_WaterFallFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        _itemSpacing = 0.0;
        _sectionInset = UIEdgeInsetsZero;
    }
    
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self commonInit];
    
    // 获取item总数
    self.itemCount = [self totalItemsCountInCollectionView];
    // 初始化各种数组
    [self initGeometryInformationCollections];
    // 计算各个item的属性
    for (NSInteger section = 0; section<[[self collectionView]numberOfSections]; section++){
        [self calculateItemsGeometryInSection:section];
    }
}

- (CGSize)collectionViewContentSize
{
    if (self.itemCount == 0) {
        return CGSizeZero;
    }
    UIEdgeInsets sectionInset = [self insetsForSection:self.columnHeights.count-1];
    CGSize contentSize = self.collectionView.frame.size;
    NSUInteger columnIndex = [self longestColumnIndexInSection:self.columnHeights.count-1];
    CGFloat height = [self.columnHeights[self.columnHeights.count-1][columnIndex] floatValue];
    contentSize.height = height + sectionInset.bottom;
    NSDictionary *supplementaryViewsAttributes = self.supplementaryViewsAttibutes[self.columnHeights.count-1];
    UICollectionViewLayoutAttributes *footerAttributes = [supplementaryViewsAttributes objectForKey:UICollectionElementKindSectionFooter];
    if (footerAttributes) {
        contentSize.height += footerAttributes.frame.size.height;
    }
    return contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    [self addVisibleItemAttributesToLayoutAttributes:attributes inRect:rect];
    [self addVisibleSupplementaryViewsAttributesToLayoutAttributes:attributes inRect:rect];
    [self addVisibleHeadersToLayoutAttributes:attributes fromVisibleSectionsWithoutHeader:[self visibleSectionsWithoutHeaderInAttributes:attributes]];
    [self updateStickedHeadersAttributesInLayoutAttributes:attributes];
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (!attributes) {
        if (self.itemAttributes.count > indexPath.section) {
            NSArray *array = self.itemAttributes[indexPath.section];
            if (array.count > indexPath.item) {
                attributes = array[indexPath.item];
            }
        }
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:elementKind
                                                                                         atIndexPath:indexPath];
    
    if (!attributes) {
        
        if (elementKind == UICollectionElementKindSectionHeader) {
            NSInteger section = indexPath.section;
            if (self.supplementaryViewsAttibutes.count > section) {
                attributes = [self.supplementaryViewsAttibutes[section] objectForKey:UICollectionElementKindSectionHeader];
            }
        }
        
    }
    return attributes;
}

#pragma mark - Accessors
- (void)setSectionInset:(UIEdgeInsets)sectionInset{
    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset)) {
        _sectionInset = sectionInset;
        [self invalidateLayout];
    }
}

#pragma mark - Private
- (void)commonInit{
    if (!self.delegate) {
        self.delegate = (id<YH_WaterFallFlowLayoutDelegate>)self.collectionView.delegate;
    }
}

- (void)initGeometryInformationCollections {
    self.itemAttributes = [NSMutableArray array];
    self.columnHeights = [NSMutableArray array];
    self.supplementaryViewsAttibutes = [NSMutableArray array];
}

- (NSUInteger)totalItemsCountInCollectionView {
    NSUInteger itemsCount = 0;
    for (NSInteger i=0; i<[self.collectionView numberOfSections];i++) {
        itemsCount += [[self collectionView] numberOfItemsInSection:i];
    }
    return itemsCount;
}

- (UIEdgeInsets)insetsForSection:(NSUInteger)section {
    UIEdgeInsets insets;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sectionInsetForSection:)]) {
        insets = [self.delegate collectionView:self.collectionView layout:self sectionInsetForSection:section];
    }else{
        insets = self.sectionInset;
    }
    return insets;
}

- (CGFloat)itemSpacingInSection:(NSUInteger)section {
    CGFloat itemSpacing;
    if([self.delegate respondsToSelector:@selector(collectionView:layout:itemSpacingInSection:)]){
        itemSpacing = [self.delegate collectionView:self.collectionView layout:self itemSpacingInSection:section];
    }else{
        itemSpacing = self.itemSpacing;
    }
    return itemSpacing;
}

- (NSUInteger)longestColumnIndexInSection:(NSUInteger)section
{
    NSUInteger index = 0;
    CGFloat longestHeight = 0;
    if (self.columnHeights.count>section) {
        NSUInteger idx=0;
        for (id obj in self.columnHeights[section]) {
            CGFloat height = [obj floatValue];
            if (height > longestHeight) {
                longestHeight = height;
                index = idx;
            }
            idx++;
        }
    }
    return index;
}

- (NSUInteger)shortestColumnIndexInSection:(NSUInteger)section
{
    NSUInteger index = 0;
    CGFloat shortestHeight = MAXFLOAT;
    if (self.columnHeights.count>section) {
        NSUInteger idx = 0;
        for (id obj in self.columnHeights[section]) {
            CGFloat height = [obj floatValue];
            if (height < shortestHeight) {
                shortestHeight = height;
                index = idx;
            }
            idx++;
        }
    }
    return index;
}

- (CGSize)headerSizeInSection:(NSUInteger)section kind:(NSString *)kind {
    CGSize size = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForSupplementaryViewInSection:kind:)]) {
        size = [self.delegate collectionView:self.collectionView layout:self sizeForSupplementaryViewInSection:section kind:kind];
    }
    return size;
}

- (void)loadSectionHeaderAttributesInSection:(NSUInteger)section {
    CGFloat yOffset = 0.f;
    
    if(section > 0) {
        NSUInteger longestColumnIndex = [self longestColumnIndexInSection:section-1];
        yOffset = [(self.columnHeights[section-1][longestColumnIndex]) floatValue] + [self insetsForSection:section-1].bottom;
        NSMutableDictionary *previousSectionSupplementaryViewsAttibutes = self.supplementaryViewsAttibutes[section-1];
        UICollectionViewLayoutAttributes *footerAttributes = [previousSectionSupplementaryViewsAttibutes objectForKey:UICollectionElementKindSectionFooter];
        if (footerAttributes) {
            yOffset += footerAttributes.frame.size.height;
        }
    }
    
    CGSize sectionHeaderSize = [self headerSizeInSection:section kind:UICollectionElementKindSectionHeader];
    if (!CGSizeEqualToSize(sectionHeaderSize, CGSizeZero)) {
        UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        headerAttributes.frame = CGRectMake(0, yOffset, sectionHeaderSize.width, sectionHeaderSize.height);
        headerAttributes.zIndex = 1;
        NSMutableDictionary *sectionSupplementaryViewsAttributes = self.supplementaryViewsAttibutes[section];
        [sectionSupplementaryViewsAttributes setObject:headerAttributes forKey:UICollectionElementKindSectionHeader];
    }
}

- (CGSize)sectionHeaderSizeInSection:(NSUInteger)section {
    CGSize headerSize=CGSizeZero;
    NSMutableDictionary *sectionSupplementaryViewsAttributes = self.supplementaryViewsAttibutes[section];
    if ([sectionSupplementaryViewsAttributes objectForKey:UICollectionElementKindSectionHeader]) {
        UICollectionViewLayoutAttributes *headerAttributes = [sectionSupplementaryViewsAttributes objectForKey:UICollectionElementKindSectionHeader];
        headerSize = headerAttributes.frame.size;
    }
    return headerSize;
}

- (CGFloat)verticalOffsetForItemAtColumn:(NSUInteger)columnIndex section:(NSUInteger)section sectionInset:(UIEdgeInsets)sectionInset itemSpacing:(CGFloat)itemSpacing {
    CGFloat initialOffsetY = 0.f;
    CGFloat yOffset = [(self.columnHeights[section][columnIndex]) floatValue];
    if (yOffset == initialOffsetY) {
        if(section > 0) {
            NSUInteger longestColumnIndex = [self longestColumnIndexInSection:section-1];
            yOffset = [(self.columnHeights[section-1][longestColumnIndex]) floatValue] + [self insetsForSection:section-1].bottom;
            NSMutableDictionary *previousSectionSupplementaryViewsAttibutes = self.supplementaryViewsAttibutes[section-1];
            UICollectionViewLayoutAttributes *footerAttributes = [previousSectionSupplementaryViewsAttibutes objectForKey:UICollectionElementKindSectionFooter];
            if (footerAttributes) {
                yOffset += footerAttributes.frame.size.height;
            }
        }
        yOffset += sectionInset.top;
        yOffset += [self sectionHeaderSizeInSection:section].height;
        return yOffset;
    }
    
    yOffset += itemSpacing;
    
    return yOffset;
}

- (CGFloat)itemHeightWithItemWidth:(CGFloat)itemWidth AtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemHeight=0.0;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:aspectRatioForIndexPath:)]) {
        itemHeight = floorf(itemWidth/[self.delegate collectionView:self.collectionView layout:self aspectRatioForIndexPath:indexPath]);
    }else if([self.delegate respondsToSelector:@selector(collectionView:layout:heightItemAtIndexPath:)]){
        itemHeight = floorf([self.delegate collectionView:self.collectionView layout:self heightItemAtIndexPath:indexPath]);
    }else if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightItemAtIndexPath:withWidth:)]){
        itemHeight = floorf([self.delegate collectionView:self.collectionView layout:self heightItemAtIndexPath:indexPath withWidth:itemWidth]);
    }else{
        NSAssert(NO, @"YH_WaterFallFlowLayout : At least one of collectionView:layout:heightItemAtIndexPath: or collectionView:layout:aspectRatioForIndexPath: methods must be implemented by the layout delegate");
    }
    return itemHeight;
}

- (void)loadSectionFooterAttributesInSection:(NSUInteger)section {
    CGSize sectionFooterSize=[self headerSizeInSection:section kind:UICollectionElementKindSectionFooter];
    if (!CGSizeEqualToSize(sectionFooterSize, CGSizeZero)) {
        NSUInteger columnIndex = [self longestColumnIndexInSection:section];
        CGFloat height = [self.columnHeights[section][columnIndex] floatValue];
        UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        footerAttributes.frame = CGRectMake(0, height+[self insetsForSection:section].bottom, sectionFooterSize.width, sectionFooterSize.height);
        footerAttributes.zIndex = 1;
        NSMutableDictionary *sectionSupplementaryViewsAttributes = self.supplementaryViewsAttibutes[section];
        [sectionSupplementaryViewsAttributes setObject:footerAttributes forKey:UICollectionElementKindSectionFooter];
    }
}

- (void)calculateItemsGeometryInSection:(NSUInteger)section {
    
    // 获取有多少列
    NSUInteger columnCountInSection = [self.delegate collectionView:self.collectionView layout:self numberOfColumnsInSection:section];
    
    if(columnCountInSection) {
        
        UIEdgeInsets sectionInset = [self insetsForSection:section];
        CGFloat itemSpacing = [self itemSpacingInSection:section];
        CGFloat itemWidth = floorf((self.collectionView.bounds.size.width-sectionInset.left-sectionInset.right-((columnCountInSection-1)*itemSpacing))/(CGFloat)columnCountInSection);
        NSInteger sectionItemsCount = [[self collectionView] numberOfItemsInSection:section];
        
        self.itemAttributes[section] = [NSMutableArray arrayWithCapacity:sectionItemsCount];
        self.columnHeights[section] = [NSMutableArray arrayWithCapacity:columnCountInSection];
        
        for (NSInteger idx = 0; idx < columnCountInSection; idx++) {
            [self.columnHeights[section] addObject:@(0)];
        }
        
        self.supplementaryViewsAttibutes[section] = [NSMutableDictionary dictionary];
        
        [self loadSectionHeaderAttributesInSection:section];
        
        if (sectionItemsCount == 0) {
            for (NSInteger idx = 0; idx < columnCountInSection; idx++) {
                CGFloat yOffset = [self verticalOffsetForItemAtColumn:idx section:section sectionInset:sectionInset itemSpacing:itemSpacing];
                self.columnHeights[section][idx] = @(yOffset);
            }
        } else {
            for (NSInteger idx = 0; idx < sectionItemsCount; idx++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
                CGFloat itemHeight = [self itemHeightWithItemWidth:itemWidth AtIndexPath:indexPath];
                NSUInteger columnIndex = [self shortestColumnIndexInSection:section];
                CGFloat xOffset = sectionInset.left + ((itemWidth + itemSpacing) * columnIndex);
                CGFloat yOffset = [self verticalOffsetForItemAtColumn:columnIndex section:section sectionInset:sectionInset itemSpacing:itemSpacing];
                UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
                attributes.zIndex = 1;
                [self.itemAttributes[section] addObject:attributes];
                self.columnHeights[section][columnIndex] = @(yOffset + itemHeight);
            }
        }
        
        [self loadSectionFooterAttributesInSection:section];
    }
}

- (BOOL)shouldStickHeaderToTopInSection:(NSUInteger)section {
    if ([self.collectionView.delegate respondsToSelector:@selector(shouldStickHeaderToTopInSection:)]) {
        return [((id<YH_WaterFallFlowLayoutDelegate>)self.collectionView.delegate) shouldStickHeaderToTopInSection:section];
    }
    return NO;
}

- (void)addVisibleItemAttributesToLayoutAttributes:(NSMutableArray *)attributes inRect:(CGRect)rect {
    for (NSArray *itemAttributesArray in self.itemAttributes) {
        NSArray *filteredAttributes = [itemAttributesArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
            return CGRectIntersectsRect(rect, [evaluatedObject frame]);
        }]];
        [attributes addObjectsFromArray:filteredAttributes];
    }
}

- (void)addVisibleSupplementaryViewsAttributesToLayoutAttributes:(NSMutableArray *)attributes inRect:(CGRect)rect {
    for (NSDictionary *itemAttributesArray in self.supplementaryViewsAttibutes) {
        if (itemAttributesArray) {
            NSArray *filteredAttributes = [[itemAttributesArray allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
                return CGRectIntersectsRect(rect, [evaluatedObject frame]);
            }]];
            [attributes addObjectsFromArray:filteredAttributes];
        }
    }
}

- (void)addVisibleHeadersToLayoutAttributes:(NSMutableArray *)attributes fromVisibleSectionsWithoutHeader:(NSArray *)visibleSectionsWithoutHeader {
    for (NSNumber *sectionNumber in visibleSectionsWithoutHeader) {
        if ([self shouldStickHeaderToTopInSection:[sectionNumber integerValue]]) {
            UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:[sectionNumber integerValue]]];
            if (headerAttributes.frame.size.width>0 && headerAttributes.frame.size.height>0) {
                [attributes addObject:headerAttributes];
            }
        }
    }
}

- (NSArray *)visibleSectionsWithoutHeaderInAttributes:(NSArray *)attributes {
    NSMutableArray *visibleSectionsWithoutHeader = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *itemAttributes in attributes) {
        if (![visibleSectionsWithoutHeader containsObject:[NSNumber numberWithInteger:itemAttributes.indexPath.section]]) {
            [visibleSectionsWithoutHeader addObject:[NSNumber numberWithInteger:itemAttributes.indexPath.section]];
        }
        if (itemAttributes.representedElementKind == UICollectionElementKindSectionHeader) {
            NSUInteger indexOfSectionObject = [visibleSectionsWithoutHeader indexOfObject:[NSNumber numberWithInteger:itemAttributes.indexPath.section]];
            if (indexOfSectionObject != NSNotFound) {
                [visibleSectionsWithoutHeader removeObjectAtIndex:indexOfSectionObject];
            }
        }
    }
    return visibleSectionsWithoutHeader;
}

- (CGRect)correctStickedHeaderFrame:(CGRect)frame relativeToContentOffsetWithHeaderAttributes:(UICollectionViewLayoutAttributes *)headerAttributes {
    CGPoint contentOffset = self.collectionView.contentOffset;
    CGPoint originInCollectionView = CGPointMake(headerAttributes.frame.origin.x-contentOffset.x, headerAttributes.frame.origin.y-contentOffset.y);
    originInCollectionView.y -= self.collectionView.contentInset.top;
    if (originInCollectionView.y < 0) {
        frame.origin.y += (originInCollectionView.y*-1);
    }
    return frame;
}

- (CGRect)correctStickedHeaderFrame:(CGRect)frame relativeToNextSectionHeaderWithHeaderAttributes:(UICollectionViewLayoutAttributes *)headerAttributes {
    NSUInteger numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    if (numberOfSections > headerAttributes.indexPath.section+1) {
        UICollectionViewLayoutAttributes *nextHeaderAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:headerAttributes.indexPath.section+1]];
        CGFloat maxY = nextHeaderAttributes.frame.origin.y;
        if (CGRectGetMaxY(frame) >= maxY) {
            frame.origin.y = maxY-frame.size.height;
        }
    }
    return frame;
}

- (CGRect)correctStickedHeaderFrame:(CGRect)frame relativeToSameSectionFooterWithHeaderAttributes:(UICollectionViewLayoutAttributes *)headerAttributes{
    UICollectionViewLayoutAttributes *sameSectionFooterAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:headerAttributes.indexPath.section]];
    if (sameSectionFooterAttributes) {
        CGFloat maxY = sameSectionFooterAttributes.frame.origin.y;
        if (CGRectGetMaxY(frame) >= maxY) {
            frame.origin.y = maxY-frame.size.height;
        }
    }
    return frame;
}

- (CGRect)correctStickedHeaderFrame:(CGRect)frame relativeToBottomLimitInSameSectionWithHeaderAttributes:(UICollectionViewLayoutAttributes *)headerAttributes{
    NSUInteger longestColumnIndex = [self longestColumnIndexInSection:headerAttributes.indexPath.section];
    CGFloat maxYOffsetInSection = [(self.columnHeights[headerAttributes.indexPath.section][longestColumnIndex]) floatValue] + [self insetsForSection:headerAttributes.indexPath.section].bottom;
    if (CGRectGetMaxY(frame) >= maxYOffsetInSection) {
        frame.origin.y = maxYOffsetInSection-frame.size.height;
    }
    return frame;
}

- (void)updateStickedHeadersAttributesInLayoutAttributes:(NSMutableArray *)attributes {
    
    for (UICollectionViewLayoutAttributes *itemAttributes in attributes) {
        if (itemAttributes.representedElementKind == UICollectionElementKindSectionHeader) {
            UICollectionViewLayoutAttributes *headerAttributes = itemAttributes;
            if ([self shouldStickHeaderToTopInSection:headerAttributes.indexPath.section]) {
                CGRect frame = headerAttributes.frame;
                frame = [self correctStickedHeaderFrame:frame relativeToContentOffsetWithHeaderAttributes:headerAttributes];
                frame = [self correctStickedHeaderFrame:frame relativeToSameSectionFooterWithHeaderAttributes:headerAttributes];
                frame = [self correctStickedHeaderFrame:frame relativeToNextSectionHeaderWithHeaderAttributes:headerAttributes];
                frame = [self correctStickedHeaderFrame:frame relativeToBottomLimitInSameSectionWithHeaderAttributes:headerAttributes];
                
                headerAttributes.frame = frame;
            }
            headerAttributes.zIndex = 1024;
        }
    }
}

#pragma mark - Public
- (void)notifyCollectionViewRelayoutAnimated:(BOOL)animated {
    
    if (animated) {
    
        [self.collectionView performBatchUpdates:^{
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionView setCollectionViewLayout:self.collectionView.collectionViewLayout animated:YES];
            
        } completion:^(BOOL finished) {
        }];
    } else {
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:self.collectionView.collectionViewLayout animated:NO];
    }
}

@end

#pragma mark - UICollectionView(YH_WaterFallFlowLayout)

@implementation UICollectionView (YH_WaterFallFlowLayout)


@end
