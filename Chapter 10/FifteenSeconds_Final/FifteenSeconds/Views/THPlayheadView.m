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

#import "THPlayheadView.h"
#import <AVFoundation/AVFoundation.h>
#import "THFunctions.h"

#define X_OFFSET 5.0f

@implementation THPlayheadView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearPlayhead:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)clearPlayhead:(NSNotification *)notification {
    [self reset];
}

- (void)reset {
    self.layer.sublayers = nil;
}

- (void)synchronizeWithPlayerItem:(AVPlayerItem *)playerItem {

    // Remove existing sublayers
    [self reset];

    // ----- Configure Red Line -----

    // Red line is 4 pts wide
    CGRect lineRect = CGRectMake(0.0f, 0.0f, 4.0f, self.layer.bounds.size.height);

    CAShapeLayer *redlineLayer = [CAShapeLayer layer];
    redlineLayer.path = [UIBezierPath bezierPathWithRect:lineRect].CGPath;
    redlineLayer.frame = lineRect;
    redlineLayer.fillColor = [[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.4f] CGColor];


    // ----- Configure White Line -----

    // White line is 1 pt wide
    lineRect.origin.x = 0;
    lineRect.size.width = 1;

    // Position the white line layer of the timeMarker at the center of the red band layer
    CAShapeLayer *whitelineLayer = [CAShapeLayer layer];
    whitelineLayer.path = [UIBezierPath bezierPathWithRect:lineRect].CGPath;
    whitelineLayer.frame = lineRect;
    whitelineLayer.position = CGPointMake(2.0f, self.bounds.size.height / 2.0f);
    whitelineLayer.fillColor = [UIColor whiteColor].CGColor;

    // Add the white line layer to red line layer
    [redlineLayer addSublayer:whitelineLayer];


    // Configure basic animation to animate the x position of the playhead
    CABasicAnimation *playheadAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    playheadAnimation.fromValue = [self xPositionForTime:kCMTimeZero];
    playheadAnimation.toValue = [self xPositionForTime:playerItem.duration];
    playheadAnimation.removedOnCompletion = NO;
    playheadAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
    playheadAnimation.duration = CMTimeGetSeconds(playerItem.duration);
    playheadAnimation.fillMode = kCAFillModeBoth;
    [redlineLayer addAnimation:playheadAnimation forKey:nil];

    // Create AVSynchronizedLayer to synchronize with player's timing
    AVSynchronizedLayer *syncLayer = [AVSynchronizedLayer synchronizedLayerWithPlayerItem:playerItem];
    [syncLayer addSublayer:redlineLayer];

    [self.layer addSublayer:syncLayer];

    // Trigger redraw to update UI
    [self.layer setNeedsDisplay];
}

- (NSNumber *)xPositionForTime:(CMTime)time {
    CGPoint position = THGetOriginForTime(time);
    return @(position.x + X_OFFSET);
}

@end
