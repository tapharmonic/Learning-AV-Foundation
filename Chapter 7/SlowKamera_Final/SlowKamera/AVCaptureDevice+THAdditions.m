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

#import "AVCaptureDevice+THAdditions.h"
#import "THError.h"

@interface THQualityOfService : NSObject

@property(strong, nonatomic, readonly) AVCaptureDeviceFormat *format;
@property(strong, nonatomic, readonly) AVFrameRateRange *frameRateRange;
@property(nonatomic, readonly) BOOL isHighFrameRate;

+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format
               frameRateRange:(AVFrameRateRange *)frameRateRange;

- (BOOL)isHighFrameRate;

@end

@implementation THQualityOfService

+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format
               frameRateRange:(AVFrameRateRange *)frameRateRange {

    return [[self alloc] initWithFormat:format frameRateRange:frameRateRange];
}

- (instancetype)initWithFormat:(AVCaptureDeviceFormat *)format
                frameRateRange:(AVFrameRateRange *)frameRateRange {
    self = [super init];
    if (self) {
        _format = format;
        _frameRateRange = frameRateRange;
    }
    return self;
}

- (BOOL)isHighFrameRate {
    return self.frameRateRange.maxFrameRate > 30.0f;
}

@end

@implementation AVCaptureDevice (THAdditions)

- (BOOL)supportsHighFrameRateCapture {
    if (![self hasMediaType:AVMediaTypeVideo]) {                            // 1
        return NO;
    }
    return [self findHighestQualityOfService].isHighFrameRate;              // 2
}

- (BOOL)enableMaxFrameRateCapture:(NSError **)error {

    THQualityOfService *qos = [self findHighestQualityOfService];

    if (!qos.isHighFrameRate) {                                             // 1
        if (error) {
            NSString *message = @"Device does not support high FPS capture";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message};

            NSUInteger code = THCameraErrorHighFrameRateCaptureNotSupported;

            *error = [NSError errorWithDomain:THCameraErrorDomain
                                         code:code
                                     userInfo:userInfo];
        }
        return NO;
    }


    if ([self lockForConfiguration:error]) {                                // 2

        CMTime minFrameDuration = qos.frameRateRange.minFrameDuration;

        self.activeFormat = qos.format;                                     // 3
        self.activeVideoMinFrameDuration = minFrameDuration;                // 4
        self.activeVideoMaxFrameDuration = minFrameDuration;

        [self unlockForConfiguration];
        return YES;
    }
    return NO;
}

- (THQualityOfService *)findHighestQualityOfService {

    AVCaptureDeviceFormat *maxFormat = nil;
    AVFrameRateRange *maxFrameRateRange = nil;

    for (AVCaptureDeviceFormat *format in self.formats) {

        FourCharCode codecType =                                            // 3
            CMVideoFormatDescriptionGetCodecType(format.formatDescription);

        if (codecType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) { // 4

            NSArray *frameRateRanges = format.videoSupportedFrameRateRanges;

            for (AVFrameRateRange *range in frameRateRanges) {              // 5
                if (range.maxFrameRate > maxFrameRateRange.maxFrameRate) {
                    maxFormat = format;
                    maxFrameRateRange = range;
                }
            }
        }
    }

    return [THQualityOfService qosWithFormat:maxFormat                      // 6
                              frameRateRange:maxFrameRateRange];

}

@end
