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

#import "THConvertingView.h"
#import "ITProgressIndicator.h"

@implementation THConvertingView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    CGFloat size = 40.0f;
    CGFloat x = (self.frame.size.width - size) / 2;
    CGFloat y = (self.frame.size.height - size) / 2;
    NSRect rect = NSMakeRect(x, y, size, size);
    ITProgressIndicator *progressView = [[ITProgressIndicator alloc] initWithFrame:rect];
    progressView.color = [NSColor whiteColor];
    progressView.lengthOfLine = 10.0f;
    progressView.numberOfLines = 12;
    progressView.widthOfLine = 2.0f;
    progressView.animationDuration = 1.2;
    progressView.innerMargin = 10.0f;
    [self addSubview:progressView];
}

- (void)drawRect:(NSRect)dirtyRect {
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColorWithColor(context, [NSColor blackColor].CGColor);
    CGContextFillRect(context, dirtyRect);
}

@end
