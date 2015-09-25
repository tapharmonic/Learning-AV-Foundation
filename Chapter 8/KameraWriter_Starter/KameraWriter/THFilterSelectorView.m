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

#import "THFilterSelectorView.h"
#import "THPhotoFilters.h"
#import "THNotifications.h"

@interface THFilterSelectorView ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) NSMutableArray *labels;
@property (weak, nonatomic) UILabel *activeLabel;
@end

@implementation THFilterSelectorView

- (void)awakeFromNib {
    [self setupLabels];
    [self setupActions];
}

- (void)setupLabels {
    NSArray *filterNames = [THPhotoFilters filterDisplayNames];
    CGRect frame = self.scrollView.bounds;
    self.labels = [NSMutableArray array];
    for (NSString *text in filterNames) {
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0f];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = text;
        [self.scrollView addSubview:label];
        frame.origin.x += frame.size.width;
        [self.labels addObject:label];
    }

    self.activeLabel = [self.labels firstObject];

    CGFloat width = frame.size.width * filterNames.count;
    self.scrollView.contentSize = CGSizeMake(width, frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
}

- (void)setupActions {
    self.leftButton.enabled = NO;
    [self.leftButton addTarget:self action:@selector(pageLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(pageRight:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)pageLeft:(id)sender {
    NSUInteger labelIndex = [self.labels indexOfObject:self.activeLabel];
    if (labelIndex > 0) {
        UILabel *label = [self.labels objectAtIndex:labelIndex - 1];
        [self.scrollView scrollRectToVisible:label.frame animated:YES];
        self.activeLabel = label;
        self.rightButton.enabled = YES;
        [self postNotificationForChange:label.text];
    }
    self.leftButton.enabled = labelIndex - 1 > 0;
}

- (void)pageRight:(id)sender {
    NSUInteger labelIndex = [self.labels indexOfObject:self.activeLabel];
    if (labelIndex < self.labels.count - 1) {
        UILabel *label = [self.labels objectAtIndex:labelIndex + 1];
        [self.scrollView scrollRectToVisible:label.frame animated:YES];
        self.activeLabel = label;
        self.leftButton.enabled = YES;
        [self postNotificationForChange:label.text];
    }
    self.rightButton.enabled = labelIndex < self.labels.count - 1;
}

- (void)postNotificationForChange:(NSString *)displayName {
    CIFilter *filter = [THPhotoFilters filterForDisplayName:displayName];
    [[NSNotificationCenter defaultCenter] postNotificationName:THFilterSelectionChangedNotification object:filter];
}

@end
