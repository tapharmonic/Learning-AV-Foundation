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

#import "THBackgroundView.h"
#import "NSString+THAdditions.h"

#define VIEW_REGEX @"TH([A-Za-z]+)BackgroundView"

@implementation THBackgroundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setUpView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self setUpView];
	}
	return self;
}

- (void)setUpView {
	NSString *className = NSStringFromClass([self class]);
	NSString *colorName = [[className stringByMatchingRegex:VIEW_REGEX capture:1] lowercaseString];
	NSString *imageName = [NSString stringWithFormat:@"app_%@_background", colorName];
	UIImage *patternImage = [UIImage imageNamed:imageName];

	// Fix for my broken tiled images.  Fix this correctly in Photoshop.
	CGRect insetRect = CGRectMake(2.0f, 2.0f, patternImage.size.width - 2.0f, patternImage.size.width - 2.0f);
	CGImageRef image = CGImageCreateWithImageInRect(patternImage.CGImage, insetRect);	
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithCGImage:image]];
	CGImageRelease(image);
}

@end

@implementation THBlackBackgroundView
@end

@implementation THStoneBackgroundView
@end

@implementation THSlateBackgroundView
@end

@implementation THGrayBackgroundView
@end

@implementation THWhiteBackgroundView
@end



