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

#import "THAppSettings.h"

#define TRANSITIONS_ENABLED_KEY        @"transitionsEnabled"
#define VOLUME_FADES_ENABLED_KEY    @"volumeFadesEnabled"
#define VOLUME_DUCKING_ENABLED_KEY    @"volumeDuckingEnabled"
#define TITLES_ENABLED_KEY            @"titlesEnabled"

@implementation THAppSettings

+ (THAppSettings *)sharedSettings {
    static dispatch_once_t pred;
    static THAppSettings *settings = nil;

    dispatch_once(&pred, ^{
        settings = [[self alloc] init];
    });
    return settings;
}

- (void)save {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)transitionsEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:TRANSITIONS_ENABLED_KEY];
}

- (void)setTransitionsEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:TRANSITIONS_ENABLED_KEY];
    [self save];
}

- (BOOL)volumeFadesEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:VOLUME_FADES_ENABLED_KEY];
}

- (void)setVolumeFadesEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:VOLUME_FADES_ENABLED_KEY];
    [self save];
}

- (BOOL)volumeDuckingEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:VOLUME_DUCKING_ENABLED_KEY];
}

- (void)setVolumeDuckingEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:VOLUME_DUCKING_ENABLED_KEY];
    [self save];
}

- (BOOL)titlesEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:TITLES_ENABLED_KEY];
}

- (void)setTitlesEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:TITLES_ENABLED_KEY];
    [self save];
}

@end
