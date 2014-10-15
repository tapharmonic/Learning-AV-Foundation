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

#import <Cocoa/Cocoa.h>
#import "THMediaItem.h"

@interface THMainWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSProgressIndicator *spinnerView;
@property (weak) IBOutlet NSTextField *nameField;

@property (weak) IBOutlet NSTextField *artistField;
@property (weak) IBOutlet NSTextField *albumArtistField;
@property (weak) IBOutlet NSTextField *albumField;
@property (weak) IBOutlet NSTextField *groupingField;
@property (weak) IBOutlet NSTextField *composerField;
@property (weak) IBOutlet NSTextField *commentsField;
@property (weak) IBOutlet NSComboBox *genreCombo;
@property (weak) IBOutlet NSTextField *yearField;
@property (weak) IBOutlet NSTextField *trackNumberField;
@property (weak) IBOutlet NSTextField *trackCountField;
@property (weak) IBOutlet NSTextField *discNumberField;
@property (weak) IBOutlet NSTextField *discCountField;
@property (weak) IBOutlet NSTextField *bpmField;
@property (weak) IBOutlet NSImageView *imageWell;
@property (weak) IBOutlet NSButton *compilationCheckbox;
@property (weak) IBOutlet NSButton *saveButton;

@property (weak) THMediaItem *mediaItem;

- (IBAction)save:(id)sender;

- (void)reloadData;

@end
