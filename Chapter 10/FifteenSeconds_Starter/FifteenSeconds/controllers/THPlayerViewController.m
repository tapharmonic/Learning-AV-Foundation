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

#import "THPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "THPlaybackView.h"
#import "AVPlayerItem+THAdditions.h"
#import "THMainViewController.h"
#import "THNotifications.h"
#import "UIView+THAdditions.h"
#import "THSettingsViewController.h"


#define STATUS_KEYPATH @"status"
#define VIDEO_SIZE CGSizeMake(1280, 720)

// Define this constant for the key-value observation context.
static const NSString *PlayerItemStatusContext;

@interface THPlayerViewController () <UIGestureRecognizerDelegate>
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic) BOOL scrubbing;
@property (nonatomic) float lastPlaybackRate;
@property (nonatomic) BOOL autoplayContent;
@property (nonatomic) BOOL readyForDisplay;
@property (strong, nonatomic) UIView *titleView;
@property (weak, nonatomic) UIPopoverController *settingsPopover;
@property (strong, nonatomic) AVAudioMix *mutingAudioMix;
@property (strong, nonatomic) AVAudioMix *lastAudioMix;
@end

@implementation THPlayerViewController

#pragma mark - Set Up
- (void)viewDidLoad {
    [super viewDidLoad];
    self.autoplayContent = YES;
    [self.view bringSubviewToFront:self.loadingView];
}

- (void)loadInitialPlayerItem:(AVPlayerItem *)playerItem {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        self.autoplayContent = NO;
        self.playerItem = playerItem;
        [self prepareToPlay];
    });
}

#pragma mark - Handle Playback

// Only called when previewing
- (void)playPlayerItem:(AVPlayerItem *)playerItem {
    [self.titleView removeFromSuperview];
    self.autoplayContent = YES;
    self.player.rate = 0.0f;
    self.playerItem = playerItem;
    self.playButton.selected = YES;
    if (playerItem) {
        [self prepareToPlay];
    } else {
        NSLog(@"Player item is nil.  Nothing to play.");
    }
}

- (void)prepareToPlay {

    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playbackView.player = self.player;
    } else {
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    }

    [self.playerItem addObserver:self forKeyPath:STATUS_KEYPATH options:0 context:&PlayerItemStatusContext];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];

    if (self.playerItem.titleLayer) {
        [self addSynchronizedLayer:self.playerItem.titleLayer];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{

            if (self.autoplayContent) {
                [self.player play];
            } else {
                [self stopPlayback];
            }

            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];

            [self prepareAudioMixes];

            if (!self.readyForDisplay) {
                [UIView animateWithDuration:0.35 animations:^{
                    self.loadingView.alpha = 0.0f;
                } completion:^(BOOL complete) {
                    [self.view sendSubviewToBack:self.loadingView];
                }];
            }
        });
    }
}


#pragma mark - Transport Actions

- (IBAction)play:(id)sender {
    UIButton *button = sender;
    if (self.player.rate == 1.0) {
        self.player.rate = 0.0f;
        button.selected = NO;
    } else {
        [self.playbackMediator prepareTimelineForPlayback];
        button.selected = YES;
    }
}

- (IBAction)beginRewinding:(id)sender {
    self.lastAudioMix = self.playerItem.audioMix;
    self.lastPlaybackRate = self.player.rate;
    self.playerItem.audioMix = self.mutingAudioMix;
    self.player.rate = -2.0;
}

- (IBAction)endRewinding:(id)sender {
    self.playerItem.audioMix = self.lastAudioMix;
    self.player.rate = self.lastPlaybackRate;
}

- (IBAction)beginFastForwarding:(id)sender {
    self.lastAudioMix = self.playerItem.audioMix;
    self.lastPlaybackRate = self.player.rate;
    self.playerItem.audioMix = self.mutingAudioMix;
    self.player.rate = 2.0;
}

- (IBAction)endFastForwarding:(id)sender {
    self.playerItem.audioMix = self.lastAudioMix;
    self.player.rate = self.lastPlaybackRate;
}

- (void)stopPlayback {
    self.player.rate = 0.0f;
    [self.player seekToTime:kCMTimeZero];
    self.playButton.selected = NO;
}

#pragma mark - Attach AVSynchronizedLayer to layer tree

- (void)addSynchronizedLayer:(AVSynchronizedLayer *)synchLayer {
    // Remove old if it still exists
    [self.titleView removeFromSuperview];

    self.titleView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.titleView.layer addSublayer:synchLayer];

    CGFloat scale = fminf(self.view.boundsWidth / VIDEO_SIZE.width, self.view.boundsHeight /VIDEO_SIZE.height);
    CGRect videoRect = AVMakeRectWithAspectRatioInsideRect(VIDEO_SIZE, self.view.bounds);
    self.titleView.center = CGPointMake( CGRectGetMidX(videoRect), CGRectGetMidY(videoRect));
    self.titleView.transform = CGAffineTransformMakeScale(scale, scale);
    [self.view addSubview:self.titleView];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self stopPlayback];
    [[NSNotificationCenter defaultCenter] postNotificationName:THPlaybackEndedNotification object:nil];
}

#pragma mark - AVAudioMix Setup

- (void)prepareAudioMixes {
    self.mutingAudioMix = [self buildAudioMixForPlayerItem:self.playerItem level:0.05];
    if (!self.playerItem.audioMix) {
        self.playerItem.audioMix = [self buildAudioMixForPlayerItem:self.playerItem level:1.0];
    }
}

- (AVAudioMix *)buildAudioMixForPlayerItem:(AVPlayerItem *)playerItem level:(CGFloat)level {
    NSMutableArray *params = [NSMutableArray array];
    for (AVPlayerItemTrack *track in playerItem.tracks) {
        if ([track.assetTrack.mediaType isEqualToString:AVMediaTypeAudio]) {
            AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track.assetTrack];
            [parameters setVolume:level atTime:kCMTimeZero];
            [params addObject:parameters];
        }
    }
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = params;
    return audioMix;
}

#pragma mark - Display/Hide Export UI

- (void)setExporting:(BOOL)exporting {
    if (exporting) {
        self.exportProgressView.progressView.progress = 0.0f;
        self.exportProgressView.alpha = 0.0f;
        [self.view bringSubviewToFront:self.exportProgressView];
        [UIView animateWithDuration:0.4 animations:^{
            self.exportProgressView.alpha = 1.0f;
        }];
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            self.exportProgressView.alpha = 0.0f;
        } completion:^(BOOL complete) {
            [self.view bringSubviewToFront:self.exportProgressView];
        }];
    }
}


#pragma mark - Settings Popover Segue Handling

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"SettingsPopover"]) {
        if (self.settingsPopover) {
            [self.settingsPopover dismissPopoverAnimated:YES];
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SettingsPopover"]) {
        self.settingsPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        THSettingsViewController *controller = [segue destinationViewController];
        controller.popover = self.settingsPopover;
    }
}

@end
