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

#import "THVideoTransition.h"

@implementation THVideoTransition

+ (id)videoTransition {
    return [[[self class] alloc] init];
}

+ (id)fadeInTransitionWithDuration:(CMTime)duration {
    THVideoTransition *transition = [self videoTransition];
    transition.type = THVideoTransitionTypeFadeIn;
    transition.duration = duration;
    return transition;
}

+ (id)fadeOutTransitionWithDuration:(CMTime)duration {
    THVideoTransition *transition = [self videoTransition];
    transition.type = THVideoTransitionTypeFadeOut;
    transition.duration = duration;
    return transition;
}

+ (id)disolveTransitionWithDuration:(CMTime)duration {
    THVideoTransition *transition = [self videoTransition];
    transition.type = THVideoTransitionTypeDissolve;
    transition.duration = duration;
    return transition;
}

+ (id)pushTransitionWithDuration:(CMTime)duration direction:(THPushTransitionDirection)direction {
    THVideoTransition *transition = [self videoTransition];
    transition.type = THVideoTransitionTypePush;
    transition.duration = duration;
    transition.direction = direction;
    return transition;
}


- (id)init {
    self = [super init];
    if (self) {
        _type = THVideoTransitionTypeNone;
        _timeRange = kCMTimeRangeInvalid;
    }
    return self;
}

- (void)setDirection:(THPushTransitionDirection)direction {
    if (self.type == THVideoTransitionTypePush) {
        _direction = direction;
    } else {
        _direction = THPushTransitionDirectionInvalid;
        NSAssert(NO, @"Direction can only be specified for a type == THVideoTransitionTypePush.");
    }
}

@end
