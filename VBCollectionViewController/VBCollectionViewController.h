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

#import <UIKit/UIKit.h>

@protocol VBCollectionViewDataSource <UICollectionViewDataSource>

@end

@protocol VBCollectionViewDelegate <UICollectionViewDelegate>

@optional
- (void) collectionViewDidScrollToNextPage:(UITableView*)tableView;
//- (void) collectionViewDidStartPullToRefresh:(UITableView*)tableView;

@end

/**
 *  VBCollectionViewController extends UICollectionViewController by adding pagination, pull-to-refresh and other useful features.
 */
@interface VBCollectionViewController : UICollectionViewController

/**
 * Use this dataSource property instead of collectionView.dataSource
 */
@property (nonatomic, weak) id<VBCollectionViewDataSource> dataSource;

/**
 * Use this delegate property instead of collectionView.delegate
 */
@property (nonatomic, weak) id<VBCollectionViewDelegate> delegate;

#pragma mark - collection
/**
 * A short version of "register class for reuse identifier".
 * Calls +reuseIdetifier if classToRegister is a subclass of VBCollectionViewCell.
 * Else - uses stringFromClass as identifier.
 */
- (void) registerClassForCell:(Class) classToRegister;

/**
 * Register several classes at once.
 */
- (void) registerClassesForCells:(NSArray<Class>*) classesToRegister;

/**
 * A short version of "register class for reuse identifier".
 * Calls +reuseIdetifier if classToRegister is a subclass of VBCollectionSupplementaryView.
 * Else - uses stringFromClass as identifier.
 */
- (void) registerClassForSupplementaryView:(Class) classToRegister;

/**
 * Register several classes at once.
 */
- (void) registerClassesForSupplementaryViews:(NSArray<Class>*) classesToRegister;

#pragma mark - pagination
/**
 * If pagination is enabled, activity indicator will be used as tableFooterView. Delegate will be notified with <i>-tableViewDidScrollToNextPage:</i>
 */
@property (nonatomic, assign) BOOL paginationEnabled;

/**
 * Setting this property to YES blocks delegate calls, but do not hide activity indicator.
 */
@property (nonatomic, assign) BOOL paginationIsLoadingNextPage;

@end
