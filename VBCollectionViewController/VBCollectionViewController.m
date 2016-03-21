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
    
    self.delegateInterceptor = [[WZProtocolInterceptor alloc] initWithInterceptedProtocol:@protocol(VBCollectionViewDelegate)];
    self.delegateInterceptor.middleMan = self;
    self.delegateInterceptor.receiver = delegate;
    
    self.collectionView.delegate = (id<UICollectionViewDelegate>)self.delegateInterceptor;
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
        if (((UICollectionViewFlowLayout*)self.collectionViewLayout).scrollDirection == UICollectionViewScrollDirectionVertical) {
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
        [self.dataSource numberOfSectionsInCollectionView:collectionView];
    }
    self.numOfSections = numOfSections;
    return numOfSections;
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
               forCellWithReuseIdentifier:footerPaginationReuseIdentifier];
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
