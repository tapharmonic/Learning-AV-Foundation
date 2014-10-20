//
//  MIT License
//
//  Copyright (c) 2015 Bob McCune http://bobmccune.com/
//  Copyright (c) 2015 TapHarmonic, LLC http://tapharmonic.com/
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

#import "THPreviewView.h"
#import "THContextManager.h"
#import "THFunctions.h"
#import "THNotifications.h"

@interface THPreviewView ()
@property (nonatomic) CGRect drawableBounds;
@end

@implementation THPreviewView

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
	self = [super initWithFrame:frame context:context];
	if (self) {
		self.enableSetNeedsDisplay = NO;
		self.backgroundColor = [UIColor blackColor];
		self.opaque = YES;

		// because the native video image from the back camera is in
		// UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right),
		// we need to apply a clockwise 90 degree transform so that we can draw
		// the video preview as if we were in a landscape-oriented view;
		// if you're using the front camera and you want to have a mirrored
		// preview (so that the user is seeing themselves in the mirror), you
		// need to apply an additional horizontal flip (by concatenating
		// CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)
		self.transform = CGAffineTransformMakeRotation(M_PI_2);
		self.frame = frame;

		[self bindDrawable];
		_drawableBounds = self.bounds;
		_drawableBounds.size.width = self.drawableWidth;
		_drawableBounds.size.height = self.drawableHeight;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(filterChanged:)
                                                     name:THFilterSelectionChangedNotification
                                                   object:nil];
	}
	return self;
}

- (void)filterChanged:(NSNotification *)notification {
    self.filter = notification.object;
}

- (void)setImage:(CIImage *)sourceImage {

    [self bindDrawable];
	
	[self.filter setValue:sourceImage forKey:kCIInputImageKey];
	CIImage *filteredImage = self.filter.outputImage;

	if (filteredImage) {

		CGRect cropRect =
			THCenterCropImageRect(sourceImage.extent, self.drawableBounds);

		[self.coreImageContext drawImage:filteredImage
								  inRect:self.drawableBounds
								fromRect:cropRect];
	}

	[self display];
    [self.filter setValue:nil forKey:kCIInputImageKey];
}

@end
