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

#import "MainViewController.h"
#import "THRecorderController.h"
#import "THMemo.h"
#import "THMemoCell.h"
#import "THLevelMeterView.h"
#import "THLevelPair.h"

#define CANCEL_BUTTON    0
#define OK_BUTTON        1

#define MEMO_CELL        @"memoCell"
#define MEMOS_ARCHIVE    @"memos.archive"

@interface MainViewController () <THRecorderControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet THLevelMeterView *levelMeterView;

@property (strong, nonatomic) NSMutableArray *memos;
@property (strong, nonatomic) CADisplayLink *levelTimer;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) THRecorderController *controller;

@end

@implementation MainViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _controller = [[THRecorderController alloc] init];
    _controller.delegate = self;
    _memos = [NSMutableArray array];
    self.stopButton.enabled = NO;

    UIImage *recordImage = [[UIImage imageNamed:@"record"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *pauseImage = [[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *stopImage = [[UIImage imageNamed:@"stop"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    [self.recordButton setImage:recordImage forState:UIControlStateNormal];
    [self.recordButton setImage:pauseImage forState:UIControlStateSelected];
    [self.stopButton setImage:stopImage forState:UIControlStateNormal];

    NSData *data = [NSData dataWithContentsOfURL:[self archiveURL]];
    if (!data) {
        _memos = [NSMutableArray array];
    } else {
        _memos = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

- (void)interruptionBegan {
    self.recordButton.selected = NO;
    [self stopMeterTimer];
    [self stopTimer];
}


#pragma mark - Recorder Control

- (IBAction)record:(id)sender {
    self.stopButton.enabled = YES;
    if (![sender isSelected]) {
        [self startMeterTimer];
        [self startTimer];
        [self.controller record];
    } else {
        [self stopMeterTimer];
        [self stopTimer];
        [self.controller pause];
    }
    [sender setSelected:![sender isSelected]];
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(updateTimeDisplay)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)updateTimeDisplay {
    self.timeLabel.text = self.controller.formattedCurrentTime;
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (IBAction)stopRecording:(id)sender {
    [self stopMeterTimer];
    self.recordButton.selected = NO;
    self.stopButton.enabled = NO;
    [self.controller stopWithCompletionHandler:^(BOOL result) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [self showSaveDialog];
        });
    }];
}

- (void)showSaveDialog {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Save Recording"
                                          message:@"Please provide a name"
                                          preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"My Recording", @"Login");
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *filename = [alertController.textFields.firstObject text];
        [self.controller saveRecordingWithName:filename completionHandler:^(BOOL success, id object) {
            if (success) {
                [self.memos addObject:object];
                [self saveMemos];
                [self.tableView reloadData];
            } else {
                NSLog(@"Error saving file: %@", [object localizedDescription]);
            }
        }];
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];

    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Memo Archiving

- (void)saveMemos {
    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:self.memos];
    [fileData writeToURL:[self archiveURL] atomically:YES];
}

- (NSURL *)archiveURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    NSString *archivePath = [docsDir stringByAppendingPathComponent:MEMOS_ARCHIVE];
    return [NSURL fileURLWithPath:archivePath];
}


#pragma mark - UITableView Datasource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    THMemoCell *cell = [tableView dequeueReusableCellWithIdentifier:MEMO_CELL forIndexPath:indexPath];
    THMemo *memo = self.memos[indexPath.row];
    cell.titleLabel.text = memo.title;
    cell.dateLabel.text = memo.dateString;
    cell.timeLabel.text = memo.timeString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    THMemo *memo = self.memos[indexPath.row];
    [self.controller playbackMemo:memo];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        THMemo *memo = self.memos[indexPath.row];
        [memo deleteMemo];
        [self.memos removeObjectAtIndex:indexPath.row];
        [self saveMemos];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark - Level Metering

- (void)startMeterTimer {
    [self.levelTimer invalidate];
    self.levelTimer = [CADisplayLink displayLinkWithTarget:self
                                                  selector:@selector(updateMeter)];
    self.levelTimer.frameInterval = 5;
    [self.levelTimer addToRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSRunLoopCommonModes];
}

- (void)stopMeterTimer {
    [self.levelTimer invalidate];
    self.levelTimer = nil;
    [self.levelMeterView resetLevelMeter];
}

- (void)updateMeter {
    THLevelPair *levels = [self.controller levels];
    self.levelMeterView.level = levels.level;
    self.levelMeterView.peakLevel = levels.peakLevel;
    [self.levelMeterView setNeedsDisplay];
}

@end
