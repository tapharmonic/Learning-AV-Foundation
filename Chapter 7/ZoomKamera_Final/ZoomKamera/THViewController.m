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
#import "THCameraModeView.h"
#import "THOverlayView.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface THViewController () <THCameraZoomingDelegate>
@property (nonatomic) THCameraMode cameraMode;
@property (strong, nonatomic) THCameraController *cameraController;
@property (weak, nonatomic) IBOutlet THPreviewView *previewView;
@property (weak, nonatomic) IBOutlet THOverlayView *overlayView;
@property (weak, nonatomic) IBOutlet UIButton *thumbnailButton;
@property (weak, nonatomic) IBOutlet UISlider *zoomSlider;

@end

@implementation THViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateThumbnail:)
                                                 name:THThumbnailCreatedNotification
                                               object:nil];
    self.cameraMode = THCameraModeVideo;
    self.cameraController = [[THCameraController alloc] init];
    self.overlayView.alpha = 0.0f;
    
    NSError *error;
    if ([self.cameraController setupSession:&error]) {
        self.previewView.session = self.cameraController.session;
        [self.cameraController.session addObserver:self
                                               forKeyPath:@"running"
                                                  options:NSKeyValueObservingOptionNew
                                                  context:NULL];
        [self.cameraController startSession];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }

	self.cameraController.zoomingDelegate = self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"running"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3f animations:^{
                self.overlayView.alpha = 1.0f;
            }];
            [self.cameraController.session removeObserver:self
                                                      forKeyPath:@"running"];
        });

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateThumbnail:(NSNotification *)notification {
    UIImage *image = notification.object;
    [self.thumbnailButton setBackgroundImage:image forState:UIControlStateNormal];
    self.thumbnailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnailButton.layer.borderWidth = 1.0f;
}

- (IBAction)showCameraRoll:(id)sender {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)cameraModeChanged:(id)sender {
    self.cameraMode = [sender cameraMode];
}

- (IBAction)captureOrRecord:(UIButton *)sender {
    if (self.cameraMode == THCameraModePhoto) {
        [self.cameraController captureStillImage];
    } else {
        if (!self.cameraController.isRecording) {
            [self.cameraController startRecording];
        } else {
            [self.cameraController stopRecording];
        }
        sender.selected = !sender.selected;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction)zoomToValue:(id)sender {
	[self.cameraController setZoomValue:[(UISlider *)sender value]];
}

- (IBAction)rampZoomToValue:(id)sender {
    CGFloat zoomValue = [(UIButton *)sender tag];
	[self.cameraController rampZoomToValue:zoomValue];
}

- (IBAction)cancelZoomRamp:(id)sender {
    [self.cameraController cancelZoom];
}

// Zooming Delegate Method
- (void)rampedZoomToValue:(CGFloat)value {
    self.zoomSlider.value = value;
}

@end
