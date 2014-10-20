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

#import "THTransitionViewController.h"
#import "THVideoTransitionTypeViewModel.h"
#import "THVideoTransitionDurationViewModel.h"

@interface THTransitionViewController ()
@property (strong, nonatomic) THVideoTransition *transition;
@property (strong, nonatomic) NSArray *transitionTypes;
@end

@implementation THTransitionViewController

+ (id)controllerWithTransition:(THVideoTransition *)transition {
	return [[self alloc] initWithTransition:transition];
}

- (id)initWithTransition:(THVideoTransition *)transition {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		_transition = transition;
		self.transitionTypes = @[@"None", @"Dissolve", @"Push"];
		self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.separatorInset = UIEdgeInsetsZero;
        self.tableView.scrollEnabled = NO;
	}
	return self;
}

- (CGSize)preferredContentSize {
	return CGSizeMake(200, 140);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.transitionTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

    NSString *type = self.transitionTypes[indexPath.row];
	cell.textLabel.text = type;
    if (self.transition.type == [self transitionTypeFromString:type]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

	return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *currentIndexPath = [tableView indexPathForSelectedRow];
	if (![currentIndexPath isEqual:indexPath]) {
		[self.tableView deselectRowAtIndexPath:currentIndexPath animated:YES];
	}
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *type = self.transitionTypes[indexPath.row];
    self.transition.type = [self transitionTypeFromString:type];
    [self.tableView reloadData];
	[self.delegate transitionSelected];
}

- (THVideoTransitionType)transitionTypeFromString:(NSString *)type {
	if ([type isEqualToString:@"Dissolve"]) {
        return THVideoTransitionTypeDissolve;
	} else if ([type isEqualToString:@"Push"]) {
		return  THVideoTransitionTypePush;
	} else {
		return  THVideoTransitionTypeNone;
	}
}

@end
