//
//  MIT License
//
//  Copyright (c) 2013 Bob McCune http://bobmccune.com/
//  Copyright (c) 2013 TapHarmonic, LLC http://tapharmonic.com/
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

#import "THTransitionCompositionBuilder.h"
#import "THVideoItem.h"
#import "THAudioItem.h"
#import "THVolumeAutomation.h"
#import "THTransitionComposition.h"
#import "THTransitionInstructions.h"
#import "THFunctions.h"

@interface THTransitionCompositionBuilder ()
@property (strong, nonatomic) THTimeline *timeline;
@property (strong, nonatomic) AVMutableComposition *composition;
@property (weak, nonatomic) AVMutableCompositionTrack *musicTrack;
@end

@implementation THTransitionCompositionBuilder

- (id)initWithTimeline:(THTimeline *)timeline {
    self = [super init];
    if (self) {
        _timeline = timeline;
    }
    return self;
}

- (id <THComposition>)buildComposition {

    self.composition = [AVMutableComposition composition];

    [self buildCompositionTracks];

    AVVideoComposition *videoComposition = [self buildVideoComposition];

    AVAudioMix *audioMix = [self buildAudioMix];

    return [[THTransitionComposition alloc] initWithComposition:self.composition
                                               videoComposition:videoComposition
                                                       audioMix:audioMix];
}

- (void)buildCompositionTracks {

    // Listing 11.5

}

- (AVVideoComposition *)buildVideoComposition {

    // Listing 11.6

    // Listing 11.8

    // Listing 11.9

    // Listing 11.10

    return nil;
}

// Extract the composition and layer instructions out of the
// prebuilt AVVideoComposition. Make the association between the instructions
// and the THVideoTransition the user configured in the timeline.
- (NSArray *)transitionInstructionsInVideoComposition:(AVVideoComposition *)vc {

    // Listing 11.7

    return nil;
}

- (AVMutableCompositionTrack *)addCompositionTrackOfType:(NSString *)mediaType
                                          withMediaItems:(NSArray *)mediaItems {

    AVMutableCompositionTrack *compositionTrack = nil;

    if (!THIsEmpty(mediaItems)) {
        compositionTrack =
            [self.composition addMutableTrackWithMediaType:mediaType
                                          preferredTrackID:kCMPersistentTrackID_Invalid];

        CMTime cursorTime = kCMTimeZero;

        for (THMediaItem *item in mediaItems) {

            if (CMTIME_COMPARE_INLINE(item.startTimeInTimeline, !=, kCMTimeInvalid)) {
                cursorTime = item.startTimeInTimeline;
            }

            AVAssetTrack *assetTrack = [[item.asset tracksWithMediaType:mediaType] firstObject];
            [compositionTrack insertTimeRange:item.timeRange ofTrack:assetTrack atTime:cursorTime error:nil];

            // Move cursor to next item time
            cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
        }
    }

    return compositionTrack;
}

- (AVAudioMix *)buildAudioMix {
    NSArray *items = self.timeline.musicItems;
    // Only one allowed
    if (items.count == 1) {
        THAudioItem *item = self.timeline.musicItems[0];

        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];

        AVMutableAudioMixInputParameters *parameters =
            [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:self.musicTrack];

        for (THVolumeAutomation *automation in item.volumeAutomation) {
            [parameters setVolumeRampFromStartVolume:automation.startVolume
                                         toEndVolume:automation.endVolume
                                           timeRange:automation.timeRange];
        }
        audioMix.inputParameters = @[parameters];
        return audioMix;
    }
    return nil;
}

@end
