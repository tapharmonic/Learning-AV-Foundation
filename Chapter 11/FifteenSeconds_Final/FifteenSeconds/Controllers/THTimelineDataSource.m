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

#import "THTimelineDataSource.h"

#import "THVideoItemCollectionViewCell.h"
#import "THTransitionCollectionViewCell.h"
#import "THAudioItemCollectionViewCell.h"
#import "THTimelineItemViewModel.h"
#import "THTimelineItemCell.h"
#import "THCompositionLayer.h"
#import "THModels.h"
#import "THTransitionViewController.h"
#import "THFunctions.h"

static NSString * const THVideoItemCollectionViewCellID		= @"THVideoItemCollectionViewCell";
static NSString * const THTransitionCollectionViewCellID	= @"THTransitionCollectionViewCell";
static NSString * const THTitleItemCollectionViewCellID		= @"THTitleItemCollectionViewCell";
static NSString * const THAudioItemCollectionViewCellID		= @"THAudioItemCollectionViewCell";

@interface THTimelineDataSource () <THTransitionViewControllerDelegate>
@property (weak, nonatomic) THTimelineViewController *controller;
@property (strong, nonatomic) UIPopoverController *transitionPopoverController;
@end

@implementation THTimelineDataSource

+ (id)dataSourceWithController:(THTimelineViewController *)controller {
	return [[self alloc] initWithController:controller];
}

- (id)initWithController:(THTimelineViewController *)controller {
	self = [super init];
	if (self) {
		_controller = controller;
        [self resetTimeline];
	}
	return self;
}

- (void)clearTimeline {
    self.timelineItems = [NSMutableArray array];
}

- (void)resetTimeline {
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[NSMutableArray array]];
    [items addObject:[NSMutableArray array]];
    [items addObject:[NSMutableArray array]];
    [items addObject:[NSMutableArray array]];

    self.timelineItems = items;
}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return self.timelineItems.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.timelineItems[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	NSString *cellID = [self cellIDForIndexPath:indexPath];
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.contentView.frame = cell.bounds;
    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;

	if ([cellID isEqualToString:THVideoItemCollectionViewCellID]) {
		[self configureVideoItemCell:(THVideoItemCollectionViewCell *)cell withItemAtIndexPath:indexPath];

	} else if ([cellID isEqualToString:THAudioItemCollectionViewCellID]) {
		[self configureAudioItemCell:(THAudioItemCollectionViewCell *)cell withItemAtIndexPath:indexPath];

	} else if ([cellID isEqualToString:THTransitionCollectionViewCellID]) {
		THTransitionCollectionViewCell *transCell = (THTransitionCollectionViewCell *)cell;
		THVideoTransition *transition = self.timelineItems[indexPath.section][indexPath.row];
		transCell.button.transitionType = transition.type;

	} else if ([cellID isEqualToString:THTitleItemCollectionViewCellID]) {
		[self configureTitleItemCell:(THTimelineItemCell *)cell withItemAtIndexPath:indexPath];
	}
	return cell;
}

- (void)configureVideoItemCell:(THVideoItemCollectionViewCell *)cell withItemAtIndexPath:(NSIndexPath *)indexPath {
	THTimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
	THVideoItem *item = (THVideoItem *)model.timelineItem;
	cell.maxTimeRange = item.timeRange;
	cell.itemView.label.text = item.title;
	cell.itemView.backgroundColor = [UIColor colorWithRed:0.523 green:0.641 blue:0.851 alpha:1.000];
}

- (void)configureAudioItemCell:(THAudioItemCollectionViewCell *)cell withItemAtIndexPath:(NSIndexPath *)indexPath {
	THTimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
	if (indexPath.section == THMusicTrack) {
		THAudioItem *item = (THAudioItem *)model.timelineItem;
		cell.volumeAutomationView.audioRamps = item.volumeAutomation;
		cell.volumeAutomationView.duration = item.timeRange.duration;
		cell.itemView.backgroundColor = [UIColor colorWithRed:0.361 green:0.724 blue:0.366 alpha:1.000];
	} else {
		cell.volumeAutomationView.audioRamps = nil;
		cell.volumeAutomationView.duration = kCMTimeZero;
		cell.itemView.backgroundColor = [UIColor colorWithRed:0.992 green:0.785 blue:0.106 alpha:1.000];
	}
}

- (void)configureTitleItemCell:(THTimelineItemCell *)cell withItemAtIndexPath:(NSIndexPath *)indexPath {
	THTimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
	THCompositionLayer *layer = (THCompositionLayer *)model.timelineItem;
	cell.itemView.label.text = layer.identifier;
	cell.itemView.backgroundColor = [UIColor colorWithRed:0.741 green:0.556 blue:1.000 alpha:1.000];
}

- (NSString *)cellIDForIndexPath:(NSIndexPath *)indexPath {
	if (self.controller.transitionsEnabled && indexPath.section == 0) {
		// Video items are at odd indexes, transitions are at even indexes
		return (indexPath.item % 2 == 0) ? THVideoItemCollectionViewCellID : THTransitionCollectionViewCellID;
	} else if (indexPath.section == 0) {
		return THVideoItemCollectionViewCellID;
	} else if (indexPath.section == 1) {
		return THTitleItemCollectionViewCellID;
	} else if (indexPath.section == 2 || indexPath.section == 3) {
		return THAudioItemCollectionViewCellID;
	}
	return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didAdjustToWidth:(CGFloat)width forItemAtIndexPath:(NSIndexPath *)indexPath {
	THTimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
	if (width <= model.maxWidthInTimeline) {
		model.widthInTimeline = width;
	}
}

- (void)collectionView:(UICollectionView *)collectionView didAdjustToPosition:(CGPoint)position forItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == THCommentaryTrack || indexPath.section == THTitleTrack) {
		THTimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
		model.positionInTimeline = position;
		[model updateTimelineItem];
        if (indexPath.section == THCommentaryTrack) {
            [self.controller updateMusicTrackVolumeAutomation];
        }
        [self.controller.collectionView reloadData];
	}
}

- (CGFloat)collectionView:(UICollectionView *)collectionView widthForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (self.controller.transitionsEnabled && indexPath.section == 0 && indexPath.item > 0) {
		if (indexPath.item % 2 != 0) {
			return 32.0f;
		}
	}
	THTimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
	return model.widthInTimeline;
}

- (CGPoint)collectionView:(UICollectionView *)collectionView positionForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == THCommentaryTrack || indexPath.section == THTitleTrack) {
		THTimelineItemViewModel *model = self.timelineItems[indexPath.section][indexPath.row];
		return model.positionInTimeline;
	}
	return CGPointZero;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canAdjustToPosition:(CGPoint)point forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == THCommentaryTrack) {
        CMTime time = THGetTimeForOrigin(point.x, THTimelineWidth / THTimelineSeconds);
        CMTime fadeInEnd = CMTimeAdd(THDefaultFadeInOutTime, THDefaultDuckingFadeInOutTime);
        CMTime fadeOutBegin = CMTimeSubtract(CMTimeMake((int64_t)THTimelineSeconds, 1), fadeInEnd);
        return CMTIME_COMPARE_INLINE(time, >=, fadeInEnd) && CMTIME_COMPARE_INLINE(time, <=, fadeOutBegin);
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	id selectedItem = self.timelineItems[indexPath.section][indexPath.item];
	if ([selectedItem isKindOfClass:[THVideoTransition class]]) {
		[self configureTransition:selectedItem atIndexPath:indexPath];
	}
}

- (void)configureTransition:(THVideoTransition *)transition atIndexPath:(NSIndexPath *)indexPath {

	THTransitionViewController *transitionController = [THTransitionViewController controllerWithTransition:transition];
	transitionController.delegate = self;
	self.transitionPopoverController = [[UIPopoverController alloc] initWithContentViewController:transitionController];

	UICollectionViewCell *cell = [self.controller.collectionView cellForItemAtIndexPath:indexPath];
	[self.transitionPopoverController presentPopoverFromRect:cell.frame
												 inView:self.controller.view
							   permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)transitionSelected {
	[self.transitionPopoverController dismissPopoverAnimated:YES];
	self.transitionPopoverController = nil;
	[self.controller.collectionView reloadData];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section == 0 && !self.controller.transitionsEnabled;
}

- (void)collectionView:(UICollectionView *)collectionView didMoveMediaItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableArray *items = self.timelineItems[fromIndexPath.section];
	if (fromIndexPath.item == toIndexPath.item) {
		NSLog(@"FUBAR:  Attempting to move: %li to %li.", (long)fromIndexPath.item, (long)toIndexPath.item);
		NSAssert(NO, @"Attempting to make invalid move.");
	}
	[items exchangeObjectAtIndex:fromIndexPath.item withObjectAtIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)theCollectionView layout:(UICollectionViewLayout *)theLayout itemAtIndexPath:(NSIndexPath *)theFromIndexPath shouldMoveToIndexPath:(NSIndexPath *)theToIndexPath {
	return theFromIndexPath.section == theToIndexPath.section;
}

- (void)collectionView:(UICollectionView *)collectionView willDeleteItemAtIndexPath:(NSIndexPath *)indexPath {
	[self.timelineItems[indexPath.section] removeObjectAtIndex:indexPath.row];
}

@end
