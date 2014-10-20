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

#import "THVolumeAutomationView.h"
#import "THVolumeAutomation.h"
#import "THFunctions.h"

@interface THVolumeAutomationView ()
@property (nonatomic) CGFloat scaleFactor;
@property (nonatomic) BOOL duckingOnly;
@end

@implementation THVolumeAutomationView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)awakeFromNib {
	self.backgroundColor = [UIColor clearColor];
}

- (void)setAudioRamps:(NSArray *)audioRamps {
	_audioRamps = audioRamps;

    // Determine if ducking-only automation. This is fragile, but suffices
    // for the purposes of the demo app.
    if (audioRamps.count == 2) {
        THVolumeAutomation *startAutomation = [audioRamps firstObject];
        CMTime startTime = startAutomation.timeRange.start;
        if (CMTIME_COMPARE_INLINE(startTime, !=, kCMTimeZero)) {
            self.duckingOnly = YES;
        }
    } else {
        self.duckingOnly = NO;
    }

	[self setNeedsDisplay];
}

CGFloat _THGetWidthForTimeRange(CMTimeRange timeRange, CGFloat scaleFactor) {
	return CMTimeGetSeconds(timeRange.duration) * scaleFactor;
}

- (CGFloat)xForTime:(CMTime)time {
	CMTime xTime = CMTimeSubtract(self.duration, CMTimeSubtract(self.duration, time));
	return CMTimeGetSeconds(xTime) * self.scaleFactor;
}

- (void)setDuration:(CMTime)duration {
	_duration = duration;
	self.scaleFactor = self.bounds.size.width / CMTimeGetSeconds(duration);
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Flip context to think in more natural volume adjustment orientation
	CGContextTranslateCTM(context, 0.0f, CGRectGetHeight(rect));
	CGContextScaleCTM(context, 1.0, -1.0);

	CGFloat x = 0.0f, y = 0.0f;
	CGFloat rectHeight = CGRectGetHeight(rect);

	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, x, y);

    if (self.duckingOnly) {
        y = 1.0f * rectHeight;
        CGPathAddLineToPoint(path, NULL, x, y);
    }

	// Build points for volume ramps
	for (THVolumeAutomation *automation in self.audioRamps) {
		x = [self xForTime:automation.timeRange.start];
		y = automation.startVolume * rectHeight;
		CGPathAddLineToPoint(path, NULL, x, y);

		x = x + THGetWidthForTimeRange(automation.timeRange, self.scaleFactor);
		y = automation.endVolume * rectHeight;
		CGPathAddLineToPoint(path, NULL, x, y);
	}

    if (self.duckingOnly) {
        x = CGRectGetMaxX(rect);
        y = 1.0f * rectHeight;
        CGPathAddLineToPoint(path, NULL, x, y);
        CGPathAddLineToPoint(path, NULL, x, 0.0f);
    }
	
	CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.000 alpha:0.750].CGColor);
	CGContextAddPath(context, path);
	CGContextDrawPath(context, kCGPathFill);

	CGPathRelease(path);
}


@end
