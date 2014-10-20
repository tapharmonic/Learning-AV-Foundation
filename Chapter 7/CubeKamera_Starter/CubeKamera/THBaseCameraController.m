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

#import "THBaseCameraController.h"

NSString *const THCameraErrorDomain = @"com.tapharmonic.THCameraErrorDomain";
NSString *const THThumbnailCreatedNotification = @"THThumbnailCreated";

@interface THBaseCameraController ()

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (weak, nonatomic) AVCaptureDeviceInput *activeVideoInput;

@end

@implementation THBaseCameraController

- (instancetype)init {
	self = [super init];
	if (self) {
	}
	return self;
}

- (BOOL)setupSession:(NSError **)error {

	self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = [self sessionPreset];

	if (![self setupSessionInputs:error]) {
		return NO;
	}

	if (![self setupSessionOutputs:error]) {
		return NO;
	}

    return YES;
}

- (NSString *)sessionPreset {
	return AVCaptureSessionPresetHigh;
}

- (BOOL)setupSessionInputs:(NSError **)error {

	// Set up default camera device
	AVCaptureDevice *videoDevice =
		[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    AVCaptureDeviceInput *videoInput =
		[AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Failed to add video input."};
			*error = [NSError errorWithDomain:THCameraErrorDomain
										 code:THCameraErrorFailedToAddInput
									 userInfo:userInfo];
			return NO;
		}
    } else {
        return NO;
    }

	return YES;
}

- (BOOL)setupSessionOutputs:(NSError **)error {
    return NO;
}

- (void)startSession {
	if (![self.captureSession isRunning]) {
        [self.captureSession startRunning];
	}
}

- (void)stopSession {
	if ([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
	}
}

#pragma mark - Device Configuration

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {
		if (device.position == position) {
			return device;
		}
	}
	return nil;
}

- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}

- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}

- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (BOOL)switchCameras {

    if (![self canSwitchCameras]) {
        return NO;
    }

    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];

    AVCaptureDeviceInput *videoInput =
		[AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];

    if (videoInput) {
        [self.captureSession beginConfiguration];

        [self.captureSession removeInput:self.activeVideoInput];

        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }

        [self.captureSession commitConfiguration];

    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
        return NO;
    }

    return YES;
}

@end
