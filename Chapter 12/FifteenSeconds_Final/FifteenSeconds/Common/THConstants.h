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

static const CGFloat THTimelineSeconds = 15.0f;
static const CGFloat THTimelineWidth = 1014.0f;

static const CGSize TH720pVideoSize = {1280.0f, 720.0f};
static const CGSize TH1080pVideoSize = {1920.0f, 1080.0f};

static const CGRect TH720pVideoRect = {{0.0f, 0.0f}, {1280.0f, 720.0f}};
static const CGRect TH1080pVideoRect = {{0.0f, 0.0f}, {1920.0f, 1080.f}};

static const CMTime THDefaultFadeInOutTime = {3, 2, 1, 0}; // 1.5 seconds
static const CMTime THDefaultDuckingFadeInOutTime = {1, 2, 1, 0}; // .5 seconds
static const CMTime THDefaultTransitionDuration = {1, 1, 1, 0}; // 1 second
