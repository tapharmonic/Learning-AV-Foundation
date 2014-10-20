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

@implementation THViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CALayer *parentLayer = self.view.layer;
    
    UIImage *image = [UIImage imageNamed:@"lavf_cover"];
    
    CALayer *imageLayer = [CALayer layer];
    // Set the layer contents to the book cover image
    imageLayer.contents = (id)image.CGImage;
    imageLayer.contentsScale = [UIScreen mainScreen].scale;
    
    // Size and position the layer
    CGFloat midX = CGRectGetMidX(parentLayer.bounds);
    CGFloat midY = CGRectGetMidY(parentLayer.bounds);
    
    imageLayer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    imageLayer.position = CGPointMake(midX, midY);
    
    // Add the image layer as a sublayer of the parent layer
    [parentLayer addSublayer:imageLayer];
    
    // Basic animation to rotate around z-axis
    CABasicAnimation *rotationAnimation =
        [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // Rotate 360 degrees over a three-second duration, repeat indefinitely
    rotationAnimation.toValue = @(2 * M_PI);
    rotationAnimation.duration = 3.0f;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    // Add and execute animation on the image layer
    [imageLayer addAnimation:rotationAnimation forKey:@"rotateAnimation"];

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
