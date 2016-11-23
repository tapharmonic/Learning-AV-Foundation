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

#import "THCameraController.h"
#import <AVFoundation/AVFoundation.h>

const CGFloat THZoomRate = 1.0f;

// KVO Contexts
static const NSString *THRampingVideoZoomContext;
static const NSString *THRampingVideoZoomFactorContext;

@implementation THCameraController

- (BOOL)setupSessionInputs:(NSError **)error {
	BOOL success = [super setupSessionInputs:error];                        // 1
	if (success) {
		[self.activeCamera addObserver:self                                 // 2
							forKeyPath:@"videoZoomFactor"
							   options:0
							   context:&THRampingVideoZoomFactorContext];
		[self.activeCamera addObserver:self                                 // 3
							forKeyPath:@"rampingVideoZoom"
							   options:0
							   context:&THRampingVideoZoomContext];

	}
	return success;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {

	if (context == &THRampingVideoZoomContext) {
        [self updateZoomingDelegate];                                       // 4
	} else if (context == &THRampingVideoZoomFactorContext) {
		if (self.activeCamera.isRampingVideoZoom) {
			[self updateZoomingDelegate];                                   // 5
		}
	} else {
		[super observeValueForKeyPath:keyPath
							 ofObject:object
							   change:change
							  context:context];
	}
}

- (void)updateZoomingDelegate {
	CGFloat curZoomFactor = self.activeCamera.videoZoomFactor;
	CGFloat maxZoomFactor = [self maxZoomFactor];
	CGFloat value = log(curZoomFactor) / log(maxZoomFactor);                // 6
    [self.zoomingDelegate rampedZoomToValue:value];                         // 7
}

- (BOOL)cameraSupportsZoom {
	return self.activeCamera.activeFormat.videoMaxZoomFactor > 1.0f;        // 1
}

- (CGFloat)maxZoomFactor {
	return MIN(self.activeCamera.activeFormat.videoMaxZoomFactor, 4.0f);    // 2
}

- (void)setZoomValue:(CGFloat)zoomValue {                                   // 3
	if (!self.activeCamera.isRampingVideoZoom) {

        NSError *error;
        if ([self.activeCamera lockForConfiguration:&error]) {              // 4

            // Provide linear feel to zoom slider
			CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);      // 5
            self.activeCamera.videoZoomFactor = zoomFactor;

            [self.activeCamera unlockForConfiguration];                     // 6

		} else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
	}
}

- (void)rampZoomToValue:(CGFloat)zoomValue {                                // 1
    CGFloat zoomFactor = pow([self maxZoomFactor], zoomValue);
	NSError *error;
	if ([self.activeCamera lockForConfiguration:&error]) {
		[self.activeCamera rampToVideoZoomFactor:zoomFactor                 // 2
                                        withRate:THZoomRate];
		[self.activeCamera unlockForConfiguration];
	} else {
		[self.delegate deviceConfigurationFailedWithError:error];
	}
}

- (void)cancelZoom {                                                        // 3
	NSError *error;
	if ([self.activeCamera lockForConfiguration:&error]) {
		[self.activeCamera cancelVideoZoomRamp];                            // 4
		[self.activeCamera unlockForConfiguration];
	} else {
		[self.delegate deviceConfigurationFailedWithError:error];
	}
}

@end

