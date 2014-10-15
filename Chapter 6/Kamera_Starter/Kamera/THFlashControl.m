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

// Code based on Apple's ExpandyButton

#import "THFlashControl.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+THAdditions.h"

static const CGFloat BUTTON_WIDTH   = 48.0f;
static const CGFloat BUTTON_HEIGHT  = 30.0;
static const CGFloat ICON_WIDTH     = 18.0f;
static const CGFloat FONT_SIZE      = 17.0f;

#define BOLD_FONT   [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:FONT_SIZE]
#define NORMAL_FONT [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:FONT_SIZE]

#define LEFT_SHRINK     CGRectMake(ICON_WIDTH, self.midY, 0.f, BUTTON_HEIGHT)
#define RIGHT_SHRINK    CGRectMake(ICON_WIDTH + BUTTON_WIDTH, 0, 0.f, BUTTON_HEIGHT)
#define MIDDLE_EXPANDED CGRectMake(ICON_WIDTH, self.midY, BUTTON_WIDTH, BUTTON_HEIGHT)

@interface THFlashControl ()

@property (nonatomic) BOOL expanded;
@property (nonatomic) CGFloat defaultWidth;
@property (nonatomic) CGFloat expandedWidth;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) CGFloat midY;

@property (strong, nonatomic) NSArray *labels;

@end

@implementation THFlashControl

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH + BUTTON_WIDTH, BUTTON_HEIGHT)];
	if (self) {
        [self setupView];
	}
	return self;
}

- (void)awakeFromNib {
    [self setupView];
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    UIImage *iconImage = [UIImage imageNamed:@"flash_icon"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:iconImage];
    imageView.frameY = (self.frameHeight - imageView.frameHeight) / 2;
    [self addSubview:imageView];
    _midY = floorf(self.frameWidth - BUTTON_HEIGHT) / 2.0f;
    _labels = [self buildLabels:@[@"Auto", @"On", @"Off"]];
    
    _defaultWidth = self.frameWidth;
    _expandedWidth = ICON_WIDTH + (BUTTON_WIDTH * self.labels.count);
    self.clipsToBounds = YES;
    
    [self addTarget:self action:@selector(selectMode:forEvent:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSArray *)buildLabels:(NSArray *)labelStrings {
	CGFloat x = ICON_WIDTH;
    BOOL first = YES;
	NSMutableArray *labels = [NSMutableArray array];
	for (NSString *string in labelStrings) {
		CGRect frame = CGRectMake(x, self.midY, BUTTON_WIDTH, BUTTON_HEIGHT);
		UILabel *label = [[UILabel alloc] initWithFrame:frame];
		label.text = string;
		label.font = NORMAL_FONT;
		label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor clearColor];
        label.textAlignment = first ? NSTextAlignmentLeft : NSTextAlignmentCenter;
        first = NO;
		[self addSubview:label];
		[labels addObject:label];
		x += BUTTON_WIDTH;
	}
    return labels;
}

- (void)selectMode:(id)sender forEvent:(UIEvent *)event {

	if (!self.expanded) {
		[self performDelegateSelectorIfSupported:@selector(flashControlWillExpand)];
		[UIView animateWithDuration:0.3 animations:^{
            self.frameWidth = self.expandedWidth;
            for (NSUInteger i = 0; i < self.labels.count; i++) {
                UILabel *label = self.labels[i];
                label.font = (i == self.selectedIndex) ? BOLD_FONT : NORMAL_FONT;
                label.frame = CGRectMake(ICON_WIDTH + (i * BUTTON_WIDTH), self.midY, BUTTON_WIDTH, BUTTON_HEIGHT);
                if (i > 0) {
                    label.textAlignment = NSTextAlignmentCenter;
                }
            }
        } completion:^(BOOL finished) {
			[self performDelegateSelectorIfSupported:@selector(flashControlDidExpand)];
		}];
	} else {

		[self performDelegateSelectorIfSupported:@selector(flashControlWillCollapse)];

		UITouch *touch = [[event allTouches] anyObject];
        for (NSUInteger i = 0; i < self.labels.count; i++) {

            UILabel *label = self.labels[i];
			CGPoint touchPoint = [touch locationInView:label];

            if ([label pointInside:touchPoint withEvent:event]) {

                self.selectedIndex = i;
                label.textAlignment = NSTextAlignmentLeft;
                
                [UIView animateWithDuration:0.2 animations:^{
                    for (NSUInteger i = 0; i < self.labels.count; i++) {
                        UILabel *label = self.labels[i];
                        if (i < self.selectedIndex) {
                            label.frame = LEFT_SHRINK;
                        } else if (i > self.selectedIndex) {
                            label.frame = RIGHT_SHRINK;
                        } else if (i == self.selectedIndex) {
                            label.frame = MIDDLE_EXPANDED;
                        }
                    }
                    self.frameWidth = self.defaultWidth;
                } completion:^(BOOL finished) {
					[self performDelegateSelectorIfSupported:@selector(flashControlDidCollapse)];
				}];
                break;
            }
        }
	}
    self.expanded = !self.expanded;
}

- (void)performDelegateSelectorIfSupported:(SEL)sel {
	if ([self.delegate respondsToSelector:sel]) {
		[self.delegate performSelector:sel withObject:nil];
	}
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;

    // Remap to fit enum values
    NSInteger mode = selectedIndex;
    if (selectedIndex == 0) {
        mode = 2;
    } else if (selectedIndex == 2) {
        mode = 0;
    }
    self.selectedMode = mode;
}

- (void)setSelectedMode:(NSInteger)selectedMode {
	if (_selectedMode != selectedMode) {
		_selectedMode = selectedMode;
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

@end
