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

#import "THPlayerView.h"
#import "THOverlayView.h"
#import <AVFoundation/AVFoundation.h>

@interface THPlayerView ()
@property (strong, nonatomic) THOverlayView *overlayView;                   // 1
@end

@implementation THPlayerView

+ (Class)layerClass {                                                       // 2
    return [AVPlayerLayer class];
}

- (id)initWithPlayer:(AVPlayer *)player {
    self = [super initWithFrame:CGRectZero];                                // 3
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleWidth;

        [(AVPlayerLayer *) [self layer] setPlayer:player];                  // 4

        [[NSBundle mainBundle] loadNibNamed:@"THOverlayView"                // 5
                                      owner:self
                                    options:nil];
        
        [self addSubview:_overlayView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.overlayView.frame = self.bounds;
}

- (id <THTransport>)transport {
    return self.overlayView;
}

@end
