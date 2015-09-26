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

#import "THManualTransitionCompositionBuilder.h"
#import "AVPlayerItem+THAdditions.h"
#import "THVideoItem.h"
#import "THAudioItem.h"
#import "THVolumeAutomation.h"
#import "THTransitionComposition.h"
#import "THTransitionInstructions.h"
#import "THFunctions.h"

@interface THManualTransitionCompositionBuilder ()
@property (strong, nonatomic) THTimeline *timeline;
@property (strong, nonatomic) AVMutableComposition *composition;
@property (strong, nonatomic) AVVideoComposition *videoComposition;
@property (weak, nonatomic) AVMutableCompositionTrack *musicTrack;
@property (strong, nonatomic) NSMutableArray *passThroughTimeRanges;
@property (strong, nonatomic) NSMutableArray *transitionTimeRanges;

@end

@implementation THManualTransitionCompositionBuilder

- (id)initWithTimeline:(THTimeline *)timeline {
	self = [super init];
	if (self) {
		_timeline = timeline;
        _passThroughTimeRanges = [NSMutableArray array];
        _transitionTimeRanges = [NSMutableArray array];
	}
	return self;
}

- (id <THComposition>)buildComposition {

	self.composition = [AVMutableComposition composition];

	[self buildCompositionTracks];
    [self calculateTimeRanges];

    AVVideoComposition *videoComposition = [self buildVideoCompositionAndInstructions];

    AVAudioMix *audioMix = [self buildAudioMix];

	return [[THTransitionComposition alloc] initWithComposition:self.composition
											 videoComposition:videoComposition
													 audioMix:audioMix];
}

- (void)buildCompositionTracks {

    CMPersistentTrackID trackID = kCMPersistentTrackID_Invalid;

	AVMutableCompositionTrack *compositionTrackA =
        [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                      preferredTrackID:trackID];

	AVMutableCompositionTrack *compositionTrackB =
        [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                      preferredTrackID:trackID];

	NSArray *videoTracks = @[compositionTrackA, compositionTrackB];

	CMTime cursorTime = kCMTimeZero;
    CMTime transitionDuration = kCMTimeZero;

    if (!THIsEmpty(self.timeline.transitions)) {
        // 1 second transition duration
        transitionDuration = THDefaultTransitionDuration;
    }

    NSArray *videos = self.timeline.videos;

	for (NSUInteger i = 0; i < videos.count; i++) {

		NSUInteger trackIndex = i % 2;

		THVideoItem *item = videos[i];
		AVMutableCompositionTrack *currentTrack = videoTracks[trackIndex];

		AVAssetTrack *assetTrack =
            [[item.asset tracksWithMediaType:AVMediaTypeVideo] firstObject];

		[currentTrack insertTimeRange:item.timeRange
                              ofTrack:assetTrack
                               atTime:cursorTime error:nil];

		// Overlap clips by transition duration by moving cursor to the current
		// item's duration and then back it up by the transition duration time.
		cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
		cursorTime = CMTimeSubtract(cursorTime, transitionDuration);
	}

	// Add voice overs
	[self addCompositionTrackOfType:AVMediaTypeAudio
                      withMediaItems:self.timeline.voiceOvers];

	// Add music track
    NSArray *musicItems = self.timeline.musicItems;
	self.musicTrack = [self addCompositionTrackOfType:AVMediaTypeAudio
                                        withMediaItems:musicItems];
}

- (void)calculateTimeRanges {

    CMTime cursorTime = kCMTimeZero;
    CMTime transDuration = THDefaultTransitionDuration;
    transDuration.value = 1000000000;
    transDuration.timescale = 1000000000;

    NSUInteger videoCount = self.timeline.videos.count;

    for (NSUInteger i = 0; i < videoCount; i++) {

        THMediaItem *item = self.timeline.videos[i];

        CMTimeRange timeRange = CMTimeRangeMake(cursorTime, item.timeRange.duration);

        if (i > 0) {
            timeRange.start = CMTimeAdd(timeRange.start, transDuration);
            timeRange.duration = CMTimeSubtract(timeRange.duration, transDuration);
        }

        if (i + 1 < videoCount) {
            timeRange.duration = CMTimeSubtract(timeRange.duration, transDuration);
        }

        [self.passThroughTimeRanges addObject:[NSValue valueWithCMTimeRange:timeRange]];

        cursorTime = CMTimeAdd(cursorTime, item.timeRange.duration);
        cursorTime = CMTimeSubtract(cursorTime, transDuration);

        if (i + 1 < videoCount) {
            timeRange = CMTimeRangeMake(cursorTime, transDuration);
            NSValue *timeRangeValue = [NSValue valueWithCMTimeRange:timeRange];
            [self.transitionTimeRanges addObject:timeRangeValue];
        }
        
    }

//    AVVideoComposition *videoComposition = [AVVideoComposition videoCompositionWithPropertiesOfAsset:self.composition];
//    NSLog(@"Render scale %f", videoComposition.renderScale);
//    NSLog(@"Render size %@", NSStringFromCGSize(videoComposition.renderSize));
//    CMTimeShow(videoComposition.frameDuration);
//
//
//    for (AVVideoCompositionInstruction *vci in videoComposition.instructions) {
//        CMTimeRangeShow(vci.timeRange);
//    }
//
//    printf("\n");
//
//    for (int i = 0; i < videoCount; i++) {
//        CMTimeRangeShow([self.passThroughTimeRanges[i] CMTimeRangeValue]);
//        if (i < videoCount - 1) {
//            CMTimeRangeShow([self.transitionTimeRanges[i] CMTimeRangeValue]);
//        }
//    }

}

- (AVMutableVideoComposition *)buildVideoCompositionAndInstructions {

NSMutableArray *compositionInstructions = [NSMutableArray array];

// Look up all of the video tracks in the composition
NSArray *tracks = [self.composition tracksWithMediaType:AVMediaTypeVideo];

for (NSUInteger i = 0; i < self.passThroughTimeRanges.count; i++) {         // 1

    // Calculate the trackIndex to operate upon: 0, 1, 0, 1, etc.
    NSUInteger trackIndex = i % 2;

    AVMutableCompositionTrack *currentTrack = tracks[trackIndex];

    AVMutableVideoCompositionInstruction *instruction =                     // 2
        [AVMutableVideoCompositionInstruction videoCompositionInstruction];

    instruction.timeRange =                                                 // 3
        [self.passThroughTimeRanges[i] CMTimeRangeValue];

    AVMutableVideoCompositionLayerInstruction *layerInstruction =           // 4
        [AVMutableVideoCompositionLayerInstruction
            videoCompositionLayerInstructionWithAssetTrack:currentTrack];

    instruction.layerInstructions = @[layerInstruction];

    [compositionInstructions addObject:instruction];

    if (i < self.transitionTimeRanges.count) {

        AVCompositionTrack *foregroundTrack = tracks[trackIndex];           // 5
        AVCompositionTrack *backgroundTrack = tracks[1 - trackIndex];

        AVMutableVideoCompositionInstruction *instruction =                 // 6
            [AVMutableVideoCompositionInstruction videoCompositionInstruction];

        CMTimeRange timeRange = [self.transitionTimeRanges[i] CMTimeRangeValue];
        instruction.timeRange = timeRange;

        AVMutableVideoCompositionLayerInstruction *fromLayerInstruction =   // 7
            [AVMutableVideoCompositionLayerInstruction
                videoCompositionLayerInstructionWithAssetTrack:foregroundTrack];

        AVMutableVideoCompositionLayerInstruction *toLayerInstruction =
            [AVMutableVideoCompositionLayerInstruction
                videoCompositionLayerInstructionWithAssetTrack:backgroundTrack];

        instruction.layerInstructions = @[fromLayerInstruction,             // 8
                                          toLayerInstruction];

        [compositionInstructions addObject:instruction];
    }

}

AVMutableVideoComposition *videoComposition =
    [AVMutableVideoComposition videoComposition];

videoComposition.instructions = compositionInstructions;
videoComposition.renderSize = CGSizeMake(1280.0f, 720.0f);
videoComposition.frameDuration = CMTimeMake(1, 30);
videoComposition.renderScale = 1.0f;

    return videoComposition;
}

- (AVVideoComposition *)buildVideoComposition {

	AVVideoComposition *videoComposition =
        [AVMutableVideoComposition
            videoCompositionWithPropertiesOfAsset:self.composition];

	NSArray *transitionInstructions =
        [self transitionInstructionsInVideoComposition:videoComposition];

	for (THTransitionInstructions *instructions in transitionInstructions) {

		CMTimeRange timeRange =
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

            // Define starting and ending transforms
            CGAffineTransform identityTransform = CGAffineTransformIdentity;

            CGFloat videoWidth = videoComposition.renderSize.width;

            CGAffineTransform fromDestTransform =
                CGAffineTransformMakeTranslation(-videoWidth, 0.0);

            CGAffineTransform toStartTransform =
                CGAffineTransformMakeTranslation(videoWidth, 0.0);

            [fromLayer setTransformRampFromStartTransform:identityTransform
                                           toEndTransform:fromDestTransform
                                                timeRange:timeRange];

			[toLayer setTransformRampFromStartTransform:toStartTransform
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

        instructions.compositionInstruction.layerInstructions = @[fromLayer,
                                                                  toLayer];
	}
    
	return videoComposition;
}

// Extract the composition and layer instructions out of the prebuilt AVVideoComposition.
// Make the association between the instructions and the THVideoTransition the user configured
// in the timeline.  There is plenty of room for improvement in how I'm doing this.
- (NSArray *)transitionInstructionsInVideoComposition:(AVVideoComposition *)vc {

    NSMutableArray *transitionInstructions = [NSMutableArray array];

    int layerInstructionIndex = 1;

    NSArray *compositionInstructions = vc.instructions;

	for (AVMutableVideoCompositionInstruction *vci in compositionInstructions) {

        if (vci.layerInstructions.count == 2) {

			THTransitionInstructions *instructions =
                [[THTransitionInstructions alloc] init];

			instructions.compositionInstruction = vci;

			instructions.fromLayerInstruction =
                (AVMutableVideoCompositionLayerInstruction *)vci.layerInstructions[1 - layerInstructionIndex];

            instructions.toLayerInstruction =
                (AVMutableVideoCompositionLayerInstruction *)vci.layerInstructions[layerInstructionIndex];

			[transitionInstructions addObject:instructions];

			layerInstructionIndex = layerInstructionIndex == 1 ? 0 : 1;
		}
	}

	NSArray *transitions = self.timeline.transitions;

	// Transitions are disabled
	if (THIsEmpty(transitions)) {
		return transitionInstructions;
	}
	
	NSAssert(transitionInstructions.count == transitions.count,
             @"Instruction count and transition count do not match.");

	for (NSUInteger i = 0; i < transitionInstructions.count; i++) {
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
