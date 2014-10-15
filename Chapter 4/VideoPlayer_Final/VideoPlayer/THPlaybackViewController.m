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

#import "THPlaybackViewController.h"
#import "HCYoutubeParser.h"
#import "THPlayerViewController.h"
#import "UIAlertView+THAdditions.h"

#define YOUTUBE_URL @"http://www.youtube.com/watch?v=6dNryy5elc8"

#define LOCAL_SEGUE        @"localSegue"
#define STREAMING_SEGUE @"streamingSegue"

@interface THPlaybackViewController ()
@property (nonatomic, strong) NSURL *localURL;
@property (nonatomic, strong) NSURL *streamingURL;
@end

@implementation THPlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Init local asset
    self.localURL = [[NSBundle mainBundle] URLForResource:@"hubblecast" withExtension:@"m4v"];

    // Init streaming asset
    [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:YOUTUBE_URL] completeBlock:^(NSDictionary *urls, NSError *error) {
        self.streamingURL = [NSURL URLWithString:urls[@"hd720"]];
    }];
    
    //self.streamingURL = [NSURL URLWithString:YOUTUBE_URL];
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:LOCAL_SEGUE] && !self.localURL) {
        return [self alertError];
    } else if ([identifier isEqualToString:STREAMING_SEGUE] && !self.streamingURL) {
        return [self alertError];
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSURL *url = [segue.identifier isEqualToString:LOCAL_SEGUE] ? self.localURL : self.streamingURL;
    THPlayerViewController *controller = [segue destinationViewController];
    controller.assetURL = url;
}

- (BOOL)alertError {
    [UIAlertView showAlertWithTitle:@"Asset Unavailable"
                            message:@"The requested asset could not be loaded."];
    return NO;
}

@end
