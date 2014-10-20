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

    // Listing 9.9

}

- (void)monitorExportProgress {

    // Listing 9.10

    // Listing 9.11

}

- (void)writeExportedVideoToAssetsLibrary {

    // Listing 9.11
    
}

- (NSURL *)exportURL {
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
