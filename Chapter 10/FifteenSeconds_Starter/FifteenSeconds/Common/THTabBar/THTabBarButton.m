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

#import "THTabBarButton.h"

#define IMG_FORMAT			@"THTabBar%@"
#define IMG_FORMAT_SELECTED @"THTabBar%@_selected"

@implementation THTabBarButton

- (id)initWithImageName:(NSString *)imageName {
    if ((self = [super initWithFrame:CGRectZero])) {

        UIImage *normalImage = [UIImage imageNamed:[NSString stringWithFormat:IMG_FORMAT, imageName]];
        UIImage *selectedImage = [UIImage imageNamed:[NSString stringWithFormat:IMG_FORMAT_SELECTED, imageName]];

        [self setImage:normalImage forState:UIControlStateNormal];
        [self setImage:selectedImage forState:UIControlStateSelected];

        self.selected = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setHighlighted:(BOOL)value {
    // Override and do nothing to prevent button highlighting
}

- (void)drawRect:(CGRect)rect {

//	if (self.selected) {
//
//        CGContextRef context = UIGraphicsGetCurrentContext();
//
//		// Gloss Gradient Colors
//		UIColor *lightBlack = [UIColor colorWithRed:0.33f green:0.33f blue:0.33f alpha:1.0f];
//		UIColor *midBlack = [UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:1.0f];
//		UIColor *darkBlack = [UIColor colorWithRed:0.16f green:0.16f blue:0.16f alpha:1.0f];
//		NSArray *glossGradientColors = @[(id)lightBlack.CGColor, (id)midBlack.CGColor, (id)darkBlack.CGColor];
//
//		CGFloat glossGradientLocations[] = {0.32, 0.6, 0.88};
//		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//		CGGradientRef glossGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) glossGradientColors, glossGradientLocations);
//
//        // Draw rounded rect
//        CGRect insetRect = CGRectInset(rect, 0.5, 0.5);
//        UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:4.0f];
//        CGContextSaveGState(context);
//        [roundedRectanglePath addClip];
//		CGFloat midX = CGRectGetMidX(rect);
//        CGContextDrawLinearGradient(context, glossGradient, CGPointMake(midX, 0.5), CGPointMake(midX, CGRectGetMaxY(rect) - 0.5), 0);
//        CGContextRestoreGState(context);
//
//        [[UIColor colorWithWhite:0.143 alpha:1.000] setStroke];
//        roundedRectanglePath.lineWidth = 1;
//        [roundedRectanglePath stroke];
//
//        // Release
//        CGGradientRelease(glossGradient);
//        CGColorSpaceRelease(colorSpace);
//    }
}

@end

