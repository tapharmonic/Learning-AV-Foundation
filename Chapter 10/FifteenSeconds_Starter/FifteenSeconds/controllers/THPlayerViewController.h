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

#import <AVFoundation/AVFoundation.h>
#import "THVideoPickerViewController.h"
#import "THPlaybackView.h"
#import "THPlaybackMediator.h"
#import "THExportProgressView.h"

@interface THPlayerViewController : UIViewController

@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) IBOutlet THPlaybackView *playbackView;
@property (weak, nonatomic) id <THPlaybackMediator> playbackMediator;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet THExportProgressView *exportProgressView;
@property (nonatomic) BOOL exporting;

- (void)loadInitialPlayerItem:(AVPlayerItem *)playerItem;
- (void)playPlayerItem:(AVPlayerItem *)playerItem;

// Transport Actions
- (IBAction)play:(id)sender;
- (IBAction)beginRewinding:(id)sender;
- (IBAction)endRewinding:(id)sender;
- (IBAction)endFastForwarding:(id)sender;
- (IBAction)beginFastForwarding:(id)sender;
- (void)stopPlayback;

@end
