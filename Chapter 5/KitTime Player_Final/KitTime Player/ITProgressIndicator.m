//
//  ITProgressIndicatorView.m
//  ITProgressIndicator
//
//  Created by Ilija Tovilo on 9/25/13.
//  Copyright (c) 2013 Ilija Tovilo. All rights reserved.
//

#if !__has_feature(objc_arc)
#error ARC needs to be enabled!
#endif


#import "ITProgressIndicator.h"
#import "NSBezierPath+Geometry.h"


#pragma mark - Consts
#define kITSpinAnimationKey @"spinAnimation"
#define kITProgressPropertyKey @"progress"

#pragma mark - Private Interface

@interface ITProgressIndicator ()
@property (nonatomic, strong, readonly) CALayer *progressIndicatorLayer;
@end


#pragma mark - Implementation

@implementation ITProgressIndicator
@synthesize progressIndicatorLayer = _progressIndicatorLayer;


#pragma mark - Init

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initLayers];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayers];
    }
    return self;
}

- (void)initLayers {
    // Setting initial values
    self.color = [NSColor blackColor];
    self.innerMargin = 4;
	self.widthOfLine = 3;
    self.lengthOfLine = 6;
    self.numberOfLines = 8;
    self.animationDuration = 0.6;
    self.isIndeterminate = NO;
    self.steppedAnimation = YES;
    self.hideWhenStopped = YES;
    self.animates = YES;
    
    // Init layers
    [self setWantsLayer:YES];
    self.progressIndicatorLayer.frame = self.layer.bounds;
    [self.layer addSublayer:self.progressIndicatorLayer];
    
    [self reloadIndicatorContent];
    [self reloadAnimation];
}

- (void)awakeFromNib {
    [self reloadAnimation];
}

- (void)reloadIndicatorContent {
    self.progressIndicatorLayer.contents = [self progressImage];
}

- (void)reloadAnimation {
    [self.progressIndicatorLayer removeAnimationForKey:kITSpinAnimationKey];
    
    if (self.animates) {
        [self.progressIndicatorLayer addAnimation:[self keyFrameAnimationForCurrentPreferences] forKey:kITSpinAnimationKey];
    }
}


#pragma mark - Drawing

- (NSImage *)progressImage {
    NSImage *progressImage = [[NSImage alloc] initWithSize:self.bounds.size];
    [progressImage lockFocusFlipped:NO];
    [progressImage lockFocus];
    {
        [NSGraphicsContext saveGraphicsState];
        {
            [self.color set];
            
            NSRect r = self.bounds;
            NSBezierPath *line = [NSBezierPath bezierPathWithRoundedRect:
                                  NSMakeRect((NSWidth(r) / 2) - (self.widthOfLine / 2),
                                             (NSHeight(r) / 2) - self.innerMargin - self.lengthOfLine,
                                             self.widthOfLine, self.lengthOfLine)
                                                                 xRadius:self.widthOfLine / 2
                                                                 yRadius:self.widthOfLine / 2];
            
            void (^lineDrawingBlock)(NSUInteger line) =
            ^(NSUInteger lineNumber) {
                NSBezierPath *lineInstance = [line copy];
                lineInstance = [lineInstance rotatedBezierPath:((2 * M_PI) / self.numberOfLines * lineNumber) + M_PI
                                                    aboutPoint:NSMakePoint(NSWidth(r) / 2, NSHeight(r) / 2)];
                
                if (!_isIndeterminate) [[self.color colorWithAlphaComponent:1.0 - (1.0 / self.numberOfLines * lineNumber)] set];
                
                [lineInstance fill];
            };
            
            if (self.isIndeterminate) {
                for (NSUInteger i = self.numberOfLines;
                     i > round(self.numberOfLines - (self.numberOfLines * self.progress));
                     i--)
                {
                    lineDrawingBlock(i);
                }
            } else {
                for (NSUInteger i = 0; i < self.numberOfLines; i++) {
                    lineDrawingBlock(i);
                }
            }
        }
        [NSGraphicsContext restoreGraphicsState];
    }
    [progressImage unlockFocus];
    
    return progressImage;
}


#pragma mark - Helpers

- (CAKeyframeAnimation *)keyFrameAnimationForCurrentPreferences {
    NSMutableArray* keyFrameValues = [NSMutableArray array];
    NSMutableArray* keyTimeValues;
    
    if (self.steppedAnimation) {
        {
            [keyFrameValues addObject:[NSNumber numberWithFloat:0.0]];
            for (int i = 0; i < self.numberOfLines; i++) {
                [keyFrameValues addObject:[NSNumber numberWithFloat:-M_PI * (2.0 / self.numberOfLines * i)]];
                [keyFrameValues addObject:[NSNumber numberWithFloat:-M_PI * (2.0 / self.numberOfLines * i)]];
            }
            [keyFrameValues addObject:[NSNumber numberWithFloat:-M_PI*2.0]];
        }
        
        keyTimeValues = [NSMutableArray array];
        {
            [keyTimeValues addObject:[NSNumber numberWithFloat:0.0]];
            for (int i = 0; i < (self.numberOfLines - 1); i++) {
                [keyTimeValues addObject:[NSNumber numberWithFloat:1.0 / self.numberOfLines * i]];
                [keyTimeValues addObject:[NSNumber numberWithFloat:1.0 / self.numberOfLines * (i + 1)]];
            }
            [keyTimeValues addObject:[NSNumber numberWithFloat:1.0 / self.numberOfLines * (self.numberOfLines - 1)]];
        }
    } else {
        {
            [keyFrameValues addObject:[NSNumber numberWithFloat:-M_PI*0.0]];
            [keyFrameValues addObject:[NSNumber numberWithFloat:-M_PI*0.5]];
            [keyFrameValues addObject:[NSNumber numberWithFloat:-M_PI*1.0]];
            [keyFrameValues addObject:[NSNumber numberWithFloat:-M_PI*1.5]];
            [keyFrameValues addObject:[NSNumber numberWithFloat:-M_PI*2.0]];
        }
    }
    
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    [animation setRepeatCount:HUGE_VALF];
    [animation setValues:keyFrameValues];
    [animation setKeyTimes:keyTimeValues];
    [animation setValueFunction:[CAValueFunction functionWithName: kCAValueFunctionRotateZ]];
    [animation setDuration:self.animationDuration];
    
    return animation;
}

- (void)reloadVisibility {
    if (_hideWhenStopped && !_animates && !_isIndeterminate) {
        [self setHidden:YES];
    } else {
        [self setHidden:NO];
    }
}


#pragma mark - NSView methods

// Animatible proxy
+ (id)defaultAnimationForKey:(NSString *)key
{
    if ([key isEqualToString:kITProgressPropertyKey]) {
        return [CABasicAnimation animation];
    } else {
        return [super defaultAnimationForKey:key];
    }
}


#pragma mark - Setters & Getters

- (void)setIndeterminate:(BOOL)isIndeterminate {
    _isIndeterminate = isIndeterminate;
    
    if (_isIndeterminate) {
        self.animates = NO;
    }
}

- (void)setProgress:(CGFloat)progress {
    if (progress < 0 || progress > 1) {
        @throw [NSException exceptionWithName:@"Invalid `progress` property value"
                                       reason:@"`progress` property needs to be between 0 and 1"
                                     userInfo:nil];
    }
    
    _progress = progress;
    
    if (self.isIndeterminate) {
        [self reloadIndicatorContent];
    }
}

- (void)setAnimates:(BOOL)animates {
    _animates = animates;
    [self reloadIndicatorContent];
    [self reloadAnimation];
    [self reloadVisibility];
}

- (void)setHideWhenStopped:(BOOL)hideWhenStopped {
    _hideWhenStopped = hideWhenStopped;
    [self reloadVisibility];
}

- (CALayer *)progressIndicatorLayer {
    if (!_progressIndicatorLayer) {
        _progressIndicatorLayer = [CALayer layer];
    }
    
    return _progressIndicatorLayer;
}

- (void)setLengthOfLine:(CGFloat)lengthOfLine {
    _lengthOfLine = lengthOfLine;
    [self reloadIndicatorContent];
}

- (void)setWidthOfLine:(CGFloat)widthOfLine {
    _widthOfLine = widthOfLine;
    [self reloadIndicatorContent];
}

- (void)setInnerMargin:(CGFloat)innerMargin {
    _innerMargin = innerMargin;
    [self reloadIndicatorContent];
}

- (void)setAnimationDuration:(CGFloat)animationDuration {
    _animationDuration = animationDuration;
    [self reloadAnimation];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    [self reloadIndicatorContent];
    [self reloadAnimation];
}

- (void)setSteppedAnimation:(BOOL)steppedAnimation {
    _steppedAnimation = steppedAnimation;
    [self reloadAnimation];
}

- (void)setColor:(NSColor *)color {
    _color = color;
    [self reloadIndicatorContent];
}

@end
