//
//    The MIT License (MIT)
//
//    Copyright (c) 2016 Valeriy Bezuglyy.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

#import "VBCollectionViewController.h"

#import <WZProtocolInterceptor/WZProtocolInterceptor.h>

#import "VBCollectionViewCell.h"
#import "VBCollectionViewHeader.h"

@interface VBCollectionViewController ()

@property (nonatomic, strong) WZProtocolInterceptor* delegateInterceptor;

@property (nonatomic, strong) WZProtocolInterceptor* dataSourceInterceptor;
@property (nonatomic, assign) NSInteger numOfSections;

@property (nonatomic, strong) UIRefreshControl* p2rControl;

@end

@implementation VBCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
}

#pragma mark - dataSource/delegate
- (void) setDataSource:(id<VBCollectionViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    self.dataSourceInterceptor = [[WZProtocolInterceptor alloc] initWithInterceptedProtocol:@protocol(VBCollectionViewDataSource)];
    self.dataSourceInterceptor.middleMan = self;
    self.dataSourceInterceptor.receiver = dataSource;
    
    self.collectionView.dataSource = (id<UICollectionViewDataSource>)self.dataSourceInterceptor;
}
- (void) setDelegate:(id<VBCollectionViewDelegate>)delegate {
    _delegate = delegate;
    
    self.delegateInterceptor = [[WZProtocolInterceptor alloc] initWithInterceptedProtocols:@protocol(VBCollectionViewDelegate), @protocol(UICollectionViewDelegateFlowLayout), nil];
    self.delegateInterceptor.middleMan = self;
    self.delegateInterceptor.receiver = delegate;
    
    self.collectionView.delegate = (id<UICollectionViewDelegate>)self.delegateInterceptor;
}

#pragma mark - flow layout
/**
 * Fast creation.
 */
+ (instancetype) collectionFlowLayout {
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    return [[self alloc] initWithCollectionViewLayout:layout];
}

/**
 * Layout cast.
 */
- (UICollectionViewFlowLayout*) flowLayout {
    return (UICollectionViewFlowLayout*)self.collectionViewLayout;
}

#pragma mark - collection
- (void) registerClassesForCells:(NSArray<Class>*) classesToRegister {
    __weak typeof(self) __self = self;
    [classesToRegister enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [__self registerClassForCell:obj];
    }];
}
- (void) registerClassForCell:(Class) classToRegister {
    if ([classToRegister isSubclassOfClass:[VBCollectionViewCell class]]) {
        [self.collectionView registerClass:classToRegister
                forCellWithReuseIdentifier:[classToRegister reuseIdentifier]];
    }else{
        [self.collectionView registerClass:classToRegister
                    forCellReuseIdentifier:NSStringFromClass(classToRegister)];
    }
}

- (void) registerClassesForSupplementaryViews:(NSArray<Class>*) classesToRegister {
    __weak typeof(self) __self = self;
    [classesToRegister enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [__self registerClassForSupplementaryView:obj];
    }];
}
- (void) registerClassForSupplementaryView:(Class) classToRegister {
    if ([classToRegister isSubclassOfClass:[VBCollectionViewHeader class]]) {
        [self.collectionView registerClass:classToRegister
                forSupplementaryViewOfKind:[classToRegister kindOfView]
                       withReuseIdentifier:[classToRegister reuseIdentifier]];
    }else{
        [self.collectionView registerClass:classToRegister
                forSupplementaryViewOfKind:[VBCollectionViewHeader kindOfView]
                       withReuseIdentifier:NSStringFromClass(classToRegister)];
    }
}

#pragma mark - pullToRefresh
- (void) setPullToRefreshEnabled:(BOOL)pullToRefreshEnabled {
    _pullToRefreshEnabled = pullToRefreshEnabled;
    
    if (_pullToRefreshEnabled) {
        UIRefreshControl* p2rCtrl = [UIRefreshControl new];
        [p2rCtrl addTarget:self
                    action:@selector(pullToRefreshEvent:)
          forControlEvents:UIControlEventValueChanged];
        self.p2rControl = p2rCtrl;
        [self.collectionView addSubview:self.p2rControl];
        
    }else{
        [self.p2rControl removeFromSuperview];
        self.p2rControl = nil;
    }
}

- (void) pullToRefreshEvent:(id)sender {
    if ([self.delegate respondsToSelector:@selector(collectionViewDidStartPullToRefresh:)]) {
        [self.delegate collectionViewDidStartPullToRefresh:self.collectionView];
    }
}

- (void) beginPullToRefresh {
    [self.p2rControl beginRefreshing];
}
- (void) endPullToRefresh {
    [self.p2rControl endRefreshing];
}

#pragma mark - pagination
- (void) setPaginationEnabled:(BOOL)paginationEnabled {
    if ([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        _paginationEnabled = paginationEnabled;
        [self.collectionView reloadData];
    }
    else{
        _paginationEnabled = NO;
    }
}

- (void) paginationOffsetCheck:(CGPoint)contentOffset {
    BOOL nextPage = NO;
    if (self.paginationEnabled &&
        self.paginationIsLoadingNextPage == NO) {
        if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionVertical) {
            nextPage = [self contentOffsetYAtBottom:contentOffset.y];
        }
        else{
            nextPage = [self contentOffsetXAtRight:contentOffset.x];
        }
    }
    
    if (nextPage) {
        if ([self.delegate respondsToSelector:@selector(collectionViewDidScrollToNextPage:)]) {
            [self.delegate collectionViewDidScrollToNextPage:self.collectionView];
        }
    }
}
- (BOOL) contentOffsetYAtBottom:(CGFloat)contentOffsetY {
    double collectionHeight = self.collectionView.bounds.size.height;
    double bottomOffset = self.collectionView.contentSize.height - collectionHeight - contentOffsetY;
    return bottomOffset <= (collectionHeight / 4.0f);
}
- (BOOL) contentOffsetXAtRight:(CGFloat)contentOffsetX {
    double collectionWidth = self.collectionView.bounds.size.width;
    double rightOffset = self.collectionView.contentSize.width - collectionWidth - contentOffsetX;
    return rightOffset <= (collectionWidth / 2.0f);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numOfSections = 1;
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        numOfSections = [self.dataSource numberOfSectionsInCollectionView:collectionView];
    }
    self.numOfSections = numOfSections;
    return numOfSections;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView
      numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource collectionView:collectionView
                    numberOfItemsInSection:section];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource collectionView:collectionView
                    cellForItemAtIndexPath:indexPath];
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView
            viewForSupplementaryElementOfKind:(NSString *)kind
                                  atIndexPath:(NSIndexPath *)indexPath {
    if (self.paginationEnabled &&
        indexPath.section == (self.numOfSections - 1) &&
        [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        UICollectionReusableView* footerPagination = nil;
        NSString* footerPaginationReuseIdentifier = @"footerPaginationReuseIdentifier";
        @try {
            footerPagination = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                  withReuseIdentifier:footerPaginationReuseIdentifier
                                                                         forIndexPath:indexPath];
        }
        @catch (NSException *exception) {
            [collectionView registerClass:[UICollectionReusableView class]
               forSupplementaryViewOfKind:kind
                      withReuseIdentifier:footerPaginationReuseIdentifier];
            footerPagination = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                  withReuseIdentifier:footerPaginationReuseIdentifier
                                                                         forIndexPath:indexPath];
            footerPagination.backgroundColor = [UIColor clearColor];
            
            UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [aiv startAnimating];
            [footerPagination addSubview:aiv];
            aiv.center = CGPointMake(footerPagination.bounds.size.width / 2, footerPagination.bounds.size.height / 2);
        }
        return footerPagination;
    }
    else{
        if ([self.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
            return [self.dataSource collectionView:collectionView
                 viewForSupplementaryElementOfKind:kind
                                       atIndexPath:indexPath];
        }
    }
    return nil;
}

- (CGSize) collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    if (self.paginationEnabled &&
        section == (self.numOfSections - 1)) {
        return CGSizeMake(self.collectionView.bounds.size.width, 44);
    }
    else if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        return [self.delegate collectionView:collectionView
                                      layout:collectionViewLayout
             referenceSizeForFooterInSection:section];
    }
    return CGSizeZero;
}

#pragma mark - UICollectionViewDelegate
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self paginationOffsetCheck:scrollView.contentOffset];

    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView
                   willDecelerate:(BOOL)decelerate {
    [self paginationOffsetCheck:scrollView.contentOffset];
    
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView
                                 willDecelerate:decelerate];
    }
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView
                      withVelocity:(CGPoint)velocity
               targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self paginationOffsetCheck:CGPointMake(targetContentOffset->x,
                                            targetContentOffset->y)];
    
    if ([self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView
                                    withVelocity:velocity
                             targetContentOffset:targetContentOffset];
    }
}

@end
