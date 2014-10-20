//
//  UIColor+THAdditions.m
//  THWaveformView
//
//  Created by Bob McCune on 7/14/14.
//  Copyright (c) 2014 TapHarmonic, LLC. All rights reserved.
//

#import "UIColor+THAdditions.h"

@implementation UIColor (THAdditions)

+ (instancetype)greenWaveColor {
    return [UIColor colorWithRed:0.714 green:1.000 blue:0.816 alpha:1.000];
}

+ (instancetype)greenBackgroundColor {
    return [UIColor colorWithRed:0.122 green:0.618 blue:0.240 alpha:1.000];
}

+ (instancetype)blueWaveColor {
    return [UIColor colorWithRed:0.749 green:0.861 blue:0.994 alpha:1.000];
}

+ (instancetype)blueBackgroundColor {
    return [UIColor colorWithRed:0.142 green:0.270 blue:0.438 alpha:1.000];
}

@end
