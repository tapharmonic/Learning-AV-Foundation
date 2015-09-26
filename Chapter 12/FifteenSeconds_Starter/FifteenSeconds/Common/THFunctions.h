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

#import "THConstants.h"

#ifndef FifteenSeconds_Starter_THFunctions_h
#define FifteenSeconds_Starter_THFunctions_h

static inline BOOL THIsEmpty(id value) {
    return value == nil ||
    value == [NSNull null] ||
    ([value isKindOfClass:[NSString class]] && [value length] == 0) ||
    ([value respondsToSelector:@selector(count)] && [value count] == 0);
}

static inline CGFloat THGetWidthForTimeRange(CMTimeRange timeRange, CGFloat scaleFactor) {
    return CMTimeGetSeconds(timeRange.duration) * scaleFactor;
}

static inline CGPoint THGetOriginForTime(CMTime time) {
    if (CMTIME_IS_VALID(time)) {
        CGFloat seconds = CMTimeGetSeconds(time);
        return CGPointMake(seconds * (THTimelineWidth / THTimelineSeconds), 0);
    }
    return CGPointZero;
}

static inline CMTimeRange THGetTimeRangeForWidth(CGFloat width, CGFloat scaleFactor) {
    CGFloat duration = width / scaleFactor;
    return CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(duration, NSEC_PER_SEC));
}

static inline CMTime THGetTimeForOrigin(CGFloat origin, CGFloat scaleFactor) {
    CGFloat seconds = origin / scaleFactor;
    return CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC);
}

static inline CGFloat THDegreesToRadians(CGFloat degrees) {
    return (degrees * M_PI / 180);
}

#endif
