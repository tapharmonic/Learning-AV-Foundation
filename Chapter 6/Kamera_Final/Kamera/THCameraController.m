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

#import "THCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSFileManager+THAdditions.h"

NSString *const THThumbnailCreatedNotification = @"THThumbnailCreated";

@interface THCameraController () <AVCaptureFileOutputRecordingDelegate>

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (weak, nonatomic) AVCaptureDeviceInput *activeVideoInput;

@property (strong, nonatomic) AVCaptureStillImageOutput *imageOutput;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieOutput;
@property (strong, nonatomic) NSURL *outputURL;
@end

@implementation THCameraController

- (BOOL)setupSession:(NSError **)error {

	self.captureSession = [[AVCaptureSession alloc] init];                  // 1
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;

	// Set up default camera device
	AVCaptureDevice *videoDevice =                                          // 2
        [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    AVCaptureDeviceInput *videoInput =                                      // 3
        [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {                 // 4
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        return NO;
    }

    // Setup default microphone
    AVCaptureDevice *audioDevice =                                          // 5
        [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];

    AVCaptureDeviceInput *audioInput =                                      // 6
        [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {                 // 7
            [self.captureSession addInput:audioInput];
        }
    } else {
        return NO;
    }

	// Setup the still image output
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];            // 8
    self.imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};

	if ([self.captureSession canAddOutput:self.imageOutput]) {
		[self.captureSession addOutput:self.imageOutput];
	}

    // Setup movie file output
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];             // 9

    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }

    return YES;
}

- (void)startSession {
	if (![self.captureSession isRunning]) {                                 // 1
		dispatch_async([self globalQueue], ^{
			[self.captureSession startRunning];
		});
	}
}

- (void)stopSession {
	if ([self.captureSession isRunning]) {                                  // 2
		dispatch_async([self globalQueue], ^{
			[self.captureSession stopRunning];
		});
	}
}

- (dispatch_queue_t)globalQueue {
	return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

#pragma mark - Device Configuration

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position { // 1
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {                              // 2
		if (device.position == position) {
			return device;
		}
	}
	return nil;
}

- (AVCaptureDevice *)activeCamera {                                         // 3
    return self.activeVideoInput.device;
}

- (AVCaptureDevice *)inactiveCamera {                                       // 4
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {  // 5
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (BOOL)canSwitchCameras {                                                  // 6
    return self.cameraCount > 1;
}

- (NSUInteger)cameraCount {                                                 // 7
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (BOOL)switchCameras {

    if (![self canSwitchCameras]) {                                         // 1
        return NO;
    }

    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];                   // 2

    AVCaptureDeviceInput *videoInput =
    [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];

    if (videoInput) {
        [self.captureSession beginConfiguration];                           // 3

        [self.captureSession removeInput:self.activeVideoInput];            // 4

        if ([self.captureSession canAddInput:videoInput]) {                 // 5
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }

        [self.captureSession commitConfiguration];                          // 6

    } else {
        [self.delegate deviceConfigurationFailedWithError:error];           // 7
        return NO;
    }

    return YES;
}


#pragma mark - Flash and Torch Modes

- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode {
    return [[self activeCamera] flashMode];
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {

    AVCaptureDevice *device = [self activeCamera];

    if (device.flashMode != flashMode &&
        [device isFlashModeSupported:flashMode]) {

        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {

    AVCaptureDevice *device = [self activeCamera];

    if (device.torchMode != torchMode &&
        [device isTorchModeSupported:torchMode]) {

        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

#pragma mark - Focus Methods

- (BOOL)cameraSupportsTapToFocus {                                          // 1
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point {                                       // 2

    AVCaptureDevice *device = [self activeCamera];

    if (device.isFocusPointOfInterestSupported &&                           // 3
        [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {

        NSError *error;
        if ([device lockForConfiguration:&error]) {                         // 4
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

#pragma mark - Exposure Methods

- (BOOL)cameraSupportsTapToExpose {                                         // 1
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

// Define KVO context pointer for observing 'adjustingExposure" device property.
static const NSString *THCameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point {

    AVCaptureDevice *device = [self activeCamera];

    AVCaptureExposureMode exposureMode =
    AVCaptureExposureModeContinuousAutoExposure;

    if (device.isExposurePointOfInterestSupported &&                        // 2
        [device isExposureModeSupported:exposureMode]) {

        NSError *error;
        if ([device lockForConfiguration:&error]) {                         // 3

            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;

            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self                                    // 4
                         forKeyPath:@"adjustingExposure"
                            options:NSKeyValueObservingOptionNew
                            context:&THCameraAdjustingExposureContext];
            }

            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (context == &THCameraAdjustingExposureContext) {                     // 5

        AVCaptureDevice *device = (AVCaptureDevice *)object;

        if (!device.isAdjustingExposure &&                                  // 6
            [device isExposureModeSupported:AVCaptureExposureModeLocked]) {

            [object removeObserver:self                                     // 7
                        forKeyPath:@"adjustingExposure"
                           context:&THCameraAdjustingExposureContext];

            dispatch_async(dispatch_get_main_queue(), ^{                    // 8
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    [self.delegate deviceConfigurationFailedWithError:error];
                }
            });
        }

    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)resetFocusAndExposureModes {

    AVCaptureDevice *device = [self activeCamera];

    AVCaptureExposureMode exposureMode =
    AVCaptureExposureModeContinuousAutoExposure;

    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;

    BOOL canResetFocus = [device isFocusPointOfInterestSupported] &&        // 1
    [device isFocusModeSupported:focusMode];

    BOOL canResetExposure = [device isExposurePointOfInterestSupported] &&  // 2
    [device isExposureModeSupported:exposureMode];

    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);                          // 3

    NSError *error;
    if ([device lockForConfiguration:&error]) {

        if (canResetFocus) {                                                // 4
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }

        if (canResetExposure) {                                             // 5
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        
        [device unlockForConfiguration];
        
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
    }
}


#pragma mark - Image Capture Methods

- (void)captureStillImage {

    AVCaptureConnection *connection =                                   
        [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];

    if (connection.isVideoOrientationSupported) {                       
        connection.videoOrientation = [self currentVideoOrientation];
    }

    id handler = ^(CMSampleBufferRef sampleBuffer, NSError *error) {
        if (sampleBuffer != NULL) {

            NSData *imageData =
                [AVCaptureStillImageOutput
                    jpegStillImageNSDataRepresentation:sampleBuffer];

            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [self writeImageToAssetsLibrary:image];                         // 1

        } else {
            NSLog(@"NULL sampleBuffer: %@", [error localizedDescription]);
        }
    };
    // Capture still image
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection
                                                  completionHandler:handler];
}

- (void)writeImageToAssetsLibrary:(UIImage *)image {

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];              // 2

    [library writeImageToSavedPhotosAlbum:image.CGImage                     // 3
                              orientation:(NSInteger)image.imageOrientation // 4
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              if (!error) {
                                  [self postThumbnailNotifification:image]; // 5
                              } else {
                                  id message = [error localizedDescription];
                                  NSLog(@"Error: %@", message);
                              }
                          }];
}

- (void)postThumbnailNotifification:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:THThumbnailCreatedNotification object:image];
    });
}

#pragma mark - Video Capture Methods

- (BOOL)isRecording {                                                       // 1
    return self.movieOutput.isRecording;
}

- (void)startRecording {

    if (![self isRecording]) {

		AVCaptureConnection *videoConnection =                              // 2
            [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];

		if ([videoConnection isVideoOrientationSupported]) {                // 3
			videoConnection.videoOrientation = self.currentVideoOrientation;
		}

		if ([videoConnection isVideoStabilizationSupported]) {              // 4
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
                videoConnection.enablesVideoStabilizationWhenAvailable = YES;
            } else {
                videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
		}

        AVCaptureDevice *device = [self activeCamera];

        if (device.isSmoothAutoFocusSupported) {                            // 5
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = NO;
                [device unlockForConfiguration];
            } else {
                [self.delegate deviceConfigurationFailedWithError:error];
            }
        }

        self.outputURL = [self uniqueURL];                                  // 6
		[self.movieOutput startRecordingToOutputFileURL:self.outputURL      // 8
                                      recordingDelegate:self];

    }
}

- (CMTime)recordedDuration {
    return self.movieOutput.recordedDuration;
}

- (NSURL *)uniqueURL {                                                      // 7

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath =
        [fileManager temporaryDirectoryWithTemplateString:@"kamera.XXXXXX"];

    if (dirPath) {
        NSString *filePath =
            [dirPath stringByAppendingPathComponent:@"kamera_movie.mov"];
        return [NSURL fileURLWithPath:filePath];
    }

    return nil;
}

- (void)stopRecording {                                                     // 9
    if ([self isRecording]) {
        [self.movieOutput stopRecording];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error {
	if (error) {                                                            // 1
        [self.delegate mediaCaptureFailedWithError:error];
	} else {
        [self writeVideoToAssetsLibrary:[self.outputURL copy]];
	}
    self.outputURL = nil;
}

- (void)writeVideoToAssetsLibrary:(NSURL *)videoURL {

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];              // 2

    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {   // 3

        ALAssetsLibraryWriteVideoCompletionBlock completionBlock;

        completionBlock = ^(NSURL *assetURL, NSError *error){               // 4
            if (error) {
                [self.delegate assetLibraryWriteFailedWithError:error];
            } else {
                [self generateThumbnailForVideoAtURL:videoURL];
            }
        };

        [library writeVideoAtPathToSavedPhotosAlbum:videoURL                // 8
                                    completionBlock:completionBlock];
    }
}

- (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL {

    dispatch_async([self globalQueue], ^{

        AVAsset *asset = [AVAsset assetWithURL:videoURL];

        AVAssetImageGenerator *imageGenerator =                             // 5
            [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        imageGenerator.maximumSize = CGSizeMake(100.0f, 0.0f);
        imageGenerator.appliesPreferredTrackTransform = YES;

        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero // 6
                                                     actualTime:NULL
                                                          error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);

        dispatch_async(dispatch_get_main_queue(), ^{                        // 7
            [self postThumbnailNotifification:image];
        });
    });
}

#pragma mark - Recoding Destination URL

- (AVCaptureVideoOrientation)currentVideoOrientation {

    AVCaptureVideoOrientation orientation;

    switch ([UIDevice currentDevice].orientation) {                         // 3
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }

    return orientation;
}


@end

