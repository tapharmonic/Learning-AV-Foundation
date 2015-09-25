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

#import "THCameraModeView.h"
#import "UIView+THAdditions.h"
#import <CoreText/CoreText.h>
#import "THCaptureButton.h"

#define COMPONENT_MARGIN 20.0f
#define BUTTON_SIZE CGSizeMake(68.0f, 68.0f)

@interface THCameraModeView ()
@property (strong, nonatomic) UIColor *foregroundColor;
@property (strong, nonatomic) CATextLayer *videoTextLayer;
@property (strong, nonatomic) CATextLayer *photoTextLayer;
@property (strong, nonatomic) UIView *labelContainerView;
@property (strong, nonatomic) IBOutlet THCaptureButton *captureButton;
@property (nonatomic) BOOL maxLeft;
@property (nonatomic) BOOL maxRight;
@property (nonatomic) CGFloat videoStringWidth;
@end

@implementation THCameraModeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _maxRight = YES;
    self.cameraMode = THCameraModeVideo;

    self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    _foregroundColor = [UIColor colorWithRed:1.000 green:0.734 blue:0.006 alpha:1.000];
    _videoTextLayer = [self textLayerWithTitle:@"VIDEO"];
    _videoTextLayer.foregroundColor = self.foregroundColor.CGColor;
    _photoTextLayer = [self textLayerWithTitle:@"PHOTO"];

    CGSize size = [@"VIDEO" sizeWithAttributes:[self fontAttributes]];
    self.videoStringWidth = size.width;
    _videoTextLayer.frame = CGRectMake(0.0f, 0.0f, 40.0f, 20.0f);
    _photoTextLayer.frame = CGRectMake(60.0f, 0.0f, 50.0f, 20.0f);
    CGRect containerRect = CGRectMake(0.0f, 0.0f, 120.0, 20.0);
    _labelContainerView = [[UIView alloc] initWithFrame:containerRect];
    _labelContainerView.backgroundColor = [UIColor clearColor];
    
    [_labelContainerView.layer addSublayer:_videoTextLayer];
    [_labelContainerView.layer addSublayer:_photoTextLayer];
    _labelContainerView.backgroundColor = [UIColor clearColor];
    [self addSubview:_labelContainerView];
    
    self.labelContainerView.centerY += 8.0f;
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchMode:)];
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchMode:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:rightRecognizer];
    [self addGestureRecognizer:leftRecognizer];
}

- (void)toggleSelected {
    self.captureButton.selected = !self.captureButton.selected;
}

- (void)switchMode:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft && !self.maxLeft) {

        [UIView animateWithDuration:0.28
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.labelContainerView.frameX -= 62;
                             [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  [CATransaction disableActions];
                                                  self.photoTextLayer.foregroundColor = self.foregroundColor.CGColor;
                                                  self.videoTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
                                                  
                                              }completion:^(BOOL complete){}];
                         }
                         completion:^(BOOL complete){
							 self.cameraMode = THCameraModePhoto;
                             self.maxLeft = YES;
                             self.maxRight = NO;
						 }];

    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight && !self.maxRight) {
        [UIView animateWithDuration:0.28
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.labelContainerView.frameX += 62;
                             self.videoTextLayer.foregroundColor = self.foregroundColor.CGColor;
                             self.photoTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
                         }
                         completion:^(BOOL complete){
							 self.cameraMode = THCameraModeVideo;
                             self.maxRight = YES;
                             self.maxLeft = NO;
						 }];

    }
}

- (void)setCameraMode:(THCameraMode)cameraMode {
    if (_cameraMode != cameraMode) {
        _cameraMode = cameraMode;
        if (cameraMode == THCameraModePhoto) {
            self.captureButton.selected = NO;
            self.captureButton.captureButtonMode = THCaptureButtonModePhoto;
            self.layer.backgroundColor = [UIColor blackColor].CGColor;
        } else {
            self.captureButton.captureButtonMode = THCaptureButtonModeVideo;
            self.layer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (CATextLayer *)textLayerWithTitle:(NSString *)title {
    CATextLayer *layer = [CATextLayer layer];
    layer.string = [[NSAttributedString alloc] initWithString:title attributes:[self fontAttributes]];
    layer.contentsScale = [UIScreen mainScreen].scale;
    return layer;
}

- (NSDictionary *)fontAttributes {
    return @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:17.0f],
             NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.foregroundColor.CGColor);
    
    CGRect circleRect = CGRectMake(CGRectGetMidX(rect) - 4.0f, 2.0f, 6.0f, 6.0f);
    CGContextFillEllipseInRect(context, circleRect);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.labelContainerView.frameX = CGRectGetMidX(self.bounds) - (self.videoStringWidth / 2.0);
}

@end
