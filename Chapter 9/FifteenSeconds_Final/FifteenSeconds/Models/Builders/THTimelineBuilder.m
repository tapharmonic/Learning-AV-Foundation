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

#import "THTimelineBuilder.h"
#import "THVideoTransition.h"

@implementation THTimelineBuilder

+ (THTimeline *)buildTimelineWithMediaItems:(NSArray *)mediaItems {
    THTimeline *timeline = [[THTimeline alloc] init];
    timeline.videos = [self buildVideoItems:mediaItems[THVideoTrack]];
    timeline.transitions = [self buildTransitions:mediaItems[THVideoTrack]];
    timeline.voiceOvers = [self buildMediaItems:mediaItems[THCommentaryTrack]];
    timeline.musicItems = [self buildMediaItems:mediaItems[THMusicTrack]];
    timeline.titles = [self buildMediaItems:mediaItems[THTitleTrack]];
    return timeline;
}

+ (NSArray *)buildMediaItems:(NSArray *)adaptedItems {
    NSMutableArray *items = [NSMutableArray array];
    for (THTimelineItemViewModel *adapter in adaptedItems) {
        [adapter updateTimelineItem];
        [items addObject:adapter.timelineItem];
    }
    return items;
}

+ (NSArray *)buildTransitions:(NSArray *)viewModels {
    NSMutableArray *items = [NSMutableArray array];
    for (id item in viewModels) {
        if ([item isKindOfClass:[THVideoTransition class]]) {
            [items addObject:item];
        }
    }
    return items;
}

+ (NSArray *)buildVideoItems:(NSArray *)viewModels {
    NSMutableArray *items = [NSMutableArray array];
    for (THTimelineItemViewModel *model in viewModels) {
        if ([model isKindOfClass:[THTimelineItemViewModel class]] &&
            [model.timelineItem isKindOfClass:[THMediaItem class]]) {
            [model updateTimelineItem];
            [items addObject:model.timelineItem];
        }
    }
    return items;
}

@end
