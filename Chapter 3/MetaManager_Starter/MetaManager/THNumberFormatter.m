//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THNumberFormatter.h"

@interface THNumberFormatter ()
@property (strong) NSCharacterSet *digitSet;
@end

@implementation THNumberFormatter

- (id)init {
    self = [super init];
    if (self) {
        _digitSet = [NSCharacterSet decimalDigitCharacterSet];
    }
    return self;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error {

    BOOL isValid = [super isPartialStringValid:partialStringPtr
                         proposedSelectedRange:proposedSelRangePtr
                                originalString:origString
                         originalSelectedRange:origSelRange
                              errorDescription:error];
    if (isValid) {
        NSCharacterSet *partialSet =
            [NSCharacterSet characterSetWithCharactersInString:*partialStringPtr];
        if (![self.digitSet isSupersetOfSet:partialSet]) {
            return NO;
        }
    }
    return isValid;
}

@end
