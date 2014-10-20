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

#import "THVideoItem.h"

#define THUMBNAIL_COUNT 4
#define THUMBNAIL_SIZE CGSizeMake(227.0f, 128.0f)

@interface THVideoItem ()
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;
@property (strong, nonatomic) NSMutableArray *images;
@end

@implementation THVideoItem

+ (id)videoItemWithURL:(NSURL *)url {
    return [[self alloc] initWithURL:url];
}

- (id)initWithURL:(NSURL *)url {
    self = [super initWithURL:url];
    if (self) {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
        _imageGenerator.maximumSize = THUMBNAIL_SIZE;
        _thumbnails = @[];
        _images = [NSMutableArray arrayWithCapacity:THUMBNAIL_COUNT];
    }
    return self;
}

// Always pass back valid time range.  If no start or end transition playthroughTimeRange equals the media item timeRange.
- (CMTimeRange)playthroughTimeRange {
    CMTimeRange range = self.timeRange;
    if (self.startTransition && self.startTransition.type != THVideoTransitionTypeNone) {
        range.start = CMTimeAdd(range.start, self.startTransition.duration);
        range.duration = CMTimeSubtract(range.duration, self.startTransitionTimeRange.duration);
    }
    if (self.endTransition && self.endTransition.type != THVideoTransitionTypeNone) {
        range.duration = CMTimeSubtract(range.duration, self.endTransition.duration);
    }
    return range;
}

- (CMTimeRange)startTransitionTimeRange {
    if (self.startTransition && self.startTransition.type != THVideoTransitionTypeNone) {
        return CMTimeRangeMake(kCMTimeZero, self.startTransition.duration);
    }
    return CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
}

- (CMTimeRange)endTransitionTimeRange {
    if (self.endTransition && self.endTransition.type != THVideoTransitionTypeNone) {
        CMTime beginTransitionTime = CMTimeSubtract(self.timeRange.duration, self.endTransition.duration);
        return CMTimeRangeMake(beginTransitionTime, self.endTransition.duration);
    }
    return CMTimeRangeMake(self.timeRange.duration, kCMTimeZero);
}

- (NSString *)mediaType {
    // This is actually muxed, but treat as video for our purposes
    return AVMediaTypeVideo;
}

- (void)performPostPrepareActionsWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self generateThumbnailsWithCompletionBlock:completionBlock];
    });
}

- (void)generateThumbnailsWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {

    CMTime duration = self.asset.duration;
    CMTimeValue intervalSeconds = duration.value / THUMBNAIL_COUNT;

    CMTime time = kCMTimeZero;
    NSMutableArray *times = [NSMutableArray array];
    for (NSUInteger i = 0; i < THUMBNAIL_COUNT; i++) {
        [times addObject:[NSValue valueWithCMTime:time]];
        time = CMTimeAdd(time, CMTimeMake(intervalSeconds, duration.timescale));
    }

    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime,
        CGImageRef cgImage,
        CMTime actualTime,
        AVAssetImageGeneratorResult result,
        NSError *error) {

        if (cgImage) {
            UIImage *image = [UIImage imageWithCGImage:cgImage];
            [self.images addObject:image];

        } else {
            [self.images addObject:[UIImage imageNamed:@"video_thumbnail"]];
        }

        if (self.images.count == THUMBNAIL_COUNT) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.thumbnails = [NSArray arrayWithArray:self.images];
                completionBlock(YES);
            });
        }
    }];
}

@end
