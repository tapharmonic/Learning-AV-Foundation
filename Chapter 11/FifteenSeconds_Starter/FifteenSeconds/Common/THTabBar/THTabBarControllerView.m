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

#import "THTabBarControllerView.h"
#import "UIView+THAdditions.h"
#import <QuartzCore/QuartzCore.h>

#define TAB_BAR_HEIGHT 49

@interface THTabBarControllerView ()
@property(strong, nonatomic) THTabBarView *tabBarView;
@property(strong, nonatomic) UIView *contentView;
@end

@implementation THTabBarControllerView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _tabBarView = [[THTabBarView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.tabBarView];
        _tabBarAnchor = THTabBarAnchorBottom;
    }
    return self;
}

- (void)setTabBarAnchor:(THTabBarAnchor)tabBarAnchor {
    _tabBarAnchor = tabBarAnchor;
    if (self.tabBarAnchor == THTabBarViewAnchorTop) {
        _tabBarView.frame = CGRectMake(0, 0, self.bounds.size.width, TAB_BAR_HEIGHT);
        _tabBarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    } else {
        _tabBarView.frame = CGRectMake(0, self.bounds.size.height - TAB_BAR_HEIGHT, self.bounds.size.width, TAB_BAR_HEIGHT);
        _tabBarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    }
	_contentView.frame = [self contentFrameForCurrentAnchorPosition];
    [self setNeedsLayout];
}

- (CGRect)contentFrameForCurrentAnchorPosition {
    CGRect frame;
    if (self.tabBarAnchor == THTabBarAnchorTop) {
        frame = CGRectMake(0, TAB_BAR_HEIGHT, self.bounds.size.width, self.bounds.size.height - self.tabBarView.bounds.size.height);
    } else {
        frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - self.tabBarView.bounds.size.height);
    }
    return frame;
}

- (void)setContentView:(UIView *)newContentView animated:(BOOL)animated options:(THTabBarAnimationOption)options {
    if (!_contentView) {
        // Content view must be set by simple assignment.  Do not retain!!
        newContentView.frame = [self contentFrameForCurrentAnchorPosition];
        _contentView = newContentView;
        [self addSubview:_contentView];
        [self sendSubviewToBack:_contentView];
    } else {

        UIView *oldContentView = _contentView;

		newContentView.frame = [self contentFrameForCurrentAnchorPosition];
		_contentView = newContentView;
		[self addSubview:_contentView];
		[self sendSubviewToBack:_contentView];
		[oldContentView removeFromSuperview];
    }
}

- (void)layoutSubviews {
    self.contentView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height - TAB_BAR_HEIGHT);
	self.tabBarView.frame = CGRectMake(0.0f, self.bounds.size.height - TAB_BAR_HEIGHT, self.bounds.size.width, TAB_BAR_HEIGHT);
}

@end
