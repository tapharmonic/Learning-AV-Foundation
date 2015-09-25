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

#import "THOverlayView.h"
#import "UIView+THAdditions.h"
#import "NSTimer+Additions.h"
#import <MediaPlayer/MediaPlayer.h>
#import "THSubtitleViewController.h"

@interface THOverlayView () <THSubtitleViewControllerDelegate>
@property (nonatomic) BOOL controlsHidden;
@property (nonatomic) BOOL filmstripHidden;
@property (strong, nonatomic) NSArray *excludedViews;
//@property (nonatomic, assign) CGFloat sliderOffset;
@property (nonatomic, assign) CGFloat infoViewOffset;
@property (strong, nonatomic) NSTimer *timer;
@property (assign) BOOL scrubbing;
@property (strong, nonatomic) NSArray *subtitles;
@property (strong, nonatomic) THSubtitleViewController *controller;
@property (copy, nonatomic) NSString *selectedSubtitle;
@property (assign) CGFloat lastPlaybackRate;
@property (strong, nonatomic) MPVolumeView *volumeView;
@end

@implementation THOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.filmstripHidden = YES;
    self.excludedViews = @[self.navigationBar, self.toolbar, self.filmStripView];

    UIImage *thumbNormalImage = [UIImage imageNamed:@"knob"];
    UIImage *thumbHighlightedImage = [UIImage imageNamed:@"knob_highlighted"];
    [self.scrubberSlider setThumbImage:thumbNormalImage forState:UIControlStateNormal];
    [self.scrubberSlider setThumbImage:thumbHighlightedImage forState:UIControlStateHighlighted];

    self.infoView.hidden = YES;

    [self calculateInfoViewOffset];
    
    // Set up actions
    [self.scrubberSlider addTarget:self action:@selector(showPopupUI) forControlEvents:UIControlEventValueChanged];
    [self.scrubberSlider addTarget:self action:@selector(hidePopupUI) forControlEvents:UIControlEventTouchUpInside];
    [self.scrubberSlider addTarget:self action:@selector(unhidePopupUI) forControlEvents:UIControlEventTouchDown];

    self.filmStripView.layer.shadowOffset = CGSizeMake(0, 2);
    self.filmStripView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.filmStripView.layer.shadowRadius = 2.0f;
    self.filmStripView.layer.shadowOpacity = 0.8f;

    [self enableAirplay];
    
    [self resetTimer];
}

- (void)enableAirplay {
#if ENABLE_AIRPLAY == 1
    UIImage *airplayImage = [UIImage imageNamed:@"airplay"];
    self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectZero];
    self.volumeView.showsVolumeSlider = NO;
    self.volumeView.showsRouteButton = YES;
    [self.volumeView setRouteButtonImage:airplayImage forState:UIControlStateNormal];
    
    [self.volumeView sizeToFit];

    NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbar.items];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.volumeView];
    [items addObject:item];
    self.toolbar.items = items;
#endif
}

- (void)calculateInfoViewOffset {
    [self.infoView sizeToFit];
    self.infoViewOffset = ceilf(CGRectGetWidth(self.infoView.frame) / 2);
}

- (IBAction)showSubtitles:(id)sender {
    [self.timer invalidate];
    [self.delegate pause];
    self.lastPlaybackRate = [[(NSObject *)self.delegate valueForKey:@"lastPlaybackRate"] floatValue];
    self.controller = [[THSubtitleViewController alloc] initWithSubtitles:self.subtitles];
    self.controller.delegate = self;
    self.controller.selectedSubtitle = self.selectedSubtitle ? self.selectedSubtitle : self.subtitles[0];
    [self.window.rootViewController.presentedViewController presentViewController:self.controller animated:YES completion:nil];
}

- (void)subtitleSelected:(NSString *)subtitle {
    self.selectedSubtitle = subtitle;
    [self.delegate subtitleSelected:subtitle];
    if (self.lastPlaybackRate > 0) {
        [self.delegate play];
    }
}

- (void)setSubtitles:(NSArray *)subtitles {
#if ENABLE_SUBTITLES == 1
    NSMutableArray *filtered = [NSMutableArray array];
    [filtered addObject:@"None"];
    for (NSString *sub in subtitles) {
        if ([sub rangeOfString:@"Forced"].location == NSNotFound) {
            [filtered addObject:sub];
        }
    }
    _subtitles = filtered;
    if (_subtitles && _subtitles.count > 1) {
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbar.items];
        UIImage *image = [UIImage imageNamed:@"subtitles"];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(showSubtitles:)];
        [items addObject:item];
        self.toolbar.items = items;
        [self calculateInfoViewOffset];
    }
#endif
}

- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    NSInteger currentSeconds = ceilf(time);
    double remainingTime = duration - time;
    self.currentTimeLabel.text = [self formatSeconds:currentSeconds];
    self.remainingTimeLabel.text = [self formatSeconds:remainingTime];
    self.scrubberSlider.minimumValue = 0.0f;
    self.scrubberSlider.maximumValue = duration;
    self.scrubberSlider.value = time;
}

- (void)setScrubbingTime:(NSTimeInterval)time {
    self.scrubbingTimeLabel.text = [self formatSeconds:time];
}

- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

- (UILabel *)createTransportLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    //label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:15.0f];
    label.text = @"00:00";
    label.userInteractionEnabled = YES;
    [label sizeToFit];
    return label;
}

- (IBAction)toggleFilmstrip:(id)sender {
    [UIView animateWithDuration:0.35 animations:^{
        if (self.filmstripHidden) {
            self.filmStripView.hidden = NO;
            self.filmStripView.frameY = 0;
        } else {
            self.filmStripView.frameY -= self.filmStripView.frameHeight;
        }
        self.filmstripHidden = !self.filmstripHidden;
    } completion:^(BOOL complete) {
        if (self.filmstripHidden) {
            self.filmStripView.hidden = YES;
        }
    }];
    self.filmstripToggleButton.selected = !self.filmstripToggleButton.selected;
}

- (IBAction)toggleControls:(id)sender {
    [UIView animateWithDuration:0.35 animations:^{
        if (!self.controlsHidden) {
            if (!self.filmstripHidden) {
                [UIView animateWithDuration:0.35 animations:^{
                    self.filmStripView.frameY -= self.filmStripView.frameHeight;
                    self.filmstripHidden = YES;
                    self.filmstripToggleButton.selected = NO;
                } completion:^(BOOL complete) {
                    self.filmStripView.hidden = YES;
                    [UIView animateWithDuration:0.35 animations:^{
                        self.navigationBar.frameY -= self.navigationBar.frameHeight;
                        self.toolbar.frameY += self.toolbar.frameHeight;
                    }];
                }];
            } else {
                self.navigationBar.frameY -= self.navigationBar.frameHeight;
                self.toolbar.frameY += self.toolbar.frameHeight;
            }
        } else {
            self.navigationBar.frameY += self.navigationBar.frameHeight;
            self.toolbar.frameY -= self.toolbar.frameHeight;
        }
        self.controlsHidden = !self.controlsHidden;
    }];
}

- (IBAction)togglePlayback:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate) {
        SEL callback = sender.selected ? @selector(play) : @selector(pause);
        [self.delegate performSelector:callback];
    }
}

- (IBAction)closeWindow:(id)sender {
    [self.timer invalidate];
    self.timer = nil;
    [self.delegate stop];
    self.filmStripView.hidden = YES;
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPopupUI {
    self.infoView.hidden = NO;
    CGRect trackRect = [self.scrubberSlider convertRect:self.scrubberSlider.bounds toView:nil];
    CGRect thumbRect = [self.scrubberSlider thumbRectForBounds:self.scrubberSlider.bounds trackRect:trackRect value:self.scrubberSlider.value];

    CGRect rect = self.infoView.frame;
    rect.origin.x = (thumbRect.origin.x) - self.infoViewOffset + 16;
    rect.origin.y = self.boundsHeight - 80;
    self.infoView.frame = rect;

    self.currentTimeLabel.text = @"-- : --";
	self.remainingTimeLabel.text = @"-- : --";
    
    [self setScrubbingTime:self.scrubberSlider.value];
    [self.delegate scrubbedToTime:self.scrubberSlider.value];
}

- (void)unhidePopupUI {
    self.infoView.hidden = NO;
    self.infoView.alpha = 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        self.infoView.alpha = 1.0f;
    }];
    self.scrubbing = YES;
    [self resetTimer];
    [self.delegate scrubbingDidStart];
}

- (void)hidePopupUI {
    [UIView animateWithDuration:0.3f animations:^{
        self.infoView.alpha = 0.0f;
    } completion:^(BOOL complete) {
        self.infoView.alpha = 1.0f;
        self.infoView.hidden = YES;
    }];
    self.scrubbing = NO;
    [self.delegate scrubbingDidEnd];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    [self resetTimer];
    return ![self.excludedViews containsObject:touch.view] && ![self.excludedViews containsObject:touch.view.superview];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    [self.delegate jumpedToTime:currentTime];
}

- (void)playbackComplete {
    self.scrubberSlider.value = 0.0f;
    self.togglePlaybackButton.selected = NO;
}

- (void)resetTimer {
    [self.timer invalidate];
    if (!self.scrubbing) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 firing:^{
            if (self.timer.isValid && !self.controlsHidden) {
                [self toggleControls:nil];
            }
        }];
    }
}

- (void)setTitle:(NSString *)title {
    self.navigationBar.topItem.title = title ? title : @"Video Player";
}

@end
