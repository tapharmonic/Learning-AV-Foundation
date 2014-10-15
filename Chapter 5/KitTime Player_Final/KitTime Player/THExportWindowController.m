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

#import "THExportWindowController.h"
#import "NSTimer+Additions.h"

@interface THExportWindowController ()
@property (strong) NSTimer *timer;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property CGFloat progress;
@end

@implementation THExportWindowController

- (id)init {
    self = [super initWithWindowNibName:@"THExportWindow"];
    return self;
}

- (id)initWithWindowNibName:(NSString *)windowNibName {
    return [self init];
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

- (IBAction)cancelExport:(id)sender {
	if (self.delegate) {
        [self.delegate exportDidCancel];
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)setExportSession:(AVAssetExportSession *)exportSession {
	_exportSession = exportSession;
    __weak THExportWindowController *weakSelf = self;
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeating:YES firing:^{
        weakSelf.progressIndicator.doubleValue = weakSelf.exportSession.progress;
    }];
}

@end
