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
#import "VBCollectionViewSupplementaryView.h"

@interface VBCollectionViewController ()

@property (nonatomic, strong) WZProtocolInterceptor* delegateInterceptor;

@end

@implementation VBCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
}

#pragma mark - dataSource/delegate
- (void) setDataSource:(id<VBCollectionViewDataSource>)dataSource {
    _dataSource = dataSource;
    self.collectionView.dataSource = dataSource;
}
- (void) setDelegate:(id<VBCollectionViewDelegate>)delegate {
    _delegate = delegate;
    
    self.delegateInterceptor = [[WZProtocolInterceptor alloc] initWithInterceptedProtocol:@protocol(VBCollectionViewDelegate)];
    self.delegateInterceptor.middleMan = self;
    self.delegateInterceptor.receiver = delegate;
    
    self.collectionView.delegate = (id<UICollectionViewDelegate>)self.delegateInterceptor;
}

#pragma mark - collection
- (void) registerClassForCell:(Class) classToRegister {
    if ([classToRegister isSubclassOfClass:[VBCollectionViewCell class]]) {
        [self.collectionView registerClass:classToRegister
                forCellWithReuseIdentifier:[classToRegister reuseIdentifier]];
    }else{
        [self.collectionView registerClass:classToRegister
                    forCellReuseIdentifier:NSStringFromClass(classToRegister)];
    }
}

- (void) registerClassForSupplementaryView:(Class) classToRegister {
    if ([classToRegister isSubclassOfClass:[VBCollectionViewSupplementaryView class]]) {
        [self.collectionView registerClass:classToRegister
                forSupplementaryViewOfKind:[classToRegister kindOfView]
                       withReuseIdentifier:[classToRegister reuseIdentifier]];
    }else{
        [self.collectionView registerClass:classToRegister
                forSupplementaryViewOfKind:[VBCollectionViewSupplementaryView kindOfView]
                       withReuseIdentifier:NSStringFromClass(classToRegister)];
    }
}

@end
