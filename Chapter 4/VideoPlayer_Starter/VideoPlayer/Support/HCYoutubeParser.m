//
//  HCYoutube.m
//  YoutubeParser
//
//  Created by Simon Andersson on 6/4/12.
//  Copyright (c) 2012 Hiddencode.me. All rights reserved.
//

#import "HCYoutubeParser.h"

#define kYoutubeInfoURL      @"http://www.youtube.com/get_video_info?video_id="
#define kYoutubeThumbnailURL @"http://img.youtube.com/vi/%@/%@.jpg"
#define kYoutubeDataURL      @"http://gdata.youtube.com/feeds/api/videos/%@?alt=json"
#define kUserAgent @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"

@interface NSString (QueryString)

/**
 Parses a query string

 @return key value dictionary with each parameter as an array
 */
- (NSMutableDictionary *)dictionaryFromQueryStringComponents;


/**
 Convenient method for decoding a html encoded string
 */
- (NSString *)stringByDecodingURLFormat;

@end

@interface NSURL (QueryString)

/**
 Parses a query string of an NSURL

 @return key value dictionary with each parameter as an array
 */
- (NSMutableDictionary *)dictionaryForQueryString;

@end


@implementation NSString (QueryString)

- (NSString *)stringByDecodingURLFormat {
    NSString *result = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (NSMutableDictionary *)dictionaryFromQueryStringComponents {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    for (NSString *keyValue in [self componentsSeparatedByString:@"&"]) {
        NSArray *keyValueArray = [keyValue componentsSeparatedByString:@"="];
        if ([keyValueArray count] < 2) {
            continue;
        }

        NSString *key = [[keyValueArray objectAtIndex:0] stringByDecodingURLFormat];
        NSString *value = [[keyValueArray objectAtIndex:1] stringByDecodingURLFormat];

        NSMutableArray *results = [parameters objectForKey:key];

        if (!results) {
            results = [NSMutableArray arrayWithCapacity:1];
            [parameters setObject:results forKey:key];
        }

        [results addObject:value];
    }

    return parameters;
}

@end

@implementation NSURL (QueryString)

- (NSMutableDictionary *)dictionaryForQueryString {
    return [[self query] dictionaryFromQueryStringComponents];
}

@end

@implementation HCYoutubeParser

+ (NSString *)youtubeIDFromYoutubeURL:(NSURL *)youtubeURL {
    NSString *youtubeID = nil;
    if ([youtubeURL.host isEqualToString:@"youtu.be"]) {
        youtubeID = [[youtubeURL pathComponents] objectAtIndex:1];
    } else if ([youtubeURL.absoluteString rangeOfString:@"www.youtube.com/embed"].location != NSNotFound) {
        youtubeID = [[youtubeURL pathComponents] objectAtIndex:2];
    } else {
        youtubeID = [[[youtubeURL dictionaryForQueryString] objectForKey:@"v"] objectAtIndex:0];
    }

    return youtubeID;
}

+ (NSDictionary *)h264videosWithYoutubeID:(NSString *)youtubeID {
    if (youtubeID) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kYoutubeInfoURL, youtubeID]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
        [request setHTTPMethod:@"GET"];

        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

        if (!error) {
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

            NSMutableDictionary *parts = [responseString dictionaryFromQueryStringComponents];

            if (parts) {

                NSString *fmtStreamMapString = [[parts objectForKey:@"url_encoded_fmt_stream_map"] objectAtIndex:0];
                NSArray *fmtStreamMapArray = [fmtStreamMapString componentsSeparatedByString:@","];

                NSMutableDictionary *videoDictionary = [NSMutableDictionary dictionary];

                for (NSString *videoEncodedString in fmtStreamMapArray) {
                    NSMutableDictionary *videoComponents = [videoEncodedString dictionaryFromQueryStringComponents];
                    NSString *type = [[[videoComponents objectForKey:@"type"] objectAtIndex:0] stringByDecodingURLFormat];
                    NSString *signature = nil;

                    if (![videoComponents objectForKey:@"stereo3d"]) {
                        if ([videoComponents objectForKey:@"sig"]) {
                            signature = [[videoComponents objectForKey:@"sig"] objectAtIndex:0];
                        }

                        if (signature && [type rangeOfString:@"mp4"].length > 0) {
                            NSString *url = [[[videoComponents objectForKey:@"url"] objectAtIndex:0] stringByDecodingURLFormat];
                            url = [NSString stringWithFormat:@"%@&signature=%@", url, signature];

                            NSString *quality = [[[videoComponents objectForKey:@"quality"] objectAtIndex:0] stringByDecodingURLFormat];
                            if ([videoDictionary valueForKey:quality] == nil) {
                                [videoDictionary setObject:url forKey:quality];
                            }
                        }
                    }
                }

                return videoDictionary;
            }
        }
    }

    return nil;
}

+ (NSDictionary *)h264videosWithYoutubeURL:(NSURL *)youtubeURL {

    NSString *youtubeID = [self youtubeIDFromYoutubeURL:youtubeURL];
    return [self h264videosWithYoutubeID:youtubeID];
}

+ (void)h264videosWithYoutubeURL:(NSURL *)youtubeURL
                   completeBlock:(void (^)(NSDictionary *videoDictionary, NSError *error))completeBlock {

    NSString *youtubeID = [self youtubeIDFromYoutubeURL:youtubeURL];

    if (youtubeID) {

        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kYoutubeInfoURL, youtubeID]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
        [request setHTTPMethod:@"GET"];

        NSOperationQueue *queue = [[NSOperationQueue alloc] init];

        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (!error) {
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                NSMutableDictionary *parts = [responseString dictionaryFromQueryStringComponents];

                if (parts) {

                    NSString *fmtStreamMapString = [[parts objectForKey:@"url_encoded_fmt_stream_map"] objectAtIndex:0];
                    NSArray *fmtStreamMapArray = [fmtStreamMapString componentsSeparatedByString:@","];

                    NSMutableDictionary *videoDictionary = [NSMutableDictionary dictionary];

                    for (NSString *videoEncodedString in fmtStreamMapArray) {
                        NSMutableDictionary *videoComponents = [videoEncodedString dictionaryFromQueryStringComponents];
                        NSString *type = [[[videoComponents objectForKey:@"type"] objectAtIndex:0] stringByDecodingURLFormat];
                        NSString *signature = nil;
                        if ([videoComponents objectForKey:@"sig"]) {
                            signature = [[videoComponents objectForKey:@"sig"] objectAtIndex:0];
                        }

                        if ([type rangeOfString:@"mp4"].length > 0) {
                            NSString *url = [[[videoComponents objectForKey:@"url"] objectAtIndex:0] stringByDecodingURLFormat];
                            url = [NSString stringWithFormat:@"%@&signature=%@", url, signature];

                            NSString *quality = [[[videoComponents objectForKey:@"quality"] objectAtIndex:0] stringByDecodingURLFormat];

                            if ([videoDictionary valueForKey:quality] == nil) {
                                [videoDictionary setObject:url forKey:quality];
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeBlock(videoDictionary, nil);
                    });
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completeBlock(nil, error);
                });
            }
        }];
    }
}

+ (void)thumbnailForYoutubeURL:(NSURL *)youtubeURL
                 thumbnailSize:(YouTubeThumbnail)thumbnailSize
                 completeBlock:(void (^)(UIImage *image, NSError *error))completeBlock {

    NSString *youtubeID = [self youtubeIDFromYoutubeURL:youtubeURL];
    return [self thumbnailForYoutubeID:youtubeID thumbnailSize:thumbnailSize completeBlock:completeBlock];
}

+ (NSURL *)thumbnailUrlForYoutubeURL:(NSURL *)youtubeURL
                       thumbnailSize:(YouTubeThumbnail)thumbnailSize {
    NSURL *url = nil;

    if (youtubeURL) {

        NSString *thumbnailSizeString = nil;
        switch (thumbnailSize) {
            case YouTubeThumbnailDefault:
                thumbnailSizeString = @"default";
                break;
            case YouTubeThumbnailDefaultMedium:
                thumbnailSizeString = @"mqdefault";
                break;
            case YouTubeThumbnailDefaultHighQuality:
                thumbnailSizeString = @"hqdefault";
                break;
            case YouTubeThumbnailDefaultMaxQuality:
                thumbnailSizeString = @"maxresdefault";
                break;
            default:
                thumbnailSizeString = @"default";
                break;
        }

        NSString *youtubeID = [self youtubeIDFromYoutubeURL:youtubeURL];

        url = [NSURL URLWithString:[NSString stringWithFormat:kYoutubeThumbnailURL, youtubeID, thumbnailSizeString]];

    }

    return url;
}

+ (void)thumbnailForYoutubeID:(NSString *)youtubeID thumbnailSize:(YouTubeThumbnail)thumbnailSize completeBlock:(void (^)(UIImage *, NSError *))completeBlock {
    if (youtubeID) {

        NSString *thumbnailSizeString = nil;
        switch (thumbnailSize) {
            case YouTubeThumbnailDefault:
                thumbnailSizeString = @"default";
                break;
            case YouTubeThumbnailDefaultMedium:
                thumbnailSizeString = @"mqdefault";
                break;
            case YouTubeThumbnailDefaultHighQuality:
                thumbnailSizeString = @"hqdefault";
                break;
            case YouTubeThumbnailDefaultMaxQuality:
                thumbnailSizeString = @"maxresdefault";
                break;
            default:
                thumbnailSizeString = @"default";
                break;
        }

        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kYoutubeThumbnailURL, youtubeID, thumbnailSizeString]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
        [request setHTTPMethod:@"GET"];

        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                completeBlock(image, nil);
            }
            else {
                completeBlock(nil, error);
            }
        }];

    }
    else {

        NSDictionary *details = @{NSLocalizedDescriptionKey : @"Could not find a valid Youtube ID"};

        NSError *error = [NSError errorWithDomain:@"com.hiddencode.yt-parser" code:0 userInfo:details];

        completeBlock(nil, error);
    }
}

+ (void)detailsForYouTubeURL:(NSURL *)youtubeURL
               completeBlock:(void (^)(NSDictionary *details, NSError *error))completeBlock {
    NSString *youtubeID = [self youtubeIDFromYoutubeURL:youtubeURL];
    if (youtubeID) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kYoutubeDataURL, youtubeID]]];

        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (!error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:&error];
                if (!error) {
                    completeBlock(json, nil);
                }
                else {
                    completeBlock(nil, error);
                }
            }
            else {
                completeBlock(nil, error);
            }
        }];
    }
    else {
        NSDictionary *details = @{NSLocalizedDescriptionKey : @"Could not find a valid Youtube ID"};

        NSError *error = [NSError errorWithDomain:@"com.hiddencode.yt-parser" code:0 userInfo:details];

        completeBlock(nil, error);
    }
}

@end
