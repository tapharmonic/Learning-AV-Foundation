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

#import "THAudioMixComposition.h"

@interface THAudioMixComposition ()
@property (strong, nonatomic) AVAudioMix *audioMix;
@property (strong, nonatomic) AVComposition *composition;
@end

@implementation THAudioMixComposition

+ (instancetype)compositionWithComposition:(AVComposition *)composition
                                  audioMix:(AVAudioMix *)audioMix {
    return [[self alloc] initWithComposition:composition audioMix:audioMix];
}

- (instancetype)initWithComposition:(AVComposition *)composition
                           audioMix:(AVAudioMix *)audioMix {
    self = [super init];
    if (self) {
        _composition = composition;
        _audioMix = audioMix;
    }
    return self;
}

- (AVPlayerItem *)makePlayable {

    // Listing 10.2

    return nil;
}

- (AVAssetExportSession *)makeExportable {

    // Listing 10.2

    return nil;
}

@end
