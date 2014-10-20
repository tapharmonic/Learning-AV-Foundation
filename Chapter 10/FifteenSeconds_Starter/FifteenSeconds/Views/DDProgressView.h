//
//  DDProgressView.h
//  DDProgressView
//
//  Created by Damien DeVille on 3/13/11.
//  Copyright 2011 Snappy Code. All rights reserved.
//

@interface DDProgressView : UIView

@property (nonatomic, retain) UIColor *innerColor;
@property (nonatomic, retain) UIColor *outerColor;
@property (nonatomic, retain) UIColor *emptyColor;
@property (nonatomic) float progress;

@end
