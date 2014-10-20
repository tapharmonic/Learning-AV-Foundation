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

#import "THTimelineLayout.h"
#import "THVideoItemCollectionViewCell.h"
#import "UIView+THAdditions.h"
#import "THTimelineLayoutAttributes.h"

typedef enum {
	THPanDirectionLeft = 0,
	THPanDirectionRight
} THPanDirection;

typedef enum {
	THDragModeNone = 0,
	THDragModeMove,
	THDragModeTrim
} THDragMode;

#pragma mark - Defines

#define DEFAULT_TRACK_HEIGHT 80.0f
#define DEFAULT_CLIP_SPACING 0.0f
#define TRANSITION_CONTROL_HW 32.0f
#define VERTICAL_PADDING 4.0f
#define DEFAULT_INSETS UIEdgeInsetsMake(4.0f, 5.0f, 5.0f, 5.0f)

#pragma mark - THTimelineLayout Extension

@interface THTimelineLayout () <UIGestureRecognizerDelegate>
@property (nonatomic) CGSize contentSize;
@property (strong, nonatomic) NSDictionary *calculatedLayout;
@property (strong, nonatomic) NSDictionary *initialLayout;
@property (strong, nonatomic) NSArray *updates;
@property (nonatomic) CGFloat scaleUnit;
@property (nonatomic) THPanDirection panDirection;
@property (weak, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (weak, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (weak, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) UIImageView *draggableImageView;
@property (nonatomic) BOOL swapInProgress;
@property (nonatomic) THDragMode dragMode;
@property (nonatomic) BOOL trimming;
@end

#pragma mark - Implementation

@implementation THTimelineLayout


#pragma mark - Initialization

- (id)init {
	self = [super init];
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
	_trackInsets = DEFAULT_INSETS;
	_trackHeight = DEFAULT_TRACK_HEIGHT;
	_clipSpacing = DEFAULT_CLIP_SPACING;
	_reorderingAllowed = YES;
	_dragMode = THDragModeTrim;
}

#pragma mark - Property Setters

- (void)setTrackHeight:(CGFloat)trackHeight {
	if (_trackHeight != trackHeight) {
		_trackHeight = trackHeight;
		[self invalidateLayout];
	}
}

- (void)setTrackInsets:(UIEdgeInsets)trackInsets {
	if (!UIEdgeInsetsEqualToEdgeInsets(_trackInsets, trackInsets)) {
		_trackInsets = trackInsets;
		[self invalidateLayout];
	}
}

- (void)setClipSpacing:(CGFloat)clipSpacing {
	if (_clipSpacing != clipSpacing) {
		_clipSpacing = clipSpacing;
		[self invalidateLayout];
	}
}

- (void)setReorderingAllowed:(BOOL)reorderingAllowed {
	if (_reorderingAllowed != reorderingAllowed) {
		_reorderingAllowed = reorderingAllowed;
		self.panGestureRecognizer.enabled = reorderingAllowed;
		self.longPressGestureRecognizer.enabled = reorderingAllowed;
		[self invalidateLayout];
	}
}

#pragma mark - Collection View Layout Overrides

+ (Class)layoutAttributesClass {
    return [THTimelineLayoutAttributes class];
}

- (void)prepareLayout {

    NSMutableDictionary *layoutDictionary = [NSMutableDictionary dictionary];

	CGFloat xPos = self.trackInsets.left;
	CGFloat yPos = 0;

	CGFloat maxTrackWidth = 0.0f;

	id <UICollectionViewDelegateTimelineLayout> delegate = (id <UICollectionViewDelegateTimelineLayout>) self.collectionView.delegate;

	NSUInteger trackCount = [self.collectionView numberOfSections];
    for (NSInteger track = 0; track < trackCount; track++) {

        for (NSInteger item = 0, itemCount = [self.collectionView numberOfItemsInSection:track]; item < itemCount; item++) {

			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:track];

            THTimelineLayoutAttributes *attributes = (THTimelineLayoutAttributes *)
			[UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];


			CGFloat width = [delegate collectionView:self.collectionView widthForItemAtIndexPath:indexPath];
			CGPoint position = [delegate collectionView:self.collectionView positionForItemAtIndexPath:indexPath];

			if (position.x > 0.0f) {
				xPos = position.x;
			}

            attributes.frame = CGRectMake(xPos, yPos + self.trackInsets.top, width, self.trackHeight - self.trackInsets.bottom);

			// Hacky, revisit
			if (width == TRANSITION_CONTROL_HW) {
				CGRect rect = attributes.frame;
				rect.origin.y += ((rect.size.height - TRANSITION_CONTROL_HW) / 2) + VERTICAL_PADDING;
				rect.origin.x -= (TRANSITION_CONTROL_HW / 2);
				attributes.frame = rect;
				attributes.zIndex = 1;
			}

			if ([self.selectedIndexPath isEqual:indexPath]) {
				attributes.hidden = YES;
			}

            layoutDictionary[indexPath] = attributes;

			if (width != TRANSITION_CONTROL_HW) {
				xPos += (width + self.clipSpacing);
			}

        }

		if (xPos > maxTrackWidth) {
			maxTrackWidth = xPos;
		}

		xPos = self.trackInsets.left;
		yPos += self.trackHeight;
    }

	self.contentSize = CGSizeMake(maxTrackWidth, trackCount * self.trackHeight);

	self.calculatedLayout = layoutDictionary;
}

- (CGSize)collectionViewContentSize {
	return self.contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {

	NSMutableArray *allAttributesInRect = [NSMutableArray arrayWithCapacity:self.calculatedLayout.count];

	for (NSIndexPath *indexPath in self.calculatedLayout) {
		UICollectionViewLayoutAttributes *attributes = self.calculatedLayout[indexPath];
		if (CGRectIntersectsRect(rect, attributes.frame)) {
			[allAttributesInRect addObject:attributes];
		}
	}

    return allAttributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	return self.calculatedLayout[indexPath];
}


#pragma mark - Set up Gesture Recognizers

- (void)awakeFromNib {
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
	UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	longPressRecognizer.minimumPressDuration = 0.1f;
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	tapRecognizer.numberOfTapsRequired = 2;

	// Set up dependencies with built-in recognizers
	for (UIGestureRecognizer *recognizer in self.collectionView.gestureRecognizers) {
		if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
			[recognizer requireGestureRecognizerToFail:panRecognizer];
		} else if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
			[recognizer requireGestureRecognizerToFail:longPressRecognizer];
		}
	}

	self.panGestureRecognizer = panRecognizer;
	self.longPressGestureRecognizer = longPressRecognizer;
	self.tapGestureRecognizer = tapRecognizer;

	self.panGestureRecognizer.delegate = self;
	self.longPressGestureRecognizer.delegate = self;
	self.tapGestureRecognizer.delegate = self;
	
	[self.collectionView addGestureRecognizer:panRecognizer];
	[self.collectionView addGestureRecognizer:longPressRecognizer];
	[self.collectionView addGestureRecognizer:tapRecognizer];

}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherRecognizer {
	return YES;
}

#pragma mark - Double Tap Handler

// Don't have time to do this right.  Use double tap to delete cell.
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
	CGPoint location = [recognizer locationInView:self.collectionView];
	NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
	id <UICollectionViewDelegateTimelineLayout> delegate = (id <UICollectionViewDelegateTimelineLayout>) self.collectionView.delegate;
	[delegate collectionView:self.collectionView willDeleteItemAtIndexPath:indexPath];
	[self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - Long Press Handler

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {

	if (recognizer.state == UIGestureRecognizerStateBegan) {

		self.dragMode = THDragModeMove;
		
		CGPoint location = [recognizer locationInView:self.collectionView];
		NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];

		if (!indexPath) {
			return;
		}

		self.selectedIndexPath = indexPath;
		[self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];

		UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
		cell.highlighted = YES;

		self.draggableImageView = [cell toImageView];
		self.draggableImageView.frame = cell.frame;

		[self.collectionView addSubview:self.draggableImageView];
	}

	if (recognizer.state == UIGestureRecognizerStateEnded) {

		UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:self.selectedIndexPath];
		[UIView animateWithDuration:0.15 animations:^{
			self.draggableImageView.frame = attributes.frame;
		} completion:^(BOOL finished) {
			[self invalidateLayout];
			[UIView animateWithDuration:0.2 animations:^{
				self.draggableImageView.alpha = 0.0f;

			} completion:^(BOOL complete) {

				UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
				cell.selected = YES;
				[self.draggableImageView removeFromSuperview];
				self.draggableImageView = nil;
			}];

			self.selectedIndexPath = nil;
			self.dragMode = THDragModeTrim;
		}];

	}
}

#pragma mark - Pan Gesture Handler

- (void)handleDrag:(UIPanGestureRecognizer *)recognizer {

	CGPoint location = [recognizer locationInView:self.collectionView];
	CGPoint translation = [recognizer translationInView:self.collectionView];
	self.panDirection = translation.x > 0 ? THPanDirectionRight : THPanDirectionLeft;

	NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];

	THVideoItemCollectionViewCell *cell = (THVideoItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];

	if (recognizer.state == UIGestureRecognizerStateBegan) {
		[self invalidateLayout];
	}

	if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {

		// Dragging, not trimming
		if (self.dragMode == THDragModeMove) {
			CGPoint centerPoint = self.draggableImageView.center;
			if (self.selectedIndexPath.section == 0) {
				self.draggableImageView.center = CGPointMake(centerPoint.x + translation.x, centerPoint.y + translation.y);
				if (!self.swapInProgress) {
					[self swapClips];
				}
			} else {
				// Constrain to horizontal movement
				CGPoint constrainedPoint = self.draggableImageView.center;
                CGPoint newCenter = CGPointMake(constrainedPoint.x + translation.x, constrainedPoint.y);
                CGPoint newOriginPointLeft = CGPointMake(newCenter.x - (self.draggableImageView.frameWidth / 2), 0.0f);
				id <UICollectionViewDelegateTimelineLayout> delegate = (id <UICollectionViewDelegateTimelineLayout>) self.collectionView.delegate;
                if (![delegate collectionView:self.collectionView canAdjustToPosition:newOriginPointLeft forItemAtIndexPath:self.selectedIndexPath]) {
                    return;
                }
                CGPoint newOriginPointRight = CGPointMake(newCenter.x + (self.draggableImageView.frameWidth / 2), 0.0f);
                if (![delegate collectionView:self.collectionView canAdjustToPosition:newOriginPointRight forItemAtIndexPath:self.selectedIndexPath]) {
                    return;
                }
                self.draggableImageView.center = newCenter;

				[delegate collectionView:self.collectionView didAdjustToPosition:newOriginPointLeft forItemAtIndexPath:self.selectedIndexPath];
			}
		} else {
			if (indexPath.section != 0) {
				return;
			}

			CMTimeRange timeRange = cell.maxTimeRange;
			self.scaleUnit = CMTimeGetSeconds(timeRange.duration) / cell.frameWidth;

			NSArray *selectedPaths = [self.collectionView indexPathsForSelectedItems];
			if (selectedPaths && selectedPaths.count > 0) {
				NSIndexPath *selectedPath = [self.collectionView indexPathsForSelectedItems][0];
				if (selectedPath) {
					cell = (THVideoItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:selectedPath];
					if (cell && [cell respondsToSelector:@selector(isPointInDragHandle:)]) {
						if ([cell isPointInDragHandle:[self.collectionView convertPoint:location toView:cell]]) {
							self.trimming = YES;
						}
						if (self.trimming) {
							CGFloat newFrameWidth = cell.frameWidth + translation.x;
							[self adjustedToWidth:newFrameWidth];
						}
					}
				}
			}
		}

		// Reset translation point as translation amounts are cumulative
		[recognizer setTranslation:CGPointZero inView:self.collectionView];
	}

	// User Ended Gesture
	else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
		//[self invalidateLayout];
		self.trimming = NO;
	}	
}

- (BOOL)shouldSwapSelectedIndexPath:(NSIndexPath *)selected withIndexPath:(NSIndexPath *)hovered {
	if (self.panDirection == THPanDirectionRight) {
		return selected.row < hovered.row;
	} else {
		return selected.row > hovered.row;
	}
}

- (void)swapClips {
	
    NSIndexPath *hoverIndexPath = [self.collectionView indexPathForItemAtPoint:self.draggableImageView.center];

	id <UICollectionViewDelegateTimelineLayout> delegate = (id <UICollectionViewDelegateTimelineLayout>) self.collectionView.delegate;

    if (hoverIndexPath && [self shouldSwapSelectedIndexPath:self.selectedIndexPath withIndexPath:hoverIndexPath]) {

		if (![delegate collectionView:self.collectionView canMoveItemAtIndexPath:hoverIndexPath]) {
			return;
		}

		self.swapInProgress = YES;
		NSIndexPath *lastSelectedIndexPath = self.selectedIndexPath;
		self.selectedIndexPath = hoverIndexPath;

		[delegate collectionView:self.collectionView didMoveMediaItemAtIndexPath:lastSelectedIndexPath toIndexPath:self.selectedIndexPath];

        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:@[lastSelectedIndexPath]];
            [self.collectionView insertItemsAtIndexPaths:@[self.selectedIndexPath]];
        } completion:^(BOOL finished) {
			self.swapInProgress = NO;
			[self invalidateLayout];
		}];
    }
}


#pragma mark - Event Handler Methods

- (void)adjustedToWidth:(CGFloat)width {
	id <UICollectionViewDelegateTimelineLayout> delegate = (id <UICollectionViewDelegateTimelineLayout>) self.collectionView.delegate;
	NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
	[delegate collectionView:self.collectionView didAdjustToWidth:width forItemAtIndexPath:indexPath];
	[self invalidateLayout];
}

@end
