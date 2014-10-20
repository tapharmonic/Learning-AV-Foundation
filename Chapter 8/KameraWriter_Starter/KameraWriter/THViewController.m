//
//  MIT License
//
//  Copyright (c) 2015 Bob McCune http://bobmccune.com/
//  Copyright (c) 2015 TapHarmonic, LLC http://tapharmonic.com/
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
#import <GLKit/GLKit.h>
#import "THCameraController.h"
#import "THPreviewView.h"
#import "THContextManager.h"
#import "THOverlayView.h"
#import "THPhotoFilters.h"

@interface THViewController ()
@property (strong, nonatomic) THCameraController *controller;
@property (strong, nonatomic) THPreviewView *previewView;
@property (weak, nonatomic) IBOutlet THOverlayView *overlayView;
@end

@implementation THViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.controller = [[THCameraController alloc] init];

	CGRect frame = self.view.bounds;
    EAGLContext *eaglContext = [THContextManager sharedInstance].eaglContext;
    self.previewView = [[THPreviewView alloc] initWithFrame:frame context:eaglContext];
	self.previewView.filter = [THPhotoFilters defaultFilter];

    self.controller.imageTarget = self.previewView;

	self.previewView.coreImageContext = [THContextManager sharedInstance].ciContext;
	[self.view insertSubview:self.previewView belowSubview:self.overlayView];

	NSError *error;
	if ([self.controller setupSession:&error]) {
		[self.controller startSession];
	} else {
		NSLog(@"Error: %@", [error localizedDescription]);
	}
}

- (IBAction)captureOrRecord:(UIButton *)sender {
    if (!self.controller.isRecording) {
        dispatch_async(dispatch_queue_create("com.tapharmonic.kamera", NULL), ^{
            [self.controller startRecording];
        });
    } else {
        [self.controller stopRecording];
    }
    sender.selected = !sender.selected;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
