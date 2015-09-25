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

#import "THMainWindowController.h"
#import <AVFoundation/AVFoundation.h>
#import "THMediaItem.h"
#import "AVMetadataItem+THAdditions.h"
#import "THGenre.h"
#import "NSFileManager+DirectoryLocations.h"
#import "THNumberFormatter.h"

@interface THMainWindowController () <NSComboBoxDataSource>
@property (strong) IBOutlet NSArrayController *mediaItemsController;
@property (strong) NSMutableArray *mediaItems;
@property (strong) AVAssetExportSession *exportSession;
@property (strong) NSArray *musicGenres;
@property (strong) NSArray *videoGenres;
@property (weak, readonly) NSArray *activeGenres;
@property (strong) NSWindowController *exportController;
@end

@implementation THMainWindowController

- (id)init {
    self = [super initWithWindowNibName:@"THMainWindow"];
    if (self) {
        _musicGenres = [THGenre musicGenres];
        _videoGenres = [THGenre videoGenres];
        _mediaItems = [NSMutableArray array];
    }
    return self;
}

- (id)initWithWindowNibName:(NSString *)nibName {
    return [self init];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self loadTable];
    [self configureTextFields];
}

- (void)reloadData {
    self.genreCombo.objectValue = nil;
    for (id obj in self.mediaItems) {
        [self.mediaItemsController removeObject:obj];
    }
    [self loadTable];
}

- (void)loadTable {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *rootURL = [NSURL fileURLWithPath:[fileManager applicationSupportDirectory]];
    NSArray *items = [fileManager contentsOfDirectoryAtURL:rootURL
                                includingPropertiesForKeys:@[NSURLNameKey, NSURLEffectiveIconKey]
                                                   options:NSDirectoryEnumerationSkipsHiddenFiles
                                                     error:nil];
    [items enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        [self.mediaItemsController addObject:[[THMediaItem alloc] initWithURL:url]];
    }];
    [self.tableView reloadData];
}

- (void)configureTextFields {
    THNumberFormatter *formatter = [[THNumberFormatter alloc] init];
    self.yearField.formatter = formatter;
    self.bpmField.formatter = formatter;
    self.trackNumberField.formatter = formatter;
    self.trackCountField.formatter = formatter;
    self.discNumberField.formatter = formatter;
    self.discCountField.formatter = formatter;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *view = notification.object;
    if (view.selectedRow != -1) {
        self.mediaItem = self.mediaItems[view.selectedRow];
        [self.saveButton setEnabled:self.mediaItem.isEditable];
        [self.mediaItem prepareWithCompletionHandler:^(BOOL complete) {
            [self.mediaItemsController setSelectionIndex:view.selectedRow];
            self.genreCombo.objectValue = self.mediaItem.metadata.genre;
        }];
    } else {
        self.mediaItem = nil;
        self.genreCombo.objectValue = nil;
        [self.mediaItemsController setSelectedObjects:@[]];
    }
    [self.genreCombo reloadData];
    [self updateFieldState];
}

- (void)updateFieldState {
    BOOL enabled = YES;
    if ([self.mediaItem.filetype isEqualToString:AVFileTypeAppleM4V] ||
        [self.mediaItem.filetype isEqualToString:AVFileTypeQuickTimeMovie]) {
        enabled = NO;
    }
    [self.trackNumberField setEnabled:enabled];
    [self.trackCountField setEnabled:enabled];
    [self.discNumberField setEnabled:enabled];
    [self.discCountField setEnabled:enabled];
    [self.bpmField setEnabled:enabled];
}

- (NSArray *)activeGenres {
    NSArray *active = nil;
    if (self.mediaItem) {
        if ([self.mediaItem.filetype isEqualToString:AVFileTypeQuickTimeMovie] ||
            [self.mediaItem.filetype isEqualToString:AVFileTypeAppleM4V]) {
            active = self.videoGenres;
        } else {
            active = self.musicGenres;
        }
    }
    return active;
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return self.activeGenres.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    THGenre *genre = self.activeGenres[index];
    return genre.name;
}

- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string {
    for (THGenre *genre in self.activeGenres) {
        if ([genre.name isEqualToString:string]) {
            return genre.index;
        }
    }
    return self.activeGenres.count;
}

- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)string {
    for (THGenre *genre in self.activeGenres) {
        if ([[genre.name lowercaseString] hasPrefix:[string lowercaseString]]) {
            self.mediaItem.metadata.genre = genre;
            return genre.name;
        }
    }
    self.mediaItem.metadata.genre = nil;
    return nil;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    THGenre *genre = self.activeGenres[self.genreCombo.indexOfSelectedItem];
    self.mediaItem.metadata.genre = genre;
}

- (IBAction)save:(id)sender {
    [self.mediaItem saveWithCompletionHandler:^(BOOL success) {
        NSUInteger selected = [self.tableView selectedRow];
        [self.tableView deselectRow:selected];
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selected] byExtendingSelection:NO];
    }];
}

- (NSURL *)tempURLForMediaItem:(THMediaItem *)item {
    NSString *supportDir = [[NSFileManager defaultManager] applicationSupportDirectory];
    NSString *tempPath = [supportDir stringByAppendingPathComponent:@"temp.m4a"];
    return [NSURL fileURLWithPath:tempPath];
}
@end
