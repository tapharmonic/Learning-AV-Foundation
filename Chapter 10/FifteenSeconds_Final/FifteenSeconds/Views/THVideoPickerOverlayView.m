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

#import "THVideoPickerOverlayView.h"
#import "UIView+THAdditions.h"

#define BUTTON_WIDTH 44.0f
#define BUTTON_HEIGHT 44.0f
#define STOP_INSETS UIEdgeInsetsMake(0, 0, 0, 0)
#define PLAY_INSETS UIEdgeInsetsMake(0, 2, 0, 0)

@implementation THVideoPickerOverlayView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		_addButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_playButton = [UIButton buttonWithType:UIButtonTypeCustom];

		UIImage *bgImage = [UIImage imageNamed:@"dark_button_background"];
		[_addButton setBackgroundImage:bgImage forState:UIControlStateNormal];
		[_playButton setBackgroundImage:bgImage forState:UIControlStateNormal];
		[_addButton setImage:[UIImage imageNamed:@"tp_add_media_icon"] forState:UIControlStateNormal];
		[_playButton setImage:[UIImage imageNamed:@"tp_play_icon"] forState:UIControlStateNormal];
		[_playButton setImage:[UIImage imageNamed:@"tp_stop_icon"] forState:UIControlStateSelected];
		[_playButton setImageEdgeInsets:PLAY_INSETS];
		[self addSubview:_addButton];
		[self addSubview:_playButton];
	}
	return self;
}

- (void)layoutSubviews {
	CGFloat yPos = (self.boundsHeight - BUTTON_HEIGHT) / 2;
	self.addButton.frame = CGRectMake(CGRectGetMidX(self.bounds) - 10 - BUTTON_WIDTH, yPos, BUTTON_WIDTH, BUTTON_HEIGHT);
	self.playButton.frame = CGRectMake(CGRectGetMidX(self.bounds) + 10, yPos, BUTTON_WIDTH, BUTTON_HEIGHT);
}

@end
