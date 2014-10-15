//
//  HCYoutube.h
//  YoutubeParser
//
//  Created by Simon Andersson on 6/4/12.
//  Copyright (c) 2012 Hiddencode.me. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import <Foundation/Foundation.h>

typedef enum {
    YouTubeThumbnailDefault,
    YouTubeThumbnailDefaultMedium,
    YouTubeThumbnailDefaultHighQuality,
    YouTubeThumbnailDefaultMaxQuality
} YouTubeThumbnail;

@interface HCYoutubeParser : NSObject

/**
 Method for retrieving the youtube ID from a youtube URL
 
 @param youtubeURL the the complete youtube video url, either youtu.be or youtube.com
 @return string with desired youtube id
 */
+ (NSString *)youtubeIDFromYoutubeURL:(NSURL *)youtubeURL;

/**
 Method for retreiving a iOS supported video link
 
 @param youtubeURL the the complete youtube video url
 @return dictionary with the available formats for the selected video
 
 */
+ (NSDictionary *)h264videosWithYoutubeURL:(NSURL *)youtubeURL;

/**
 Method for retreiving an iOS supported video link
 
 @param youtubeID the id of the youtube video
 @return dictionary with the available formats for the selected video
 
 */
+ (NSDictionary *)h264videosWithYoutubeID:(NSString *)youtubeID;

/**
 Block based method for retreiving a iOS supported video link
 
 @param youtubeURL the the complete youtube video url
 @param completeBlock the block which is called on completion
 
 */
+ (void)h264videosWithYoutubeURL:(NSURL *)youtubeURL
                   completeBlock:(void (^)(NSDictionary *videoDictionary, NSError *error))completeBlock;

/**
 Method for retreiving a thumbnail url for wanted youtube id
 
 @param youtubeURL the complete youtube video id
 @param thumbnailSize the wanted size of the thumbnail
 */
+ (NSURL *)thumbnailUrlForYoutubeURL:(NSURL *)youtubeURL
                       thumbnailSize:(YouTubeThumbnail)thumbnailSize;

/**
 Method for retreiving a thumbnail for wanted youtube url
 
 @param youtubeURL the the complete youtube video url
 @param thumbnailSize the wanted size of the thumbnail
 @param completeBlock the block which is called on completion
 */
+ (void)thumbnailForYoutubeURL:(NSURL *)youtubeURL
                 thumbnailSize:(YouTubeThumbnail)thumbnailSize
                 completeBlock:(void (^)(UIImage *image, NSError *error))completeBlock;

/**
 Method for retreiving a thumbnail for wanted youtube id
 
 @param youtubeURL the complete youtube video id
 @param thumbnailSize the wanted size of the thumbnail
 @param completeBlock the block which is called on completion
 */
+ (void)thumbnailForYoutubeID:(NSString *)youtubeID
                thumbnailSize:(YouTubeThumbnail)thumbnailSize
                completeBlock:(void (^)(UIImage *image, NSError *error))completeBlock;


/**
 Method for retreiving all the details of a youtube video
 
 @param youtubeURL the the complete youtube video url
 @param completeBlock the block which is called on completion
 
 */
+ (void)detailsForYouTubeURL:(NSURL *)youtubeURL
               completeBlock:(void (^)(NSDictionary *details, NSError *error))completeBlock;
@end
