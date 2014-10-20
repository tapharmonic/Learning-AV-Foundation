//
//  ReutersTV
//
//  Copyright 2014 Thomson Reuters Global Resources. All rights reserved.
//  Proprietary and confidential information of TRGR.  Disclosure, use, or
//  reproduction without the written authorization of TRGR is prohibited.
//

#import "AVComposition+THAdditions.h"
#import <CoreMedia/CoreMedia.h>

@implementation AVComposition (THAdditions)

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag {
    NSDictionary *dictionary = [self dictionaryRepresentation];
    return [dictionary writeToFile:path atomically:flag];
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)flag {
    NSDictionary *dictionary = [self dictionaryRepresentation];
    return [dictionary writeToURL:url atomically:flag];
}

- (NSDictionary *)dictionaryRepresentation {

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    NSString *trackID;

    for (AVCompositionTrack *track in self.tracks) {
        trackID = [NSString stringWithFormat:@"track_%i", track.trackID];
        dict[trackID] = [self dictionaryForTrack:track];
    }

    return dict;
}

- (NSDictionary *)dictionaryForTrack:(AVCompositionTrack *)track {

    NSMutableArray *segments = [NSMutableArray array];
    for (AVCompositionTrackSegment *segment in track.segments) {
        [segments addObject:[self dictionaryForSegment:segment]];
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"trackID"] = @(track.trackID);
    dict[@"mediaType"] = track.mediaType;
    dict[@"segments"] = segments;

    return dict;
}

- (NSDictionary *)dictionaryForSegment:(AVCompositionTrackSegment *)segment {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    dict[@"sourceTrackID"] = @(segment.sourceTrackID);
    dict[@"sourceURL"] = [self stringForSourceURL:segment.sourceURL];

    CMTimeRange sourceTimeRange = segment.timeMapping.source;
    CMTimeRange targetTimeRange = segment.timeMapping.target;

    dict[@"sourceTimeRange"] = [self dictionaryForTimeRange:sourceTimeRange];
    dict[@"targetTimeRange"] = [self dictionaryForTimeRange:targetTimeRange];

    dict[@"empty"] = @(segment.isEmpty);

    return dict;
}

- (NSString *)stringForSourceURL:(NSURL *)sourceURL {
    return sourceURL ? [sourceURL absoluteString] : @"";
}

- (NSDictionary *)dictionaryForTimeRange:(CMTimeRange)timeRange {
    return CFBridgingRelease(CMTimeRangeCopyAsDictionary(timeRange, NULL));
}

@end
