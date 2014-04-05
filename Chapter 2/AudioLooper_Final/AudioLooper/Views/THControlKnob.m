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
//  This component is based on Matthijs Hollemans' excellent MHRotaryKnob.
//  https://github.com/hollance/MHRotaryKnob
//
//  I have added some custom drawing and made some modifications to fit the
//  needs of this demo app.
//

#import "THControlKnob.h"
#import "THIndicatorLight.h"
#import "UIColor+THAdditions.h"
#import <QuartzCore/QuartzCore.h>

const float kMaxAngle = 120.0f;
const float kScalingFactor = 4.0f;

@interface THControlKnob ()

@property (nonatomic) float angle;
@property (nonatomic) CGPoint touchOrigin;
@property (strong, nonatomic) THIndicatorLight *indicatorView;

@end

@implementation THControlKnob

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

	_angle = 0.0f;

	_defaultValue = 0.0f;
	_minimumValue = -1.0f;
	_maximumValue = 1.0f;
	_value = _defaultValue;

	_indicatorView = [[THIndicatorLight alloc] initWithFrame:self.bounds];
    _indicatorView.lightColor = [self indicatorLightColor];
	[self addSubview:_indicatorView];

	[self valueDidChangeFrom:_defaultValue to:_defaultValue animated:NO];
}

- (UIColor *)indicatorLightColor {
    return [UIColor whiteColor];
}

#pragma mark - Data Model

- (float)clampAngle:(float)angle {
	if (angle < -kMaxAngle) {
		angle = -kMaxAngle;
	} else if (angle > kMaxAngle) {
		angle = kMaxAngle;
	}
	return angle;
}

- (float)angleForValue:(float)value {
	return ((value - self.minimumValue) / (self.maximumValue - self.minimumValue) - 0.5f) * (kMaxAngle * 2.0f);
}

- (float)valueForAngle:(float)angle {
	return (angle / (kMaxAngle * 2.0f) + 0.5f) * (self.maximumValue - self.minimumValue) + self.minimumValue;
}

- (float)valueForPosition:(CGPoint)point {
	float delta = self.touchOrigin.y - point.y;
	float newAngle = [self clampAngle:delta * kScalingFactor + self.angle];
	return [self valueForAngle:newAngle];
}

- (void)setValue:(float)newValue {
	[self setValue:newValue animated:NO];
}

- (void)setValue:(float)newValue animated:(BOOL)animated {
	float oldValue = _value;

	if (newValue < self.minimumValue) {
		_value = self.minimumValue;
	} else if (newValue > self.maximumValue) {
		_value = self.maximumValue;
	} else {
		_value = newValue;
	}

	[self valueDidChangeFrom:(float)oldValue to:(float)_value animated:animated];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint point = [touch locationInView:self];
	self.touchOrigin = point;
	self.angle = [self angleForValue:self.value];
    self.highlighted = YES;
    [self setNeedsDisplay];
	return YES;
}

- (BOOL)handleTouch:(UITouch *)touch {
	if (touch.tapCount > 1) {
		[self setValue:self.defaultValue animated:YES];
		return NO;
	}
	CGPoint point = [touch locationInView:self];
	self.value = [self valueForPosition:point];
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	if ([self handleTouch:touch]) {
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	[self handleTouch:touch];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
    self.highlighted = NO;
    [self setNeedsDisplay];
}

- (void)valueDidChangeFrom:(float)oldValue to:(float)newValue animated:(BOOL)animated {

	float newAngle = [self angleForValue:newValue];

	if (animated) {

		float oldAngle = [self angleForValue:oldValue];

		CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
		animation.duration = 0.2f;

		animation.values = @[@(oldAngle * M_PI/ 180.0f),
							 @((newAngle + oldAngle) / 2.0f * M_PI/ 180.0f),
							 @(newAngle * M_PI/ 180.0f)];

		animation.keyTimes = @[@0.0f,
							   @0.5f,
							   @1.0f];

		animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
									  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

		[self.indicatorView.layer addAnimation:animation forKey:nil];
	}
    
	self.indicatorView.transform = CGAffineTransformMakeRotation(newAngle * M_PI/ 180.0f);
}

- (void)drawRect:(CGRect)rect {

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Set up Colors
	UIColor *strokeColor = [UIColor colorWithWhite:0.06 alpha:1.0f];
	UIColor *gradientLightColor = [UIColor colorWithRed:0.101 green:0.100 blue:0.103 alpha:1.000];
	UIColor *gradientDarkColor = [UIColor colorWithRed:0.237 green:0.242 blue:0.242 alpha:1.000];

    if (self.highlighted) {
        gradientLightColor = [gradientLightColor darkerColor];
        gradientDarkColor = [gradientDarkColor darkerColor];
    }

	NSArray *gradientColors = @[(id)gradientLightColor.CGColor, (id)gradientDarkColor.CGColor];
	CGFloat locations[] = {0, 1};
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, locations);

	CGRect insetRect = CGRectInset(rect, 2.0f, 2.0f);

	// Draw Bezel
	CGContextSetFillColorWithColor(context, strokeColor.CGColor);
	CGContextFillEllipseInRect(context, insetRect);

	CGFloat midX = CGRectGetMidX(insetRect);
	CGFloat midY = CGRectGetMidY(insetRect);

	// Draw Bezel Light Shadow Layer
	CGContextAddArc(context, midX, midY, CGRectGetWidth(insetRect) / 2, 0, M_PI * 2, 1);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.5f), 2.0f, [UIColor darkGrayColor].CGColor);
	CGContextFillPath(context);

	// Add Clipping Region for Knob Background
	CGContextAddArc(context, midX, midY, (CGRectGetWidth(insetRect) - 6) / 2, 0, M_PI * 2, 1);
	CGContextClip(context);

	CGPoint startPoint = CGPointMake(midX, CGRectGetMaxY(insetRect));
	CGPoint endPoint = CGPointMake(midX, CGRectGetMinY(insetRect));

	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);

	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}

@end

@implementation THGreenControlKnob

- (UIColor *)indicatorLightColor {
    return [UIColor colorWithRed:0.226 green:1.000 blue:0.226 alpha:1.000];
}

@end

@implementation THOrangeControlKnob

- (UIColor *)indicatorLightColor {
    return [UIColor colorWithRed:1.000 green:0.718 blue:0.000 alpha:1.000];
}

@end


