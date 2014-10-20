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

#import "THAppDelegate.h"
#import "THMainViewController.h"
#import "THVideoPickerViewController.h"
#import "THAudioPickerViewController.h"
#import "THTimelineViewController.h"
#import "THPlayerViewController.h"
#import "THTabBarController.h"
#import "THTabBarView.h"

@interface THAppDelegate ()
@property (weak, nonatomic) THMainViewController *mainViewController;
@end

@implementation THAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[UIApplication sharedApplication] setStatusBarHidden:YES];

	self.mainViewController = (THMainViewController *)self.window.rootViewController;

    //	// Change the tabbar's background and selection image through the appearance proxy
    UIImage *bgImage = [[UIImage imageNamed:@"tb_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
    [[THTabBarView appearance] setBackgroundImage:bgImage];

	UIEdgeInsets insets;
	insets = UIEdgeInsetsZero;
	UIImage *navbarImage = [[UIImage imageNamed:@"app_navbar_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
	[[UINavigationBar appearance] setBackgroundImage:navbarImage forBarMetrics:UIBarMetricsDefault];

    return YES;
}

+ (THAppDelegate *)sharedDelegate {
	return (THAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)prepareMainViewController {
	self.mainViewController.timelineViewController = [self childViewControllerOfType:[THTimelineViewController class]];
	self.mainViewController.playerViewController = [self childViewControllerOfType:[THPlayerViewController class]];

	self.mainViewController.videoPickerViewController = [self childViewControllerOfType:[THVideoPickerViewController class]];
	self.mainViewController.audioPickerViewController = [self childViewControllerOfType:[THAudioPickerViewController class]];

	self.mainViewController.videoPickerViewController.playbackMediator = self.mainViewController;
	self.mainViewController.audioPickerViewController.playbackMediator = self.mainViewController;
	self.mainViewController.playerViewController.playbackMediator = self.mainViewController;

	NSAssert(self.mainViewController.timelineViewController, @"THTimelineViewController not set.");
	NSAssert(self.mainViewController.playerViewController, @"THPlayerViewController not set.");
	NSAssert(self.mainViewController.videoPickerViewController, @"THVideoPickerViewController not set.");
	NSAssert(self.mainViewController.audioPickerViewController, @"THAudioPickerViewController not set.");
}

- (id)childViewControllerOfType:(Class)type {
	for (UIViewController *controller in self.mainViewController.childViewControllers) {
		if ([controller isKindOfClass:type]) {
			return controller;
		}
		if ([controller isKindOfClass:[THTabBarController class]]) {
			for (id childController in controller.childViewControllers) {
				UINavigationController *navcontroller = (UINavigationController *)childController;
				if ([navcontroller.topViewController isKindOfClass:type]) {
					return navcontroller.topViewController;
				}
			}
		}
	}
	NSAssert1(NO, @"Requested controller of type %@ was not found.", NSStringFromClass(type));
	return nil;
}

@end
