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

#import "THTitleItem.h"
#import "THConstants.h"

@interface THTitleItem ()
@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) CGRect bounds;
@end

@implementation THTitleItem

+ (instancetype)titleItemWithText:(NSString *)text image:(UIImage *)image {
    return [[self alloc] initWithText:text image:image];
}

- (instancetype)initWithText:(NSString *)text image:(UIImage *)image {
    self = [super init];
    if (self) {
        _text = [text copy];
        _image = image;
        _bounds = TH720pVideoRect;                                          // 1
    }
    return self;
}

- (CALayer *)buildLayer {

    // --- Build Layers

    CALayer *parentLayer = [CALayer layer];                                 // 2
    parentLayer.frame = self.bounds;
    parentLayer.opacity = 0.0f;

    CALayer *imageLayer = [self makeImageLayer];
    [parentLayer addSublayer:imageLayer];

    CALayer *textLayer = [self makeTextLayer];
    [parentLayer addSublayer:textLayer];


    // --- Build and Attach Animations

    CAAnimation *fadeInFadeOutAnimation = [self makeFadeInFadeOutAnimation];
    [parentLayer addAnimation:fadeInFadeOutAnimation forKey:nil];           // 1

    if (self.animateImage) {

        parentLayer.sublayerTransform = THMakePerspectiveTransform(1000);   // 1

        CAAnimation *spinAnimation = [self make3DSpinAnimation];

        NSTimeInterval offset =                                             // 2
            spinAnimation.beginTime + spinAnimation.duration - 0.5f;

        CAAnimation *popAnimation =
            [self makePopAnimationWithTimingOffset:offset];

        [imageLayer addAnimation:spinAnimation forKey:nil];                 // 3
        [imageLayer addAnimation:popAnimation forKey:nil];

    }

    return parentLayer;
}

- (CALayer *)makeImageLayer {

    CGSize imageSize = self.image.size;

    CALayer *layer = [CALayer layer];
    layer.contents = (id) self.image.CGImage;
    layer.bounds = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    layer.position = CGPointMake(CGRectGetMidX(self.bounds) - 20.0f, 270.0f);
    layer.allowsEdgeAntialiasing = YES;

    return layer;
}

- (CALayer *)makeTextLayer {

    CGFloat fontSize = self.useLargeFont ? 64.0f : 54.0f;
    UIFont *font = [UIFont fontWithName:@"GillSans-Bold" size:fontSize];

    NSDictionary *attrs =
        @{NSFontAttributeName            : font,
          NSForegroundColorAttributeName : (id) [UIColor whiteColor].CGColor};

    NSAttributedString *string =
        [[NSAttributedString alloc] initWithString:self.text attributes:attrs];

    CGSize textSize = [self.text sizeWithAttributes:attrs];

    CATextLayer *layer = [CATextLayer layer];
    layer.string = string;
    layer.bounds = CGRectMake(0.0f, 0.0f, textSize.width, textSize.height);
    layer.position = CGPointMake(CGRectGetMidX(self.bounds), 470.0f);
    layer.backgroundColor = [UIColor clearColor].CGColor;

    return layer;
}

- (CAAnimation *)makeFadeInFadeOutAnimation {

    CAKeyframeAnimation *animation =
        [CAKeyframeAnimation animationWithKeyPath:@"opacity"];

    animation.values = @[@0.0f, @1.0, @1.0f, @0.0f];
    animation.keyTimes = @[@0.0f, @0.25f, @0.75f, @1.0f];

    animation.beginTime = CMTimeGetSeconds(self.startTimeInTimeline);
    animation.duration = CMTimeGetSeconds(self.timeRange.duration);

    animation.removedOnCompletion = NO;

    return animation;
}

- (CAAnimation *)make3DSpinAnimation {

    CABasicAnimation *animation =                                           // 1
        [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];

    animation.toValue = @((4 * M_PI) * -1);                                 // 2

    animation.beginTime = CMTimeGetSeconds(self.startTimeInTimeline) + 0.2; // 3
    animation.duration = CMTimeGetSeconds(self.timeRange.duration) * 0.4;

    animation.removedOnCompletion = NO;

    animation.timingFunction =                                              // 4
        [CAMediaTimingFunction
            functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    return animation;
}

- (CAAnimation *)makePopAnimationWithTimingOffset:(NSTimeInterval)offset {

    CABasicAnimation *animation =                                           // 5
        [CABasicAnimation animationWithKeyPath:@"transform.scale"];

    animation.toValue = @1.3f;                                              // 6

    animation.beginTime = offset;                                           // 7
    animation.duration = 0.35f;
    
    animation.autoreverses = YES;                                           // 8

    animation.removedOnCompletion = NO;

    animation.timingFunction =
        [CAMediaTimingFunction
            functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    return animation;
}

static CATransform3D THMakePerspectiveTransform(CGFloat eyePosition) {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / eyePosition;
    return transform;
}

@end
