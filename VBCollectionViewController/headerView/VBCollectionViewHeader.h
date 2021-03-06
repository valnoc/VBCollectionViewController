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

#import "VBCollectionViewHeaderView.h"

/**
 *  VBCollectionViewSupplementaryView is a base class for collection header-footer.
 */
@interface VBCollectionViewHeader : UICollectionReusableView

#pragma mark - reuse identifier
/**
 *  @return Kind of view for reusability.
 */
+ (NSString *) kindOfView;

/**
 *  @return Identifier for reusability.
 */
+ (NSString *) reuseIdentifier;

#pragma mark - itemView
/**
 *  Must be implemented in subclass.
 *  A subclass of VBTableVIewItemView
 *
 *  @return Class
 */
+ (Class) itemViewClass;

/**
 *  Is created automatically using itemViewClass. can be changed at any time.
 */
@property (nonatomic, strong) VBCollectionViewHeaderView* itemView;

#pragma mark - size
+ (CGSize) estimatedSize;

+ (CGSize) estimatedSizeWithItem:(id)item;

@end
