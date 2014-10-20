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

#import "THPlayerOverlayView.h"

@interface THPlayerOverlayView ()
@property (weak, nonatomic) IBOutlet UIButton *halfSpeedButton;
@property (weak, nonatomic) IBOutlet UIButton *threeQuarterSpeedButton;
@property (weak, nonatomic) IBOutlet UIButton *fullSpeedButton;

@property (strong, nonatomic) NSArray *buttons;
@end

@implementation THPlayerOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.buttons = @[_halfSpeedButton, _threeQuarterSpeedButton, _fullSpeedButton];
    [self setPlaybackRate:self.fullSpeedButton];
}

- (IBAction)setPlaybackRate:(id)sender {
    for (UIButton *button in self.buttons) {
        button.selected = NO;
    }
    CGFloat rate = 1.0f;
    if (sender == self.halfSpeedButton) {
        rate = 0.5f;
    } else if (sender == self.threeQuarterSpeedButton) {
        rate = 0.75f;
    }
    [self.delegate setRate:rate];
    [sender setSelected:YES];

}

- (IBAction)closeWindow:(id)sender {
    [self.delegate stop];
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)playbackComplete {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
