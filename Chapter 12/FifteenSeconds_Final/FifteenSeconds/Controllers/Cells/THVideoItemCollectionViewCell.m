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

#import "THVideoItemCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+THAdditions.h"

@interface THVideoItemCollectionViewCell ()
@property (strong, nonatomic) UIImageView *trimmerImageView;
@end

@implementation THVideoItemCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setUp];
	}
	return self;
}

- (void)awakeFromNib {
	[self setUp];
}

- (void)setUp {
//	UIImage *selectedImage = [[UIImage imageNamed:@"th_trimmer_ui_selected"] stretchableImageWithLeftCapWidth:17 topCapHeight:0];
//
//	UIImage *highlightedImage = [[UIImage imageNamed:@"th_trimmer_ui_highlighted"] stretchableImageWithLeftCapWidth:17 topCapHeight:0];
//
//	self.backgroundColor = [UIColor clearColor];
//	
//	_trimmerImageView = [[UIImageView alloc] initWithImage:selectedImage highlightedImage:highlightedImage];
//	_trimmerImageView.layer.shadowColor = [UIColor blackColor].CGColor;
//	_trimmerImageView.layer.shadowRadius = 3.0f;
//	_trimmerImageView.layer.shadowOpacity = 0.5f;
//	_trimmerImageView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
//	
//
//	_trimmerImageView.userInteractionEnabled = NO;
//	_trimmerImageView.hidden = YES;
//
//	[self.contentView addSubview:_trimmerImageView];
}

- (BOOL)isPointInDragHandle:(CGPoint)point {
//	CGRect handleRect = CGRectMake(self.frameWidth - 30, 0, 30, self.frameHeight);
//	BOOL contains = CGRectContainsPoint(handleRect, point);
//	return contains;
    return NO;
}

- (void)setMaxTimeRange:(CMTimeRange)maxTimeRange {
	_maxTimeRange = maxTimeRange;
	//NSLog(@"Max Time Range Set");
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	self.trimmerImageView.frame = self.bounds;
	self.trimmerImageView.hidden = !selected;
	self.trimmerImageView.highlighted = NO;
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	self.trimmerImageView.highlighted = highlighted;
}

- (void)layoutSubviews {
	self.trimmerImageView.frame = self.bounds;
}

@end
