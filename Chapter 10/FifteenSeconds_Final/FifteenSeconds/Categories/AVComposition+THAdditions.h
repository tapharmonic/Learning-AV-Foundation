//
//  ReutersTV
//
//  Copyright 2014 Thomson Reuters Global Resources. All rights reserved.
//  Proprietary and confidential information of TRGR.  Disclosure, use, or
//  reproduction without the written authorization of TRGR is prohibited.
//

#import <AVFoundation/AVFoundation.h>

@interface AVComposition (THAdditions)

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag;
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)flag;

@end
