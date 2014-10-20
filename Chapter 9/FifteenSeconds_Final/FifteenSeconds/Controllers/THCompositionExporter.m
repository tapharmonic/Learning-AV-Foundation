//
//  THExporter.m
//  FifteenSeconds
//
//  Created by Bob McCune on 4/20/14.
//  Copyright (c) 2014 TapHarmonic, LLC. All rights reserved.
//

#import "THCompositionExporter.h"
#import "UIAlertView+THAdditions.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface THCompositionExporter ()
@property (strong, nonatomic) id <THComposition> composition;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@end

@implementation THCompositionExporter

- (instancetype)initWithComposition:(id <THComposition>)composition {

    self = [super init];
    if (self) {
        _composition = composition;
    }
    return self;
}

- (void)beginExport {

    self.exportSession = [self.composition makeExportable];                 // 1
    self.exportSession.outputURL = [self exportURL];
    self.exportSession.outputFileType = AVFileTypeMPEG4;

    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{        // 2

        dispatch_async(dispatch_get_main_queue(), ^{                        // 1
            AVAssetExportSessionStatus status = self.exportSession.status;
            if (status == AVAssetExportSessionStatusCompleted) {
                [self writeExportedVideoToAssetsLibrary];
            } else {
                [UIAlertView showAlertWithTitle:@"Export Failed"
                                        message:@"The request export failed."];
            }
        });
    }];

    self.exporting = YES;                                                   // 3
    [self monitorExportProgress];                                           // 4
}

- (void)monitorExportProgress {
    double delayInSeconds = 0.1;
    int64_t delta = (int64_t)delayInSeconds * NSEC_PER_SEC;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delta);

    dispatch_after(popTime, dispatch_get_main_queue(), ^{                   // 1

        AVAssetExportSessionStatus status = self.exportSession.status;

        if (status == AVAssetExportSessionStatusExporting) {                // 2

            self.progress = self.exportSession.progress;
            [self monitorExportProgress];                                   // 3

        } else {
            self.exporting = NO;
        }
    });
}

- (void)writeExportedVideoToAssetsLibrary {
    NSURL *exportURL = self.exportSession.outputURL;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportURL]) {  // 3

        [library writeVideoAtPathToSavedPhotosAlbum:exportURL               // 4
                                    completionBlock:^(NSURL *assetURL,
                                                      NSError *error) {

            if (error) {                                                    // 5
                NSString *message = @"Unable to write to Photos library.";
                [UIAlertView showAlertWithTitle:@"Write Failed"
                                        message:message];
            }

            [[NSFileManager defaultManager] removeItemAtURL:exportURL       // 6
                                                      error:nil];
        }];
    } else {
        NSLog(@"Video could not be exported to assets library.");
    }
    self.exportSession = nil;
}

- (NSURL *)exportURL {                                                      // 5
    NSString *filePath = nil;
    NSUInteger count = 0;
    do {
        filePath = NSTemporaryDirectory();
        NSString *numberString = count > 0 ?
            [NSString stringWithFormat:@"-%li", (unsigned long) count] : @"";
        NSString *fileNameString =
            [NSString stringWithFormat:@"Masterpiece-%@.m4v", numberString];
        filePath = [filePath stringByAppendingPathComponent:fileNameString];
        count++;
    } while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);

    return [NSURL fileURLWithPath:filePath];
}

@end
