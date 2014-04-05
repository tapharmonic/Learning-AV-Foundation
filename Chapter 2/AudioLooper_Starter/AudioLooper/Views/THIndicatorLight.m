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

#import "THIndicatorLight.h"
#import "UIColor+THAdditions.h"

@implementation THIndicatorLight

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setUserInteractionEnabled:NO];
	}
	return self;
}

- (void)setLightColor:(UIColor *)lightColor {
    _lightColor = lightColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat midX = CGRectGetMidX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat width = CGRectGetWidth(rect) * 0.15;
    CGFloat height = CGRectGetHeight(rect) * 0.15;
    CGRect indicatorRect = CGRectMake(midX - (width / 2), minY + 15, width, height);

    UIColor *strokeColor = [self.lightColor darkerColor];
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, self.lightColor.CGColor);

    UIColor *shadowColor = [self.lightColor lighterColor];
    CGSize shadowOffset = CGSizeMake(0.0f, 0.0f);
    CGFloat blurRadius = 5.0f;

    CGContextSetShadowWithColor(context, shadowOffset, blurRadius, shadowColor.CGColor);

    CGContextAddEllipseInRect(context, indicatorRect);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
