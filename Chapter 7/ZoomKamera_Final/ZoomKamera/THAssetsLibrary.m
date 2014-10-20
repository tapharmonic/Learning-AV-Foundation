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

#import "THAssetsLibrary.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

static NSString *const THThumbnailCreatedNotification = @"THThumbnailCreated";

@interface THAssetsLibrary ()
@property (strong, nonatomic) ALAssetsLibrary *library;
@end
@implementation THAssetsLibrary

- (instancetype)init {
	self = [super init];
	if (self) {
		_library = [[ALAssetsLibrary alloc] init];
	}
	return self;
}

- (void)writeImage:(UIImage *)image completionHandler:(THAssetsLibraryWriteCompletionHandler)completionHandler {

    [self.library writeImageToSavedPhotosAlbum:image.CGImage
                              orientation:(NSInteger)image.imageOrientation
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              if (!error) {
                                  [self postThumbnailNotifification:image];
								  completionHandler(YES, nil);
                              } else {
								  completionHandler(NO, error);
                              }
                          }];

}

- (void)writeVideoAtURL:(NSURL *)videoURL
	  completionHandler:(THAssetsLibraryWriteCompletionHandler)completionHandler {

    if ([self.library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {

        ALAssetsLibraryWriteVideoCompletionBlock completionBlock;

        completionBlock = ^(NSURL *assetURL, NSError *error){
            if (error) {
				completionHandler(NO, error);
            } else {
                [self generateThumbnailForVideoAtURL:videoURL];
				completionHandler(YES, nil);
            }
        };

        [self.library writeVideoAtPathToSavedPhotosAlbum:videoURL
										 completionBlock:completionBlock];
    }
}

- (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        AVAsset *asset = [AVAsset assetWithURL:videoURL];

        AVAssetImageGenerator *imageGenerator =
			[AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        imageGenerator.maximumSize = CGSizeMake(100.0f, 0.0f);
        imageGenerator.appliesPreferredTrackTransform = YES;

        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero
                                                     actualTime:NULL
                                                          error:nil];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);

		[self postThumbnailNotifification:image];
    });
}

- (void)postThumbnailNotifification:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:THThumbnailCreatedNotification object:image];
    });
}

@end
