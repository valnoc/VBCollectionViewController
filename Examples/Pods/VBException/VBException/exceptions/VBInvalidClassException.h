//
//    The MIT License (MIT)
//
//    Copyright (c) 2015 Valeriy Bezuglyy.
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

#import "VBException.h"

#define kVBInvalidClassException_givenClass     @"givenClass"
#define kVBInvalidClassException_expectedClass  @"expectedClass"

/**
 *  Throw VBInvalidClassException when instances of invalid class were passed in code. For example, when array is allowed to contain instances of only one concrete class.
 */
@interface VBInvalidClassException : VBException

/**
 *  Creates exception with additional reason info
 *
 *  @param givenClass Class of given object.
 *  @param expectedClass Expected class.
 *
 *  @return The created exception object or nil if the object couldn't be created.
 */
+ (instancetype) exceptionWithGivenClass:(Class) givenClass
                           expectedClass:(Class) expectedClass;

@end