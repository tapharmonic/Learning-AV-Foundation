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

#import "THChapter.h"

@interface THChapter ()
@property CMTime time;
@property NSUInteger number;
@property (copy) NSString *title;
@end

@implementation THChapter

+ (instancetype)chapterWithTime:(CMTime)time
                         number:(NSUInteger)number
                          title:(NSString *)title {
    return [[THChapter alloc] initWithTime:time number:number title:title];
}

- (id)initWithTime:(CMTime)time
            number:(NSUInteger)number
             title:(NSString *)title {
    self = [super init];
    if (self) {
        _time = time;
        _number = number;
        _title = [title copy];
    }
    return self;
}

- (BOOL)isInTimeRange:(CMTimeRange)timeRange {
    return CMTIME_COMPARE_INLINE(_time, >, timeRange.start) &&
            CMTIME_COMPARE_INLINE(_time, <, timeRange.duration);
}

- (BOOL)hasValidTime {
    return CMTIME_IS_VALID(_time);
}

- (NSString *)debugDescription {
    NSString *format = @"time:%@ number:%lu title:%@";
    NSString *strTime = (__bridge NSString *)CMTimeCopyDescription(NULL, _time);
    return [NSString stringWithFormat:format, strTime, _number, _title];
}

@end
