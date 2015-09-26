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

#import "THOverlayCompositionBuilder.h"
#import "THVideoItem.h"
#import "THAudioItem.h"
#import "THVolumeAutomation.h"
#import "THOverlayComposition.h"
#import "THTransitionInstructions.h"
#import "THFunctions.h"
#import "THConstants.h"
#import "THTitleItem.h"

@interface THOverlayCompositionBuilder ()
@property (strong, nonatomic) THTimeline *timeline;
@property (strong, nonatomic) AVMutableComposition *composition;
@property (weak, nonatomic) AVMutableCompositionTrack *musicTrack;
@end

@implementation THOverlayCompositionBuilder

- (id)initWithTimeline:(THTimeline *)timeline {
    self = [super init];
    if (self) {
        _timeline = timeline;
    }
    return self;
}

- (id <THComposition>)buildComposition {

    // Listing 12.7

    return nil;
}

- (CALayer *)buildTitleLayer {

    // Listing 12.7

    return nil;
}

- (void)buildCompositionTracks {

    CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;

    AVMutableCompositionTrack *compositionTrackA =                          // 1
        [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                      preferredTrackID:trackID];

    AVMutableCompositionTrack *compositionTrackB =
        [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                      preferredTrackID:trackID];

    NSArray *videoTracks = @[compositionTrackA, compositionTrackB];

    CMTime cursorTime = kCMTimeZero;
    CMTime transitionDuration = kCMTimeZero;

    if (!THIsEmpty(self.timeline.transitions)) {                            // 2
        // 1 second transition duration
        transitionDuration = THDefaultTransitionDuration;
    }

    NSArray *videos = self.timeline.videos;

    for (NSUInteger i = 0; i < videos.count; i++) {

        NSUInteger trackIndex = i % 2;                                      // 3

        THVideoItem *item = videos[i];
        AVMutableCompositionTrack *currentTrack = videoTracks[trackIndex];

        AVAssetTrack *assetTrack =
            [[item.asset tracksWithMediaType:AVMediaTypeVideo] firstObject];

        [currentTrack insertTimeRange:item.timeRange
                              ofTrack:assetTrack
                               atTime:cursorTime error:nil];

        // Overlap clips by transition duration                             // 4
        cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
        cursorTime = CMTimeSubtract(cursorTime, transitionDuration);
    }

    // Add voice overs                                                      // 5
    [self addCompositionTrackOfType:AVMediaTypeAudio
                     withMediaItems:self.timeline.voiceOvers];

    // Add music track
    NSArray *musicItems = self.timeline.musicItems;
    self.musicTrack = [self addCompositionTrackOfType:AVMediaTypeAudio
                                       withMediaItems:musicItems];
}

- (AVVideoComposition *)buildVideoComposition {

    AVVideoComposition *videoComposition =                           // 1
            [AVMutableVideoComposition
                videoCompositionWithPropertiesOfAsset:self.composition];

    NSArray *transitionInstructions =                                       // 2
        [self transitionInstructionsInVideoComposition:videoComposition];

    for (THTransitionInstructions *instructions in transitionInstructions) {

        CMTimeRange timeRange =                                             // 3
            instructions.compositionInstruction.timeRange;

        AVMutableVideoCompositionLayerInstruction *fromLayer =
            instructions.fromLayerInstruction;

        AVMutableVideoCompositionLayerInstruction *toLayer =
            instructions.toLayerInstruction;

        THVideoTransitionType type = instructions.transition.type;

        if (type == THVideoTransitionTypeDissolve) {

            [fromLayer setOpacityRampFromStartOpacity:1.0
                                         toEndOpacity:0.0
                                            timeRange:timeRange];
        }

        if (type == THVideoTransitionTypePush) {

            // Define starting and ending transforms                        // 1
            CGAffineTransform identityTransform = CGAffineTransformIdentity;

            CGFloat videoWidth = videoComposition.renderSize.width;

            CGAffineTransform fromDestTransform =                           // 2
                CGAffineTransformMakeTranslation(-videoWidth, 0.0);

            CGAffineTransform toStartTransform =
                CGAffineTransformMakeTranslation(videoWidth, 0.0);

            [fromLayer setTransformRampFromStartTransform:identityTransform // 3
                                           toEndTransform:fromDestTransform
                                                timeRange:timeRange];

            [toLayer setTransformRampFromStartTransform:toStartTransform    // 4
                                         toEndTransform:identityTransform
                                              timeRange:timeRange];
        }

        if (type == THVideoTransitionTypeWipe) {

            CGFloat videoWidth = videoComposition.renderSize.width;
            CGFloat videoHeight = videoComposition.renderSize.height;

            CGRect startRect = CGRectMake(0.0f, 0.0f, videoWidth, videoHeight);
            CGRect endRect = CGRectMake(0.0f, videoHeight, videoWidth, 0.0f);

            [fromLayer setCropRectangleRampFromStartCropRectangle:startRect
                                               toEndCropRectangle:endRect
                                                        timeRange:timeRange];
        }

        instructions.compositionInstruction.layerInstructions = @[fromLayer,// 4
                                                                  toLayer];
    }

    return videoComposition;
}

// Extract the composition and layer instructions out of the
// prebuilt AVVideoComposition. Make the association between the instructions
// and the THVideoTransition the user configured in the timeline.
- (NSArray *)transitionInstructionsInVideoComposition:(AVVideoComposition *)vc {

    NSMutableArray *transitionInstructions = [NSMutableArray array];

    int layerInstructionIndex = 1;

    NSArray *compositionInstructions = vc.instructions;                     // 1

    for (AVMutableVideoCompositionInstruction *vci in compositionInstructions) {

        if (vci.layerInstructions.count == 2) {                             // 2

            THTransitionInstructions *instructions =
                [[THTransitionInstructions alloc] init];

            instructions.compositionInstruction = vci;

            instructions.fromLayerInstruction =                             // 3
                (AVMutableVideoCompositionLayerInstruction *)vci.layerInstructions[1 - layerInstructionIndex];

            instructions.toLayerInstruction =
                (AVMutableVideoCompositionLayerInstruction *)vci.layerInstructions[layerInstructionIndex];

            [transitionInstructions addObject:instructions];

            layerInstructionIndex = layerInstructionIndex == 1 ? 0 : 1;
        }
    }

    NSArray *transitions = self.timeline.transitions;

    // Transitions are disabled
    if (THIsEmpty(transitions)) {                                           // 4
        return transitionInstructions;
    }

    NSAssert(transitionInstructions.count == transitions.count,
             @"Instruction count and transition count do not match.");

    for (NSUInteger i = 0; i < transitionInstructions.count; i++) {         // 5
        THTransitionInstructions *tis = transitionInstructions[i];
        tis.transition = self.timeline.transitions[i];
    }

    return transitionInstructions;
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
