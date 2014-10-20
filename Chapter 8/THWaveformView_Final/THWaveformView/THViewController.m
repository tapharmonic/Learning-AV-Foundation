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

#import "THViewController.h"
#import "THWaveformView.h"
#import "UIColor+THAdditions.h"
#import <AVFoundation/AVFoundation.h>

@interface THViewController ()
@property (weak, nonatomic) IBOutlet THWaveformView *keysWaveformView;
@property (weak, nonatomic) IBOutlet THWaveformView *beatWaveformView;
@end

@implementation THViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    NSURL *keysURL = [[NSBundle mainBundle] URLForResource:@"keys"
                                              withExtension:@"mp3"];
    
	NSURL *beatURL  = [[NSBundle mainBundle] URLForResource:@"beat"
                                              withExtension:@"aiff"];
    
    self.keysWaveformView.waveColor = [UIColor blueWaveColor];
    self.keysWaveformView.backgroundColor = [UIColor blueBackgroundColor];
    self.keysWaveformView.asset = [AVURLAsset assetWithURL:keysURL];

    self.beatWaveformView.waveColor = [UIColor greenWaveColor];
    self.beatWaveformView.backgroundColor = [UIColor greenBackgroundColor];
    self.beatWaveformView.asset = [AVURLAsset assetWithURL:beatURL];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
