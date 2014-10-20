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

#import "THAudioMixCompositionBuilder.h"
#import "THAudioItem.h"
#import "THVolumeAutomation.h"
#import "THAudioMixComposition.h"
#import "THFunctions.h"

@interface THAudioMixCompositionBuilder ()
@property (strong, nonatomic) THTimeline *timeline;
@property (strong, nonatomic) AVMutableComposition *composition;
@end

@implementation THAudioMixCompositionBuilder

- (id)initWithTimeline:(THTimeline *)timeline {
    self = [super init];
    if (self) {
        _timeline = timeline;
    }
    return self;
}

- (id <THComposition>)buildComposition {

    // Listing 10.4

    return nil;
}

- (AVAudioMix *)buildAudioMixWithTrack:(AVCompositionTrack *)track {

    // Listing 10.5

    return nil;
}

- (AVMutableCompositionTrack *)addCompositionTrackOfType:(NSString *)type   // 5
                                          withMediaItems:(NSArray *)mediaItems {

    if (!THIsEmpty(mediaItems)) {

        CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;

        AVMutableCompositionTrack *compositionTrack =
            [self.composition addMutableTrackWithMediaType:type
                                          preferredTrackID:trackID];
        // Set insert cursor to 0
        CMTime cursorTime = kCMTimeZero;

        for (THMediaItem *item in mediaItems) {

            if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline,
                                      !=,
                                      kCMTimeInvalid)) {
                cursorTime = item.startTimeInTimeline;
            }

            AVAssetTrack *assetTrack =
                [[item.asset tracksWithMediaType:type] firstObject];

            [compositionTrack insertTimeRange:item.timeRange
                                      ofTrack:assetTrack
                                       atTime:cursorTime
                                        error:nil];

            // Move cursor to next item time
            cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
        }

        return compositionTrack;
    }

    return nil;
}

@end
