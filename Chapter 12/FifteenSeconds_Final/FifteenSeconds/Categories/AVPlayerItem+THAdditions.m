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


#import "AVPlayerItem+THAdditions.h"
#import <objc/runtime.h>

static id THSynchronizedLayerKey;

@implementation AVPlayerItem (THAdditions)

- (BOOL)hasValidDuration {
	return self.status == AVPlayerItemStatusReadyToPlay && !CMTIME_IS_INVALID(self.duration);
}

- (AVSynchronizedLayer *)syncLayer {
	return objc_getAssociatedObject(self, &THSynchronizedLayerKey);
}

- (void)setSyncLayer:(AVSynchronizedLayer *)titleLayer {
	objc_setAssociatedObject(self, &THSynchronizedLayerKey, titleLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)muteAudioTracks:(BOOL)value {
	for (AVPlayerItemTrack *track in self.tracks) {
		if ([track.assetTrack.mediaType isEqualToString:AVMediaTypeAudio]) {
			track.enabled = !value;
		}
	}
}

@end
