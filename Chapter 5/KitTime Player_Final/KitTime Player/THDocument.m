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

#import "THDocument.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "THChapter.h"
#import <QTKit/QTKit.h>
#import "NSFileManager+THAdditions.h"
#import "THWindow.h"

#import "THExportWindowController.h"

#define STATUS_KEY @"status"

@interface THDocument () <THExportWindowControllerDelegate>

@property (strong) AVAsset *asset;
@property (strong) AVPlayerItem *playerItem;
@property (strong) NSArray *chapters;
@property (strong) AVAssetExportSession *exportSession;
@property (strong) THExportWindowController *exportController;

@property BOOL modernizing;

@property (weak) IBOutlet AVPlayerView *playerView;

@end

@implementation THDocument

#pragma mark - NSDocument Methods

- (NSString *)windowNibName {
    return @"THDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller {
    [super windowControllerDidLoadNib:controller];

    if (!self.modernizing) {
        [self setupPlaybackStackWithURL:[self fileURL]];
    } else {
        [(id)controller.window showConvertingView];
    }
}

#pragma mark - Setup

- (void)setupPlaybackStackWithURL:(NSURL *)url {

    self.asset = [AVAsset assetWithURL:url];

    NSArray *keys = @[@"commonMetadata", @"availableChapterLocales"];       // 3

    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset          // 4
                           automaticallyLoadedAssetKeys:keys];

    [self.playerItem addObserver:self                                       // 5
                      forKeyPath:STATUS_KEY
                         options:0 context:NULL];

    self.playerView.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView.showsSharingServiceButton = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        NSString *title = [self titleForAsset:self.asset];
        if (title) {
            self.windowForSheet.title = title;
        }
        self.chapters = [self chaptersForAsset:self.asset];

        // Create action menu if chapters are available
        if ([self.chapters count] > 0) {
            [self setupActionMenu];
        }

    }

    [self.playerItem removeObserver:self forKeyPath:STATUS_KEY];
}

- (NSString *)titleInMetadata:(NSArray *)metadata {
    NSArray *items =                                                        // 1
    [AVMetadataItem metadataItemsFromArray:metadata
                                   withKey:AVMetadataCommonKeyTitle
                                  keySpace:AVMetadataKeySpaceCommon];

    return [[items firstObject] stringValue];                               // 2
}

- (NSString *)titleForAsset:(AVAsset *)asset {
    NSString *title = [self titleInMetadata:asset.commonMetadata];          // 3
    if (title && ![title isEqualToString:@""]) {
        return title;
    }
    return nil;
}

- (NSArray *)chaptersForAsset:(AVAsset *)asset {

    NSArray *languages = [NSLocale preferredLanguages];                     // 1

    NSArray *metadataGroups =                                               // 2
    [asset chapterMetadataGroupsBestMatchingPreferredLanguages:languages];

    NSMutableArray *chapters = [NSMutableArray array];

    for (NSUInteger i = 0; i < metadataGroups.count; i++) {
        AVTimedMetadataGroup *group = metadataGroups[i];

        CMTime time = group.timeRange.start;
        NSUInteger number = i + 1;
        NSString *title = [self titleInMetadata:group.items];

        THChapter *chapter =                                                // 3
        [THChapter chapterWithTime:time number:number title:title];

        [chapters addObject:chapter];

    }
    return chapters;
}

#pragma mark - Chapter Navigation

- (void)setupActionMenu {

    NSMenu *menu = [[NSMenu alloc] init];                                   // 1
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Previous Chapter"
                                             action:@selector(previousChapter:)
                                      keyEquivalent:@""]];
    [menu addItem:[[NSMenuItem alloc] initWithTitle:@"Next Chapter"
                                             action:@selector(nextChapter:)
                                      keyEquivalent:@""]];

    self.playerView.actionPopUpButtonMenu = menu;                           // 2
}

- (void)previousChapter:(id)sender {
    [self skipToChapter:[self findPreviousChapter]];                        // 1
}

- (void)nextChapter:(id)sender {
    [self skipToChapter:[self findNextChapter]];                            // 2
}

- (void)skipToChapter:(THChapter *)chapter {                                // 3
    [self.playerItem seekToTime:chapter.time completionHandler:^(BOOL done) {
        [self.playerView flashChapterNumber:chapter.number
                               chapterTitle:chapter.title];
    }];
}

- (THChapter *)findPreviousChapter {

    CMTime playerTime = self.playerItem.currentTime;
    CMTime currentTime = CMTimeSubtract(playerTime, CMTimeMake(3, 1));      // 1
	CMTime pastTime = kCMTimeNegativeInfinity;

    CMTimeRange timeRange = CMTimeRangeMake(pastTime, currentTime);         // 2

    return [self findChapterInTimeRange:timeRange reverse:YES];             // 3
}

- (THChapter *)findNextChapter {

	CMTime currentTime = self.playerItem.currentTime;                       // 4
	CMTime futureTime = kCMTimePositiveInfinity;

    CMTimeRange timeRange = CMTimeRangeMake(currentTime, futureTime);       // 5

    return [self findChapterInTimeRange:timeRange reverse:NO];              // 6
}

- (THChapter *)findChapterInTimeRange:(CMTimeRange)timeRange
                              reverse:(BOOL)reverse {

    __block THChapter *matchingChapter = nil;

    NSEnumerationOptions options = reverse ? NSEnumerationReverse : 0;
    [self.chapters enumerateObjectsWithOptions:options                      // 7
                                    usingBlock:^(id obj,
                                                 NSUInteger idx,
                                                 BOOL *stop) {

        if ([(THChapter *)obj isInTimeRange:timeRange]) {                   // 8
            matchingChapter = obj;
            *stop = YES;
        }
    }];

    return matchingChapter;                                                 // 9
}

#pragma mark - Movie Modernization

- (BOOL)readFromURL:(NSURL *)url
             ofType:(NSString *)typeName
              error:(NSError *__autoreleasing *)outError {

    NSError *error = nil;

    if ([QTMovieModernizer requiresModernization:url error:&error]) {       // 1

        self.modernizing = YES;

        NSURL *destURL = [self tempURLForURL:url];                          // 2

        if (!destURL) {
            self.modernizing = NO;
            NSLog(@"Error creating destination URL, skipping modernization.");
            return NO;
        }

        QTMovieModernizer *modernizer =                                     // 3
            [[QTMovieModernizer alloc] initWithSourceURL:url
                                          destinationURL:destURL];

        modernizer.outputFormat = QTMovieModernizerOutputFormat_H264;       // 4

        [modernizer modernizeWithCompletionHandler:^{
            if (modernizer.status ==                                        // 5
                    QTMovieModernizerStatusCompletedWithSuccess) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setupPlaybackStackWithURL:destURL];               // 6
                    [(id)self.windowForSheet hideConvertingView];
                });
            }
        }];
    }

    return YES;
}

- (NSURL *)tempURLForURL:(NSURL *)url {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath =                                                     // 7
        [fileManager temporaryDirectoryWithTemplateString:@"kittime.XXXXXX"];

    if (dirPath) {                                                          // 8
        NSString *filePath =
            [dirPath stringByAppendingPathComponent:[url lastPathComponent]];
        return [NSURL fileURLWithPath:filePath];
    }

    return nil;
}

#pragma mark - Trimming

- (IBAction)startTrimming:(id)sender {
    [self.playerView beginTrimmingWithCompletionHandler:NULL];
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {

    SEL action = [item action];

	if (action == @selector(startTrimming:)) {
		return self.playerView.canBeginTrimming;
	}

    return YES;
}

#pragma mark - Exporting

- (IBAction)startExporting:(id)sender {

	[self.playerView.player pause];                                         // 1

	NSSavePanel *savePanel = [NSSavePanel savePanel];

	[savePanel beginSheetModalForWindow:self.windowForSheet
                      completionHandler:^(NSInteger result) {

        if (result == NSFileHandlingPanelOKButton) {
            // Order out save panel as the export window will be shown
            [savePanel orderOut:nil];

            NSString *preset = AVAssetExportPresetAppleM4V720pHD;
            self.exportSession =                                            // 2
            [[AVAssetExportSession alloc] initWithAsset:self.asset
                                             presetName:preset];

            NSLog(@"%@", [self.exportSession.supportedFileTypes firstObject]);

            CMTime startTime = self.playerItem.reversePlaybackEndTime;
            CMTime endTime = self.playerItem.forwardPlaybackEndTime;
            CMTimeRange timeRange = CMTimeRangeMake(startTime, endTime);    // 3

            // Configure the export session                                 // 4
            self.exportSession.timeRange = timeRange;
            self.exportSession.outputFileType =
                [self.exportSession.supportedFileTypes firstObject];
            self.exportSession.outputURL = savePanel.URL;

            self.exportController = [[THExportWindowController alloc] init];
            self.exportController.exportSession = self.exportSession;
            self.exportController.delegate = self;
            [self.windowForSheet beginSheet:self.exportController.window    // 5
                          completionHandler:nil];

            [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
                // Tear down                                                // 6
                [self.windowForSheet endSheet:self.exportController.window];
                self.exportController = nil;
                self.exportSession = nil;
            }];
        }
    }];
}

- (void)exportDidCancel {
	[self.exportSession cancelExport];                                      // 7
}


@end
