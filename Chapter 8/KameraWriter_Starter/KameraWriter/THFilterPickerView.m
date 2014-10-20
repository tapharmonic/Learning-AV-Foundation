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

#import "THFilterPickerView.h"
#import "THNotifications.h"

@interface THFilterPickerView ()
@property (strong, nonatomic) NSArray *thumbnails;
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation THFilterPickerView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {

	}
	return self;
}

- (void)setupView {
	_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	[self addSubview:_scrollView];
}
//
//- (void)setFilterThumbnailViews:(NSArray *)thumbnails {
//
//    CGFloat currentX = 0.0f;
//
//	UIView *firstView = [thumbnails firstObject];
//    CGSize size = firstView.frame.size;
//
//    CGFloat width = size.width * thumbnails.count;
//    self.scrollView.contentSize = CGSizeMake(width, size.height);
//
//    for (NSUInteger i = 0; i < thumbnails.count; i++) {
//        THThumbnail *timedImage = self.thumbnails[i];
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.adjustsImageWhenHighlighted = NO;
//        [button setBackgroundImage:timedImage.image forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(imageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        button.frame = CGRectMake(currentX, 0, imageSize.width, imageSize.height);
//        button.tag = i;
//        [self.scrollView addSubview:button];
//        currentX += imageSize.width;
//    }
//
//}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildScrubber:(NSNotification *)notification {

}

//- (void)imageButtonTapped:(UIButton *)sender {
//    THThumbnail *image = self.thumbnails[sender.tag];
//    if (image) {
//        if ([self.superview respondsToSelector:@selector(setCurrentTime:)]) {
//            [(THOverlayView *)self.superview setCurrentTime:CMTimeGetSeconds(image.time)];
//        }
//    }
//}

@end
