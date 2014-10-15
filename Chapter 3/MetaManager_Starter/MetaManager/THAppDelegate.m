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
#import "THMainWindowController.h"
#import "NSFileManager+DirectoryLocations.h"

@interface THAppDelegate ()
@property (strong) THMainWindowController *controller;
@end

@implementation THAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {

    [self copyMediaItems];

    _controller = [[THMainWindowController alloc] init];
    [_controller showWindow:nil];
}

- (void)copyMediaItems {
    NSString *appSupport = [[NSFileManager defaultManager] applicationSupportDirectory];
    NSURL *rootURL = [NSURL fileURLWithPath:appSupport];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:rootURL
                                                      includingPropertiesForKeys:nil
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:nil];
    if (contents.count == 0) {
        NSArray *items = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"Media"];
        [items enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
            NSString *filePath = [appSupport stringByAppendingPathComponent:[path lastPathComponent]];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            NSError *error;
            BOOL result = [[NSFileManager defaultManager] copyItemAtPath:path toPath:filePath error:&error];
            if (!result) {
                NSLog(@"Error %@", [error localizedDescription]);
            }
        }];
    }
}

- (IBAction)resetMediaItems:(id)sender {
    NSString *appSupport = [[NSFileManager defaultManager] applicationSupportDirectory];
    [[NSFileManager defaultManager] removeItemAtPath:appSupport error:nil];
    [self copyMediaItems];
    [self.controller reloadData];
}

@end
