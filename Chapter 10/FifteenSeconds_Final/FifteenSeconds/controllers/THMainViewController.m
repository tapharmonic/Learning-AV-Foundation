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

#import "THMainViewController.h"
#import "THPlayerViewController.h"
#import "THTimelineViewController.h"
#import "THVideoPickerViewController.h"
#import "THVideoItem.h"
#import "THCompositionBuilderFactory.h"
#import "THCompositionBuilder.h"
#import "THTimeline.h"
#import "THNotifications.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "THAppDelegate.h"
#import "UIAlertView+THAdditions.h"
#import "THCompositionExporter.h"
#import "THAudioItem.h"

#define SEGUE_ADD_MEDIA_PICKER	@"addMediaPickerViewController"
#define SEGUE_ADD_PLAYER		@"addPlayerViewController"
#define SEGUE_ADD_TIMELINE		@"addTimelineViewController"

#define EXPORTING_KEYPATH       @"exporting"
#define PROGRESS_KEYPATH        @"progress"

@interface THMainViewController ()
@property (strong, nonatomic) THCompositionBuilderFactory *factory;
@property (strong, nonatomic) THCompositionExporter *exporter;
@end

@implementation THMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Wires up child view controller relationships
	[[THAppDelegate sharedDelegate] prepareMainViewController];

	self.factory = [[THCompositionBuilderFactory alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(exportComposition:)
												 name:THExportRequestedNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadDefaultComposition:)
												 name:THLoadDefaultCompositionNotification
											   object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)loadMediaItem:(THMediaItem *)mediaItem {
	[self.playerViewController loadInitialPlayerItem:[mediaItem makePlayable]];
}

- (void)previewMediaItem:(THMediaItem *)mediaItem {
	[self.playerViewController playPlayerItem:[mediaItem makePlayable]];
}

- (void)prepareTimelineForPlayback {
	THTimeline *timeline = self.timelineViewController.currentTimeline;
	id<THCompositionBuilder> builder = [self.factory builderForTimeline:timeline];
	id<THComposition> composition = [builder buildComposition];
    AVPlayerItem *playerItem = [composition makePlayable];
    [self.timelineViewController synchronizePlayheadWithPlayerItem:playerItem];
	[self.playerViewController playPlayerItem:playerItem];
}

- (void)addMediaItem:(THMediaItem *)item toTimelineTrack:(THTrack)track {
	[self.timelineViewController addTimelineItem:item toTrack:track];
}

- (void)stopPlayback {
	[self.playerViewController stopPlayback];
}

- (void)loadDefaultComposition:(NSNotification *)notification {
    [self.timelineViewController clearTimeline];

    NSArray *videoItems = self.videoPickerViewController.defaultVideoItems;
    for (THVideoItem *item in videoItems) {
        [self.timelineViewController addTimelineItem:item toTrack:THVideoTrack];
    }

    THAudioItem *voiceOverItem = self.audioPickerViewController.defaultVoiceOver;
    THAudioItem *musicTrackItem = self.audioPickerViewController.defaultMusicTrack;
    musicTrackItem.volumeAutomation = nil;

    [self.timelineViewController addTimelineItem:voiceOverItem toTrack:THCommentaryTrack];
    [self.timelineViewController addTimelineItem:musicTrackItem toTrack:THMusicTrack];
}

- (void)exportComposition:(NSNotification *)notification {

    THTimeline *timeline = self.timelineViewController.currentTimeline;
	id<THCompositionBuilder> builder = [self.factory builderForTimeline:timeline];
	id<THComposition> composition = [builder buildComposition];
    self.exporter = [[THCompositionExporter alloc] initWithComposition:composition];
    [self.exporter addObserver:self
                    forKeyPath:EXPORTING_KEYPATH
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    [self.exporter addObserver:self
                    forKeyPath:PROGRESS_KEYPATH
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    [self.exporter beginExport];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if ([keyPath isEqualToString:EXPORTING_KEYPATH]) {
        BOOL exporting = [change[NSKeyValueChangeNewKey] boolValue];
        self.playerViewController.exporting = exporting;
        if (!exporting) {
            [self.exporter removeObserver:self forKeyPath:PROGRESS_KEYPATH];
            [self.exporter removeObserver:self forKeyPath:EXPORTING_KEYPATH];
        }

    } else if ([keyPath isEqualToString:PROGRESS_KEYPATH]) {
        CGFloat progress = [change[NSKeyValueChangeNewKey] floatValue];
        DDProgressView *progressView = self.playerViewController.exportProgressView.progressView;
        progressView.progress = progress;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }

}

@end
