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

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

int main(int argc, const char * argv[]) {

    /*
     * Using CMTime
     *
     * Here are a few challenges to help you learn how to use CMTime. Open CMTime.h for
     * more details on the available functions, macros, and constants. As with most of Apple's
     * lower-level C libraries, the best comments are usually found in the headers.
     */
    printf("----- Using CMTime -----\n\n");
    // Making Time
    CMTime t1 = CMTimeMake(300, 100); // 3 seconds
    CMTime t2 = CMTimeMakeWithSeconds(5, 1); // 5 seconds
    NSDictionary *timeData = @{(id)kCMTimeValueKey : @2,
                               (id)kCMTimeScaleKey : @1,
                               (id)kCMTimeFlagsKey : @1,
                               (id)kCMTimeEpochKey : @0};
    CMTime t3 = CMTimeMakeFromDictionary((__bridge CFDictionaryRef)timeData); // 2 seconds

    CMTimeShow(t1);
    CMTimeShow(t2);
    CMTimeShow(t3);

    // Adding and Subtracting times
    // 1) Create a new time equal to 8 seconds using the time values above and the CMTimeAdd function.
    // 2) Create a new time equal to 1 second using the time values above and the CMTimeSubtract function.

    // Using Macros
    // Experiment using the various macros defined in CMTime.h.
    // Here's an example to get you started.
    printf("Is t1 greater than t2? %s\n", CMTIME_COMPARE_INLINE(t1, >, t2) ? "YES" : "NO");

    // Using Contants
    // CMTime.h defines a number of useful constants such as kCMTimeZero and kCMTimeInvalid
    // 1) Print these constants to the console using the CMTimeShow function
    // 2) Use the macros CMTIME_IS_VALID and CMTIME_IS_INVALID to test their values.
    printf("Is kCMTimeZero a valid time? %s\n", CMTIME_IS_VALID(kCMTimeZero) ? "YES" : "NO");


    /*
     * Using CMTimeRange
     *
     * Here are a few challenges to help you learn how to use CMTimeRange. Open CMTimeRange.h for
     * more details on the available functions, macros, and constants. As with most of Apple's
     * lower-level C libraries, the best comments are usually found in the headers.
     */
    printf("\n----- Using CMTimeRange -----\n");
    // Create 3 time ranges with equal durations, but with staggered start times
    //
    //  _________________
    // |_________________|
    //      _________________
    //     |_________________|
    //           _________________
    //          |_________________|
    //

    CMTime duration = CMTimeMake(5, 1);
    CMTimeRange range1 = CMTimeRangeMake(kCMTimeZero, duration);
    CMTimeRange range2 = CMTimeRangeMake(CMTimeMake(2, 1), duration);
    CMTimeRange range3 = CMTimeRangeMake(CMTimeMake(4, 1), duration);

    CMTimeRangeShow(range1);
    CMTimeRangeShow(range2);
    CMTimeRangeShow(range3);

    // Finding Unions and Intersections
    // Use the CMTimeRangeGetUnion and CMTimeRangeGetIntersection
    // 1) Get a union of range1 and range3
    // 2) Use the CMTimeRangeContainsTimeRange on the union from step 1 to determine if it contains range2




    /*
     * Structs -> Objects -> Structs
     *
     * You'll encounter certain cases where you need to represent a time or time range as an
     * object type. Likewise, you typically need to convert them back to struct form. The following
     * examples show you the options at your disposal.
     */
    printf("\n----- Structs -> Objects -> Structs -----\n");
    
    @autoreleasepool {

        // AVFoundation provides a category on NSValue (see AVTime.h) to convert to and from NSValue instances.

        printf("\n>>> Struct -> NSValue -> Struct\n");
        // CMTime
        CMTime structTime = CMTimeMake(1, 3);

        NSValue *valueTime = [NSValue valueWithCMTime:structTime];
        NSLog(@"%@", valueTime);

        structTime = [valueTime CMTimeValue];
        CMTimeShow(structTime);

        printf("\n");

        // CMTimeRange
        CMTimeRange structTimeRange = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);

        NSValue *valueTimeRange = [NSValue valueWithCMTimeRange:structTimeRange];
        NSLog(@"%@", valueTimeRange);

        structTimeRange = [valueTimeRange CMTimeRangeValue];
        CMTimeRangeShow(structTimeRange);

        printf("\n>>> Struct -> Dictionary -> Struct\n");

        // Additionally, both CMTime and CMTimeRange can be converted to and from CFDictionaryRefs

        // CMTime
        NSDictionary *timeDict = CFBridgingRelease(CMTimeCopyAsDictionary(structTime, NULL));
        NSLog(@"%@", timeDict);

        structTime = CMTimeMakeFromDictionary((__bridge CFDictionaryRef)(timeDict));
        CMTimeShow(structTime);

        // CMTimeRange
        NSDictionary *timeRangeDict = CFBridgingRelease(CMTimeRangeCopyAsDictionary(structTimeRange, NULL));
        NSLog(@"%@", timeRangeDict);

        structTimeRange = CMTimeRangeMakeFromDictionary((__bridge CFDictionaryRef)(timeRangeDict));
        CMTimeRangeShow(structTimeRange);

    }


    return 0;
}

