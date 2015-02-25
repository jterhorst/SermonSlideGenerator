//
//  DisplayOutputManager.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/24/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DisplayOutputManager.h"

#import "SlideRenderer.h"

@interface OutputWindow : NSWindow
@property (nonatomic, strong) NSImageView * outputImageView;
@end

@implementation OutputWindow

- (instancetype)initWithScreenIndex:(NSInteger)screenIndex
{
	NSScreen * selectedScreen = [NSScreen mainScreen];
	NSRect screenRect = NSMakeRect(20, 20, 320, 240);
//	if (screenIndex > 0 && screenIndex < [[NSScreen screens] count])
//	{
//		selectedScreen = [[NSScreen screens] objectAtIndex:screenIndex];
//		screenRect = [selectedScreen frame];
//	}

	self = [super initWithContentRect:screenRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:selectedScreen];
	if (self) {

		_outputImageView = [[NSImageView alloc] initWithFrame:[[self contentView] bounds]];
		[[self contentView] addSubview:_outputImageView];

		[[self contentView] setBackgroundColor:[NSColor blackColor]];

		[self setBackgroundColor:[NSColor blackColor]];
	}
	return self;
}

@end

@interface DisplayOutputManager ()
{
	NSArray * _outputWindows;
}


@end

@implementation DisplayOutputManager

- (void)displaySlideForContainer:(SlideContainer *)container
{
	SlideRenderer * renderer = [[SlideRenderer alloc] init];

	if ([_outputWindows count] != [[NSScreen screens] count])
	{
		for (OutputWindow * win in _outputWindows)
		{
			[win orderOut:nil];
		}
		_outputWindows = nil;

		NSMutableArray * newWindows = [NSMutableArray array];

		for (NSInteger iterator = 0; iterator < [[NSScreen screens] count]; iterator++)
		{
			OutputWindow * win = [[OutputWindow alloc] initWithScreenIndex:iterator];
			[win makeKeyAndOrderFront:nil];
			NSImage * slideImage = [renderer imageForSlideContainer:container renderSize:[win frame].size];
			[[win outputImageView] setImage:slideImage];
			[newWindows addObject:win];
		}

		_outputWindows = [NSArray arrayWithArray:newWindows];
	}
	else
	{
		for (OutputWindow * win in _outputWindows)
		{
			NSImage * slideImage = [renderer imageForSlideContainer:container renderSize:[win frame].size];
			[[win outputImageView] setImage:slideImage];
		}
	}

}

@end
