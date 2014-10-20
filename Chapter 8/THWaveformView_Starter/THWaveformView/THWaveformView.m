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

#import "THWaveformView.h"
#import "THSampleDataProvider.h"
#import "THSampleDataFilter.h"
#import <QuartzCore/QuartzCore.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused"

static const CGFloat THWidthScaling = 0.95;
static const CGFloat THHeightScaling = 0.85;

#pragma clang diagnostic pop

@interface THWaveformView ()
@property (strong, nonatomic) THSampleDataFilter *filter;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;
@end

@implementation THWaveformView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
	self.backgroundColor = [UIColor clearColor];
    self.waveColor = [UIColor whiteColor];
    self.layer.cornerRadius = 2.0f;
    self.layer.masksToBounds = YES;
    
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleWhiteLarge;
    
    _loadingView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    
    CGSize size = _loadingView.frame.size;
    CGFloat x = (self.bounds.size.width - size.width) / 2;
    CGFloat y = (self.bounds.size.height - size.height) / 2;
    _loadingView.frame = CGRectMake(x, y, size.width, size.height);
    [self addSubview:_loadingView];
    
    [_loadingView startAnimating];
}

- (void)setWaveColor:(UIColor *)waveColor {
    _waveColor = waveColor;
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = waveColor.CGColor;
    [self setNeedsDisplay];
}

- (void)setAsset:(AVAsset *)asset {

    // Listing 8.7

}

- (void)drawRect:(CGRect)rect {

    // Listing 8.8

}

@end
