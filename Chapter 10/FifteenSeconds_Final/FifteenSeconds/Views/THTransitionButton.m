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

#import "THTransitionButton.h"

@interface THTransitionButton ()
@property (nonatomic) NSDictionary *typeToNameMapping;
@end

@implementation THTransitionButton

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setUp];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self setUp];
	}
	return self;
}

- (void)setUp {
	_transitionType = THVideoTransitionTypeNone;
	self.typeToNameMapping = (@{
							  @(THVideoTransitionTypeNone) : @"trans_btn_bg_none",
							  @(THVideoTransitionTypeDissolve) : @"trans_btn_bg_xfade",
							  @(THVideoTransitionTypePush) : @"trans_btn_bg_push"
							  });

	[self updateBackgroundImage];
}

- (void)setTransitionType:(THVideoTransitionType)transitionType {
	if (_transitionType != transitionType) {
		_transitionType = transitionType;
		[self updateBackgroundImage];
	}
}

- (void)updateBackgroundImage {
	NSString *imageName = self.typeToNameMapping[@(self.transitionType)];
	[self setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

@end
