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

#import "THMovieWriter.h"
#import <AVFoundation/AVFoundation.h>
#import "THContextManager.h"
#import "THFunctions.h"
#import "THPhotoFilters.h"
#import "THNotifications.h"

static NSString *const THVideoFilename = @"movie.mov";

@interface THMovieWriter ()

@property (strong, nonatomic) AVAssetWriter *assetWriter;                   // 1
@property (strong, nonatomic) AVAssetWriterInput *assetWriterVideoInput;
@property (strong, nonatomic) AVAssetWriterInput *assetWriterAudioInput;
@property (strong, nonatomic)
    AVAssetWriterInputPixelBufferAdaptor *assetWriterInputPixelBufferAdaptor;

@property (strong, nonatomic) dispatch_queue_t dispatchQueue;

@property (weak, nonatomic) CIContext *ciContext;
@property (nonatomic) CGColorSpaceRef colorSpace;
@property (strong, nonatomic) CIFilter *activeFilter;

@property (strong, nonatomic) NSDictionary *videoSettings;
@property (strong, nonatomic) NSDictionary *audioSettings;

@property (nonatomic) BOOL firstSample;

@end

@implementation THMovieWriter

- (id)initWithVideoSettings:(NSDictionary *)videoSettings
			  audioSettings:(NSDictionary *)audioSettings
              dispatchQueue:(dispatch_queue_t)dispatchQueue {

	self = [super init];
	if (self) {
		_videoSettings = videoSettings;
		_audioSettings = audioSettings;
		_dispatchQueue = dispatchQueue;

        _ciContext = [THContextManager sharedInstance].ciContext;           // 3
		_colorSpace = CGColorSpaceCreateDeviceRGB();

        _activeFilter = [THPhotoFilters defaultFilter];
        _firstSample = YES;

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];    // 4
        [nc addObserver:self
               selector:@selector(filterChanged:)
                   name:THFilterSelectionChangedNotification
                 object:nil];
	}
	return self;
}

- (void)dealloc {
	CGColorSpaceRelease(_colorSpace);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)filterChanged:(NSNotification *)notification {
    self.activeFilter = [notification.object copy];
}

- (void)startWriting {
    dispatch_async(self.dispatchQueue, ^{                                   // 1

        NSError *error = nil;

        NSString *fileType = AVFileTypeQuickTimeMovie;
        self.assetWriter =                                                  // 2
            [AVAssetWriter assetWriterWithURL:[self outputURL]
                                     fileType:fileType
                                        error:&error];
        if (!self.assetWriter || error) {
            NSString *formatString = @"Could not create AVAssetWriter: %@";
            NSLog(@"%@", [NSString stringWithFormat:formatString, error]);
            return;
        }

        self.assetWriterVideoInput =                                        // 3
            [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                           outputSettings:self.videoSettings];

        self.assetWriterVideoInput.expectsMediaDataInRealTime = YES;

        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
		self.assetWriterVideoInput.transform =                              // 4
            THTransformForDeviceOrientation(orientation);

		NSDictionary *attributes = @{                                       // 5
			(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
			(id)kCVPixelBufferWidthKey : self.videoSettings[AVVideoWidthKey],
			(id)kCVPixelBufferHeightKey : self.videoSettings[AVVideoHeightKey],
			(id)kCVPixelFormatOpenGLESCompatibility : (id)kCFBooleanTrue
		};

        self.assetWriterInputPixelBufferAdaptor =                           // 6
            [[AVAssetWriterInputPixelBufferAdaptor alloc]
                initWithAssetWriterInput:self.assetWriterVideoInput
             sourcePixelBufferAttributes:attributes];


		if ([self.assetWriter canAddInput:self.assetWriterVideoInput]) {    // 7
			[self.assetWriter addInput:self.assetWriterVideoInput];
		} else {
			NSLog(@"Unable to add video input.");
			return;
		}

        self.assetWriterAudioInput =                                        // 8
            [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio
                                           outputSettings:self.audioSettings];

        self.assetWriterAudioInput.expectsMediaDataInRealTime = YES;

        if ([self.assetWriter canAddInput:self.assetWriterAudioInput]) {    // 9
            [self.assetWriter addInput:self.assetWriterAudioInput];
        } else {
            NSLog(@"Unable to add audio input.");
        }

		self.isWriting = YES;                                              // 10
        self.firstSample = YES;
    });
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    if (!self.isWriting) {
        return;
    }
    
    CMFormatDescriptionRef formatDesc =                                     // 1
        CMSampleBufferGetFormatDescription(sampleBuffer);
    
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDesc);

    if (mediaType == kCMMediaType_Video) {

        CMTime timestamp =
            CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        if (self.firstSample) {                                             // 2
            if ([self.assetWriter startWriting]) {
                [self.assetWriter startSessionAtSourceTime:timestamp];
            } else {
                NSLog(@"Failed to start writing.");
            }
            self.firstSample = NO;
        }
        
        CVPixelBufferRef outputRenderBuffer = NULL;
        
        CVPixelBufferPoolRef pixelBufferPool =
            self.assetWriterInputPixelBufferAdaptor.pixelBufferPool;
        
        OSStatus err = CVPixelBufferPoolCreatePixelBuffer(NULL,             // 3
                                                          pixelBufferPool,
                                                          &outputRenderBuffer);
        if (err) {
            NSLog(@"Unable to obtain a pixel buffer from the pool.");
            return;
        }

        CVPixelBufferRef imageBuffer =                                      // 4
            CMSampleBufferGetImageBuffer(sampleBuffer);

        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer
                                                       options:nil];

        [self.activeFilter setValue:sourceImage forKey:kCIInputImageKey];

        CIImage *filteredImage = self.activeFilter.outputImage;

        if (!filteredImage) {
            filteredImage = sourceImage;
        }

        [self.ciContext render:filteredImage                                // 5
               toCVPixelBuffer:outputRenderBuffer
                        bounds:filteredImage.extent
                    colorSpace:self.colorSpace];


        if (self.assetWriterVideoInput.readyForMoreMediaData) {             // 6
            if (![self.assetWriterInputPixelBufferAdaptor
                            appendPixelBuffer:outputRenderBuffer
                         withPresentationTime:timestamp]) {
                NSLog(@"Error appending pixel buffer.");
            }
        }
        
        CVPixelBufferRelease(outputRenderBuffer);
        
    }
    else if (!self.firstSample && mediaType == kCMMediaType_Audio) {        // 7
        if (self.assetWriterAudioInput.isReadyForMoreMediaData) {
            if (![self.assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                NSLog(@"Error appending audio sample buffer.");
            }
        }
    }

}

- (void)stopWriting {

	self.isWriting = NO;                                                    // 1

    dispatch_async(self.dispatchQueue, ^{

        [self.assetWriter finishWritingWithCompletionHandler:^{             // 2

            if (self.assetWriter.status == AVAssetWriterStatusCompleted) {
                dispatch_async(dispatch_get_main_queue(), ^{                // 3
                    NSURL *fileURL = [self.assetWriter outputURL];
                    [self.delegate didWriteMovieAtURL:fileURL];
                });
            } else {
                NSLog(@"Failed to write movie: %@", self.assetWriter.error);
            }
        }];
    });
}

- (NSURL *)outputURL {
    NSString *filePath =
        [NSTemporaryDirectory() stringByAppendingPathComponent:THVideoFilename];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    return url;
}

@end
