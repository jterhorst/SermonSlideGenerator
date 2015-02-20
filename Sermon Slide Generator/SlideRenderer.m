//
//  SlideRenderer.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/13/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import "SlideRenderer.h"
#import <Cocoa/Cocoa.h>

@implementation SlideRenderer

- (NSImage *)imageForSlideContainer:(SlideContainer *)slide renderSize:(CGSize)renderSize
{
	NSImage * image = [[NSImage alloc] initWithSize:renderSize];
	[image lockFocus];

	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];

	CGContextSaveGState(context);

	CGContextTranslateCTM(context, 0, renderSize.height);
	CGContextScaleCTM(context, 1.0, -1.0);

	CGContextSetFillColorWithColor(context, [NSColor blackColor].CGColor);
	// over-fill with black (to bleed and avoid 1px lines around the edge
	CGContextFillRect(context, CGRectMake(0, 0, renderSize.width * 2, renderSize.height * 2));


	//CGContextDrawImage(context, CGRectMake(0, 0, renderSize.width, renderSize.height), mediaImage.CGImage);



	CGContextRestoreGState(context);

	[image unlockFocus];
    return image;
}

@end
