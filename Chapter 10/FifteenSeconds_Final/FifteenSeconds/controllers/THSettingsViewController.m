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

#import "THSettingsViewController.h"
#import "THNotifications.h"
#import "THAppSettings.h"
#import "UIView+THAdditions.h"
#import "THTableSectionHeaderView.h"

#define PROJECT_SECTION	0
#define DEFAULT_ROW		0

#define VIDEO_SECTION	2
#define EXPORT_ROW		0

#define HEADER_HEIGHT	38.0f

@implementation THSettingsViewController

- (void)viewDidLoad {
	[super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = [UIColor whiteColor];

    self.transitionsSwitch.on = [THAppSettings sharedSettings].transitionsEnabled;
	self.volumeFadesSwitch.on = [THAppSettings sharedSettings].volumeFadesEnabled;
	self.volumeDuckingSwitch.on = [THAppSettings sharedSettings].volumeDuckingEnabled;
	self.showTitlesSwitch.on = [THAppSettings sharedSettings].titlesEnabled;

}

- (CGSize)contentSizeForViewInPopover {
	return CGSizeMake(300, 300);
}

- (IBAction)toggleTransitionsEnabledState:(UISwitch *)sender {
	[THAppSettings sharedSettings].transitionsEnabled = sender.on;
	[[NSNotificationCenter defaultCenter] postNotificationName:THTransitionsEnabledStateChangeNotification
														object:@(sender.on)];
}

- (IBAction)toggleVolumeFadesEnabledState:(UISwitch *)sender {
	[THAppSettings sharedSettings].volumeFadesEnabled = sender.on;
	[[NSNotificationCenter defaultCenter] postNotificationName:THVolumeFadesEnabledStateChangeNotification
														object:@(sender.on)];
}

- (IBAction)toggleVolumeDuckingEnabledState:(UISwitch *)sender {
	[THAppSettings sharedSettings].volumeDuckingEnabled = sender.on;
	[[NSNotificationCenter defaultCenter] postNotificationName:THVolumeDuckingEnabledStateChangeNotification
														object:@(sender.on)];
}

- (IBAction)toggleShowTitlesEnableState:(UISwitch *)sender {
	[THAppSettings sharedSettings].titlesEnabled = sender.on;
	[[NSNotificationCenter defaultCenter] postNotificationName:THShowTitlesEnabledStateChangeNotification
														object:@(sender.on)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == VIDEO_SECTION && indexPath.row == EXPORT_ROW) {
		[[NSNotificationCenter defaultCenter] postNotificationName:THExportRequestedNotification object:nil];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self.popover dismissPopoverAnimated:YES];
	} else if (indexPath.section == PROJECT_SECTION && indexPath.row == DEFAULT_ROW) {
		[[NSNotificationCenter defaultCenter] postNotificationName:THLoadDefaultCompositionNotification object:nil];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self.popover dismissPopoverAnimated:YES];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	THTableSectionHeaderView *view = [[THTableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frameWidth, HEADER_HEIGHT)];
	view.title = [self tableView:tableView titleForHeaderInSection:section];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return HEADER_HEIGHT;
}

@end
