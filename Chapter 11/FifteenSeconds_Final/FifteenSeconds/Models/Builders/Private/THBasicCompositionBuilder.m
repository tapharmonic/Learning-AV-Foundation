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

#import "THBasicCompositionBuilder.h"
#import "THBasicComposition.h"
#import "THFunctions.h"

@interface THBasicCompositionBuilder ()
@property (strong, nonatomic) THTimeline *timeline;
@property (strong, nonatomic) AVMutableComposition *composition;
@end

@implementation THBasicCompositionBuilder

- (id)initWithTimeline:(THTimeline *)timeline {
    self = [super init];
    if (self) {
        _timeline = timeline;
    }
    return self;
}

- (id <THComposition>)buildComposition {

    self.composition = [AVMutableComposition composition];                  // 1

    [self addCompositionTrackOfType:AVMediaTypeVideo
                     withMediaItems:self.timeline.videos];

    [self addCompositionTrackOfType:AVMediaTypeAudio
                     withMediaItems:self.timeline.voiceOvers];

    [self addCompositionTrackOfType:AVMediaTypeAudio
                     withMediaItems:self.timeline.musicItems];

    // Create and return the basic composition                              // 2
    return [THBasicComposition compositionWithComposition:self.composition];
}

- (void)addCompositionTrackOfType:(NSString *)mediaType
                   withMediaItems:(NSArray *)mediaItems {

    if (!THIsEmpty(mediaItems)) {                                           // 1

        CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;

        AVMutableCompositionTrack *compositionTrack =                       // 2
            [self.composition addMutableTrackWithMediaType:mediaType
                                          preferredTrackID:trackID];
        // Set insert cursor to 0
        CMTime cursorTime = kCMTimeZero;                                    // 3

        for (THMediaItem *item in mediaItems) {

            if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline,             // 4
            !=,
            kCMTimeInvalid)) {
                cursorTime = item.startTimeInTimeline;
            }

            AVAssetTrack *assetTrack =                                      // 5
                [[item.asset tracksWithMediaType:mediaType] firstObject];

            [compositionTrack insertTimeRange:item.timeRange                // 6
                                      ofTrack:assetTrack
                                       atTime:cursorTime
                                        error:nil];

            // Move cursor to next item time
            cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);    // 7
        }
    }
}

@end
