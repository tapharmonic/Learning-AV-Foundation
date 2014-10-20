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

#import "THAudioPickerViewController.h"
#import "THAudioItemTableViewCell.h"
#import "THAudioItem.h"
#import "THNotifications.h"
#import "THTableSectionHeaderView.h"
#import "UIView+THAdditions.h"

#define HEADER_HEIGHT 34.0f

static NSString * const THAudioItemCellID = @"THAudioItemCell";

@interface THAudioPickerViewController ()
@property (strong, nonatomic) NSArray *musicItems;
@property (strong, nonatomic) NSArray *voiceOverItems;
@property (strong, nonatomic) NSArray *allAudioItems;
@property (nonatomic) BOOL previewCompleted;
@end

@implementation THAudioPickerViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.allAudioItems = @[self.musicItems, self.voiceOverItems];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(previewComplete:)
												 name:THPlaybackEndedNotification
											   object:nil];
	self.previewCompleted = NO;

	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;

}

- (void)previewComplete:(NSNotification *)notification {
	self.previewCompleted = YES;
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.allAudioItems.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? @"Music" : @"Voice Overs";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.allAudioItems[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	THAudioItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THAudioItemCellID forIndexPath:indexPath];
	[self registerCellActions:cell];
	THAudioItem *item = self.allAudioItems[indexPath.section][indexPath.row];
	cell.titleLabel.text = item.title;
    cell.previewButton.selected = NO;
	return cell;
}

- (void)registerCellActions:(THAudioItemTableViewCell *)cell {
	[cell.previewButton addTarget:self action:@selector(handlePreviewTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handlePreviewTap:(id)sender {
	UIButton *button = sender;
	NSIndexPath *indexPath = [self indexPathForButton:sender];
	if (!button.selected) {
		THMediaItem *item = indexPath.section == 0 ? self.musicItems[indexPath.row] : self.voiceOverItems[indexPath.row];
		[self.playbackMediator previewMediaItem:item];
	} else {
		[self.playbackMediator stopPlayback];
	}
	button.selected = !button.selected;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	THTableSectionHeaderView *view = [[THTableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frameWidth, HEADER_HEIGHT)];
	view.title = [self tableView:tableView titleForHeaderInSection:section];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return HEADER_HEIGHT;
}

- (NSIndexPath *)indexPathForButton:(UIButton *)button {
	CGPoint point = [button convertPoint:button.bounds.origin toView:self.tableView];
	return [self.tableView indexPathForRowAtPoint:point];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	THAudioItem *item = self.allAudioItems[indexPath.section][indexPath.row];
	THTrack track = indexPath.section == 0 ? THMusicTrack : THCommentaryTrack;
	[self.playbackMediator addMediaItem:item toTimelineTrack:track];
}

- (THAudioItem *)defaultVoiceOver {
    return [self.voiceOverItems firstObject];
}

- (THAudioItem *)defaultMusicTrack {
    return [self.musicItems firstObject];
}

- (NSArray *)musicItems {
	if (!_musicItems) {
		NSMutableArray *items = [NSMutableArray array];
		for (int i = 0; i < self.musicURLs.count; i++) {
			NSURL *url = self.musicURLs[i];
			THAudioItem *item = [THAudioItem audioItemWithURL:url];
			[item prepareWithCompletionBlock:NULL];
			[items addObject:item];
		}
		_musicItems = items;
	}
	return _musicItems;
}

- (NSArray *)voiceOverItems {
	if (!_voiceOverItems) {
		NSMutableArray *items = [NSMutableArray array];
		for (int i = 0; i < self.voiceOverURLs.count; i++) {
			NSURL *url = self.voiceOverURLs[i];
			THAudioItem *item = [THAudioItem audioItemWithURL:url];
			[item prepareWithCompletionBlock:NULL];
			[items addObject:item];
		}
		_voiceOverItems = items;
	}
	return _voiceOverItems;
}

- (NSArray *)musicURLs {
	return [[NSBundle mainBundle] URLsForResourcesWithExtension:@"m4a" subdirectory:@"Music"];
}

- (NSArray *)voiceOverURLs {
	return [[NSBundle mainBundle] URLsForResourcesWithExtension:@"m4a" subdirectory:@"VoiceOvers"];
}

@end
