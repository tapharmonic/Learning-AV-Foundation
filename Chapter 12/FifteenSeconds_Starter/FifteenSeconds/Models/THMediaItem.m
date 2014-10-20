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

#import "THMediaItem.h"

static NSString *const AVAssetTracksKey = @"tracks";
static NSString *const AVAssetDurationKey = @"duration";
static NSString *const AVAssetCommonMetadataKey = @"commonMetadata";

@interface THMediaItem ()
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *filename;
@property (strong, nonatomic) NSURL *url;
@end

@implementation THMediaItem

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
        _filename = [[url lastPathComponent] copy];
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey :
                                  @YES};
        _asset = [AVURLAsset URLAssetWithURL:url
                                     options:options];
    }
    return self;
}

- (NSString *)title {
    if (!_title) {
        for (AVMetadataItem *metaItem in [self.asset commonMetadata]) {
            if ([metaItem.commonKey isEqualToString:AVMetadataCommonKeyTitle]) {
                _title = [metaItem stringValue];
                break;
            }
        }
    }
    if (!_title) {
        _title = self.filename;
    }
    return _title;
}

- (NSString *)mediaType {
    NSAssert(NO, @"Must be overridden in subclass.");
    return nil;
}

- (void)prepareWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {
    [self.asset loadValuesAsynchronouslyForKeys:@[AVAssetTracksKey, AVAssetDurationKey, AVAssetCommonMetadataKey] completionHandler:^{
        // Production code should be more robust.  Specifically, should capture error in failure case.
        AVKeyValueStatus tracksStatus = [self.asset statusOfValueForKey:AVAssetTracksKey error:nil];
        AVKeyValueStatus durationStatus = [self.asset statusOfValueForKey:AVAssetDurationKey error:nil];
        _prepared = (tracksStatus == AVKeyValueStatusLoaded) && (durationStatus == AVKeyValueStatusLoaded);
        if (self.prepared) {
            self.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
            [self performPostPrepareActionsWithCompletionBlock:completionBlock];
        } else {
            if (completionBlock) {
                completionBlock(NO);
            }
        }
    }];
}

- (void)performPostPrepareActionsWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {
    if (completionBlock) {
        completionBlock(self.prepared);
    }
}

- (BOOL)isTrimmed {
    if (!self.prepared) {
        return NO;
    }
    return CMTIME_COMPARE_INLINE(self.timeRange.duration, <, self.asset.duration);
}

- (AVPlayerItem *)makePlayable {
    return [AVPlayerItem playerItemWithAsset:self.asset];
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }

    return [self.url isEqual:[other url]];
}

- (NSUInteger)hash {
    return [self.url hash];
}

@end
