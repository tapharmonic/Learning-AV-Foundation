//
//  MIT License
//
//  Copyright (c) 2015 Bob McCune http://bobmccune.com/
//  Copyright (c) 2015 TapHarmonic, LLC http://tapharmonic.com/
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
//

#import "NSString+THAdditions.h"

@implementation NSString (THAdditions)

- (NSString *)stringByMatchingRegex:(NSString *)regex capture:(NSUInteger)capture {
	NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
	NSTextCheckingResult *result = [expression firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
	if (capture < [result numberOfRanges]) {
		NSRange range = [result rangeAtIndex:capture];
		return [self substringWithRange:range];
	}
	return nil;
}

- (BOOL)containsString:(NSString *)substring {
	NSRange range = [self rangeOfString:substring];
	return range.location != NSNotFound;
}

@end
