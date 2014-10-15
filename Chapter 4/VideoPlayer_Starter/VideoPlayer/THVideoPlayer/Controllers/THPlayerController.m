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

#import "THPlayerController.h"
#import "THThumbnail.h"
#import <AVFoundation/AVFoundation.h>
#import "THTransport.h"
#import "THPlayerView.h"
#import "AVAsset+THAdditions.h"
#import "UIAlertView+THAdditions.h"
#import "THNotifications.h"

// AVPlayerItem's status property
#define STATUS_KEYPATH @"status"

// Refresh interval for timed observations of AVPlayer
#define REFRESH_INTERVAL 0.5f

// Define this constant for the key-value observation context.
static const NSString *PlayerItemStatusContext;


@interface THPlayerController () <THTransportDelegate>

@property (strong, nonatomic) THPlayerView *playerView;

// Listing 4.4

@end

@implementation THPlayerController

#pragma mark - Setup

- (id)initWithURL:(NSURL *)assetURL {
    self = [super init];
    if (self) {
        
        // Listing 4.6
        
    }
    return self;
}

- (void)prepareToPlay {

    // Listing 4.6
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    // Listing 4.7
    
}

#pragma mark - Time Observers

- (void)addPlayerItemTimeObserver {

    // Listing 4.8
    
}

- (void)addItemEndObserverForPlayerItem {

    // Listing 4.9
    
}

#pragma mark - THTransportDelegate Methods

- (void)play {

    // Listing 4.10
    
}

- (void)pause {

    // Listing 4.10
    
}

- (void)stop {

    // Listing 4.10
    
}

- (void)jumpedToTime:(NSTimeInterval)time {

    // Listing 4.10
    
}

- (void)scrubbingDidStart {

    // Listing 4.11
}

- (void)scrubbedToTime:(NSTimeInterval)time {

    // Listing 4.11
    
}

- (void)scrubbingDidEnd {

    // Listing 4.11
    
}


#pragma mark - Thumbnail Generation

- (void)generateThumbnails {

    // Listing 4.14

}


- (void)loadMediaOptions {

    // Listing 4.16
    
}

- (void)subtitleSelected:(NSString *)subtitle {

    // Listing 4.17
    
}


#pragma mark - Housekeeping

- (UIView *)view {
    return self.playerView;
}

@end
