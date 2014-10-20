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

#import "THTabBarView.h"

#define BUTTON_MARGIN 10.0f
#define BUTTON_WIDTH 56.0f

@interface THTabBarView ()
@property (strong, nonatomic) UIImageView *backgroundImageView;
@end
@implementation THTabBarView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		_backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
		[self addSubview:_backgroundImageView];
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)image {
	self.backgroundImageView.image = image;
}

- (void)setTabBarButtons:(NSArray *)buttons {
    // Remove existing items
    for (id button in _tabBarButtons) {
        [button removeFromSuperview];
    }

    _tabBarButtons = [buttons copy];

    if (_tabBarButtons.count > 0) {
        [[_tabBarButtons objectAtIndex:0] setSelected:YES];
        self.selectedTabBarButton = [_tabBarButtons objectAtIndex:0];
        if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:didSelectTabAtIndex:)]) {
            [self.delegate tabBar:self didSelectTabAtIndex:0];
        }
    }

    for (id button in _tabBarButtons) {
        [button addTarget:self action:@selector(selectTabIfAllowed:) forControlEvents:UIControlEventTouchDown];
    }

    [self setNeedsLayout];
}

- (NSUInteger)selectedTabBarButtonIndex {
    return [self.tabBarButtons indexOfObject:self.selectedTabBarButton];
}

- (void)layoutSubviews {
	self.backgroundImageView.frame = self.bounds;
	
    // Calculate the total width from the left edge of the leftmost button to the right edge of the rightmost button
    CGFloat buttonLayoutWidth = (BUTTON_WIDTH * self.tabBarButtons.count) + (BUTTON_MARGIN * (self.tabBarButtons.count - 1));

    // Calculate the X-origin point at which to start drawing the buttons
    CGFloat startOrigin = ((self.bounds.size.width - buttonLayoutWidth) / 2);

    CGFloat buttonMargin = BUTTON_MARGIN;

    // Create tab bar button item frame
    CGRect frame = CGRectMake(startOrigin, self.bounds.origin.y + 5.0, BUTTON_WIDTH, self.bounds.size.height - 8);
    for (id button in self.tabBarButtons) {
        [button setFrame:frame];
        [self addSubview:button];
        frame.origin.x += (frame.size.width + buttonMargin);
    }
}

- (void)selectTabIfAllowed:(id)sender {
    if ([self.delegate tabBar:self canSelectTabAtIndex:[self.tabBarButtons indexOfObject:sender]]) {
        // Only trigger selection change if new tab selected
        if (self.selectedTabBarButton != sender) {
            for (id item in self.tabBarButtons) {
                [item setSelected:NO];
            }
            [sender setSelected:YES];
            self.selectedTabBarButton = sender;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:didSelectTabAtIndex:)]) {
            [self.delegate tabBar:self didSelectTabAtIndex:[self.tabBarButtons indexOfObject:sender]];
        }
    }
}

@end
