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
#import "THAssetsLibrary.h"
#import "NSFileManager+THAdditions.h"

NSString *const THThumbnailCreatedNotification = @"THThumbnailCreated";
NSString *const THMovieCreatedNotification = @"THMovieCreated";

@interface THBaseCameraController () <AVCaptureFileOutputRecordingDelegate>

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (weak, nonatomic) AVCaptureDeviceInput *activeVideoInput;

@property (strong, nonatomic) AVCaptureStillImageOutput *imageOutput;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieOutput;
@property (strong, nonatomic) NSURL *outputURL;
@property (strong, nonatomic) THAssetsLibrary *library;
@property (nonatomic) dispatch_queue_t videoQueue;

@end

@implementation THBaseCameraController

- (instancetype)init {
    self = [super init];
    if (self) {
        _library = [[THAssetsLibrary alloc] init];
        _videoQueue = dispatch_queue_create("com.tapharmonic.VideoQueue", NULL);
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
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to add video input."};
            *error = [NSError errorWithDomain:THCameraErrorDomain
                                         code:THCameraErrorFailedToAddInput
                                     userInfo:userInfo];
            return NO;
        }
    } else {
        return NO;
    }

    // Setup default microphone
    AVCaptureDevice *audioDevice =
        [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];

    AVCaptureDeviceInput *audioInput =
        [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        } else {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to add audio input."};
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
    // Setup the still image output
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};

    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    } else {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to still image output."};
        *error = [NSError errorWithDomain:THCameraErrorDomain
                                     code:THCameraErrorFailedToAddOutput
                                 userInfo:userInfo];
        return NO;
    }

    // Setup movie file output
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];

    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    } else {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to still video output."};
        *error = [NSError errorWithDomain:THCameraErrorDomain
                                     code:THCameraErrorFailedToAddOutput
                                 userInfo:userInfo];
        return NO;
    }

    return YES;
}

- (void)startSession {
    dispatch_async(self.videoQueue, ^{
        if (![self.captureSession isRunning]) {
            [self.captureSession startRunning];
        }
    });
}

- (void)stopSession {
    dispatch_async(self.videoQueue, ^{
        if ([self.captureSession isRunning]) {
            [self.captureSession stopRunning];
        }
    });

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


#pragma mark - Image Capture Methods

- (void)captureStillImage {
    dispatch_async(self.videoQueue, ^{

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
                [self.library writeImage:image
                       completionHandler:^(BOOL success, NSError *writeError) {
                           if (!success) {
                               NSLog(@"Handle Error: %@", writeError);
                           }

                       }];

            } else {
                NSLog(@"NULL sampleBuffer: %@", [error localizedDescription]);
            }
        };
        // Capture still image
        [self.imageOutput
            captureStillImageAsynchronouslyFromConnection:connection
                                        completionHandler:handler];

    });
}

#pragma mark - Video Capture Methods

- (BOOL)isRecording {
    return self.movieOutput.isRecording;
}

- (void)startRecording {

    dispatch_async(self.videoQueue, ^{

        if ([self isRecording]) {
            return;
        }

        AVCaptureConnection *videoConnection =
            [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];

        if ([videoConnection isVideoOrientationSupported]) {
            videoConnection.videoOrientation = self.currentVideoOrientation;
        }

        if ([videoConnection isVideoStabilizationSupported]) {
            // videoConnection.enablesVideoStabilizationWhenAvailable = YES;
            // ^^ the above property has been deprecated. Use the following for the equivalent
            // effect on iOS 8+.
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeStandard;
        }

        AVCaptureDevice *device = [self activeCamera];

        if (device.isSmoothAutoFocusSupported) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = NO;
                [device unlockForConfiguration];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate deviceConfigurationFailedWithError:error];
                });
            }
        }

        self.outputURL = [self uniqueURL];
        [self.movieOutput startRecordingToOutputFileURL:self.outputURL
                                      recordingDelegate:self];
    });
}

- (NSURL *)uniqueURL {

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

- (void)stopRecording {
    dispatch_async(self.videoQueue, ^{
        if ([self isRecording]) {
            [self.movieOutput stopRecording];
        }
    });
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)              captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                    fromConnections:(NSArray *)connections
                              error:(NSError *)error {
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate mediaCaptureFailedWithError:error];
        });

    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:THMovieCreatedNotification object:outputFileURL];
    }
    self.outputURL = nil;
}

- (void)reportAssetWriteFailureWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate assetLibraryWriteFailedWithError:error];
    });
}

#pragma mark - Recoding Destination URL

- (AVCaptureVideoOrientation)currentVideoOrientation {

    AVCaptureVideoOrientation orientation;

    switch ([UIDevice currentDevice].orientation) {
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
