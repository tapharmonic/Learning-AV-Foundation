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

#import "THPreviewView.h"

@interface THPreviewView ()

    // Listing 7.9

@end

@implementation THPreviewView

+ (Class)layerClass {

    // Listing 7.9

    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {

    // Listing 7.10

}

- (AVCaptureSession*)session {

    // Listing 7.9

    return nil;
}

- (void)setSession:(AVCaptureSession *)session {

    // Listing 7.10

}

- (AVCaptureVideoPreviewLayer *)previewLayer {

    // Listing 7.9

    return nil;
}

- (void)didDetectFaces:(NSArray *)faces {

    // Listing 7.11

    // Listing 7.12

    // Listing 7.13

}

- (NSArray *)transformedFacesFromFaces:(NSArray *)faces {

    // Listing 7.11

    return nil;
}

- (CALayer *)makeFaceLayer {

    // Listing 7.12

    return nil;
}

// Rotate around Z-axis
- (CATransform3D)transformForRollAngle:(CGFloat)rollAngleInDegrees {

    // Listing 7.13

    return CATransform3DIdentity;
}

// Rotate around Y-axis
- (CATransform3D)transformForYawAngle:(CGFloat)yawAngleInDegrees {

    // Listing 7.13

    return CATransform3DIdentity;
}

- (CATransform3D)orientationTransform {

    // Listing 7.13

    return CATransform3DIdentity;
}

// The clang pragmas can be removed when you're finished with the project.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused"

static CGFloat THDegreesToRadians(CGFloat degrees) {

    // Listing 7.13

    return 0.0f;
}

static CATransform3D CATransform3DMakePerspective(CGFloat eyePosition) {

    // Listing 7.10

    return CATransform3DIdentity;

}
#pragma clang diagnostic pop

@end
