//
//  NSBezierPath+Geometry.h
//  ITProgressIndicator
//
//  Created by Ilija Tovilo on 9/25/13.
//  Copyright (c) 2013 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSAffineTransform *RotationTransform(const float radians, const NSPoint aboutPoint);

@interface NSBezierPath (Geometry)

- (NSBezierPath*)rotatedBezierPath:(float) angle;
- (NSBezierPath*)rotatedBezierPath:(float) angle aboutPoint:(NSPoint)point;

@end
