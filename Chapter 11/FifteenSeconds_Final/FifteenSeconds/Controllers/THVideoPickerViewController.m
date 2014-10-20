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

#import "THVideoPickerViewController.h"
#import "THVideoItem.h"
#import "THVideoItemTableViewCell.h"
#import "THVideoPickerOverlayView.h"

static CGFloat THVideoItemRowHeight = 64.0f;
static NSString * const THVideoItemCellID = @"THVideoItemCell";

@interface THVideoPickerViewController ()
@property (strong, nonatomic) NSArray *videoItems;
@property (nonatomic) BOOL initialItemLoaded;
@end

@implementation THVideoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.initialItemLoaded = NO;
	self.tableView.backgroundColor = [UIColor colorWithWhite:0.206 alpha:1.000];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.videoItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	THVideoItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THVideoItemCellID forIndexPath:indexPath];
	[self registerCellActions:cell];

	THVideoItem *item = self.videoItems[indexPath.row];
	cell.thumbnails = item.thumbnails;
	return cell;
}

- (void)registerCellActions:(THVideoItemTableViewCell *)cell {
	[cell.playButton addTarget:self action:@selector(handlePreviewTap:) forControlEvents:UIControlEventTouchUpInside];
	[cell.addButton addTarget:self action:@selector(handleAddMediaItemTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handlePreviewTap:(id)sender {
	UIButton *button = sender;
	NSIndexPath *indexPath = [self indexPathForButton:sender];
	if (!button.selected) {
		THVideoItem *item = self.videoItems[indexPath.row];
		[self.playbackMediator previewMediaItem:item];
	} else {
		[self.playbackMediator stopPlayback];
	}
	button.selected = !button.selected;
}

- (void)handleAddMediaItemTap:(id)sender {
	NSIndexPath *indexPath = [self indexPathForButton:sender];
	THVideoItem *item = self.videoItems[indexPath.row];
	[self.playbackMediator addMediaItem:item toTimelineTrack:THVideoTrack];
}

- (NSIndexPath *)indexPathForButton:(UIButton *)button {
	CGPoint point = [button convertPoint:button.bounds.origin toView:self.tableView];
	return [self.tableView indexPathForRowAtPoint:point];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return THVideoItemRowHeight;
}

- (NSArray *)defaultVideoItems {
    return [self.videoItems subarrayWithRange:NSMakeRange(0, 3)];
}

- (NSArray *)videoItems {
	if (!_videoItems) {
		NSMutableArray *items = [NSMutableArray array];
		for (int i = 0; i < [self videoURLs].count; i++) {
			NSURL *url = [self videoURLs][i];
			THVideoItem *item = [THVideoItem videoItemWithURL:url];
			[item prepareWithCompletionBlock:^(BOOL complete) {
				if (complete) {
					dispatch_async(dispatch_get_main_queue(), ^{
						if (i == 0 && !self.initialItemLoaded) {
							[self.playbackMediator loadMediaItem:item];
							self.initialItemLoaded = YES;
						}
						NSIndexPath *reloadPath = [NSIndexPath indexPathForRow:i inSection:0];
						[self.tableView reloadRowsAtIndexPaths:@[reloadPath] withRowAnimation:UITableViewRowAnimationNone];
					});
				} else {
				}
			}];
			[items addObject:item];
		}
		_videoItems = items;
	}
	return _videoItems;
}

- (NSArray *)videoURLs {
	NSMutableArray *urls = [NSMutableArray array];
	[urls addObjectsFromArray:[[NSBundle mainBundle] URLsForResourcesWithExtension:@"mov" subdirectory:nil]];
	[urls addObjectsFromArray:[[NSBundle mainBundle] URLsForResourcesWithExtension:@"mp4" subdirectory:nil]];
	return urls;
}

@end
