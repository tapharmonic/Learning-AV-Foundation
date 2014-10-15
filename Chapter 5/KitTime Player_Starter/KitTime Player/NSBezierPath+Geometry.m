//
//  NSBezierPath+Geometry.m
//  ITProgressIndicator
//
//  Created by Ilija Tovilo on 9/25/13.
//  Copyright (c) 2013 Ilija Tovilo. All rights reserved.
//

#if !__has_feature(objc_arc)
#error ARC needs to be enabled!
#endif


#import "NSBezierPath+Geometry.h"

NSAffineTransform *RotationTransform(const float angle, const NSPoint aboutPoint) {
	NSAffineTransform *xfm = [NSAffineTransform transform];
	[xfm translateXBy:aboutPoint.x yBy:aboutPoint.y];
	[xfm rotateByRadians:angle];
	[xfm translateXBy:-aboutPoint.x yBy:-aboutPoint.y];
    
	return xfm;
}

@implementation NSBezierPath (Geometry)

- (NSBezierPath *)rotatedBezierPath:(float)angle {
	return [self rotatedBezierPath:angle aboutPoint:[self centerOfBounds]];
}

- (NSBezierPath*)rotatedBezierPath:(float)angle aboutPoint:(NSPoint)point {
	if(angle == 0.0) return self;
	else
	{
		NSBezierPath* copy = [self copy];
		NSAffineTransform *xfm = RotationTransform(angle, point);
		[copy transformUsingAffineTransform:xfm];
		
		return copy;
	}
}

- (NSPoint)centerOfBounds {
	return NSMakePoint(NSMidX(self.bounds), NSMidY(self.bounds));
}

@end


