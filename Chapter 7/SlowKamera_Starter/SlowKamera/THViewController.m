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

#import "THViewController.h"
#import "THCameraController.h"
#import "THPreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "THPlayerViewController.h"
#import "UIAlertView+THAdditions.h"

@interface THViewController () <THCameraControllerDelegate>

@property (strong, nonatomic) THCameraController *cameraController;
@property (weak, nonatomic) IBOutlet THPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIView *highFPSView;
@property (weak, nonatomic) IBOutlet UILabel *highFPSLabel;

@end

@implementation THViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.highFPSView.layer.cornerRadius = 15.0f;
    self.cameraController = [[THCameraController alloc] init];

    NSError *error;
    if ([self.cameraController setupSession:&error]) {
        [self.previewView setSession:self.cameraController.captureSession];

        if ([self.cameraController cameraSupportsHighFrameRateCapture]) {
            if ([self.cameraController enableHighFrameRateCapture]) {
                self.highFPSLabel.text = @"High FPS Enabled";
            } else {
                self.highFPSLabel.text = @"Could Not Enable High FPS";
            }
        } else {
            self.highFPSLabel.text = @"High FPS Not Supported";
        }
        [self.highFPSLabel sizeToFit];
        [self.cameraController startSession];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playMovie:)
                                                 name:THMovieCreatedNotification
                                               object:nil];
}

- (void)deviceConfigurationFailedWithError:(NSError *)error {
    [UIAlertView showAlertWithTitle:@"Configuration Error"
                            message:[error localizedDescription]];
}

- (void)playMovie:(NSNotification *)notification {
    THPlayerViewController *controller = [[THPlayerViewController alloc] init];
    [controller setAssetURL:notification.object];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)toggleRecording:(UIButton *)sender {
    if (!self.cameraController.isRecording) {
        dispatch_async(dispatch_queue_create("com.tapharmonic.RecordingQueue", NULL), ^{
            [self.cameraController startRecording];
        });
    } else {
        [self.cameraController stopRecording];
    }
    sender.selected = !sender.selected;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [self.previewView updateOrientation];
}

@end
