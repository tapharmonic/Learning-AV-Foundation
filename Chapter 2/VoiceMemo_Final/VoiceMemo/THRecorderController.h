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

@protocol THRecorderControllerDelegate <NSObject>
- (void)interruptionBegan;
@end

typedef void(^THRecordingStopCompletionHandler)(BOOL);
typedef void(^THRecordingSaveCompletionHandler)(BOOL, id);

@class THMemo;
@class THLevelPair;

@interface THRecorderController : NSObject

@property (nonatomic, readonly) NSString *formattedCurrentTime;
@property (weak, nonatomic) id <THRecorderControllerDelegate> delegate;

// Recorder methods
- (BOOL)record;

- (void)pause;

- (void)stopWithCompletionHandler:(THRecordingStopCompletionHandler)handler;

- (void)saveRecordingWithName:(NSString *)name
            completionHandler:(THRecordingSaveCompletionHandler)handler;

- (THLevelPair *)levels;

// Player methods
- (BOOL)playbackMemo:(THMemo *)memo;

@end
