//
//  DisplayOutputManager.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/24/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DisplayLayoutView.h"
#import "DisplayOutputManager.h"

#import "SlideRenderer.h"

@interface OutputWindow : NSWindow
{
	NSInteger _screenIndex;
}
@property (nonatomic, strong) NSImageView * outputImageView;
- (NSInteger)screenMode;
@end

@implementation OutputWindow

- (instancetype)initWithScreenIndex:(NSInteger)screenIndex
{
	_screenIndex = screenIndex;
	NSScreen * selectedScreen = [NSScreen mainScreen];
	NSRect screenRect = NSMakeRect(20, 20, 640, 480);
	if (screenIndex > 0 && screenIndex < [[NSScreen screens] count])
	{
		selectedScreen = [[NSScreen screens] objectAtIndex:screenIndex];
		screenRect = [selectedScreen frame];
	}

	self = [super initWithContentRect:screenRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	if (self) {

		_outputImageView = [[NSImageView alloc] initWithFrame:[[self contentView] bounds]];
		[[self contentView] addSubview:_outputImageView];
		if (screenIndex > 0)
		{
			[self setLevel:NSStatusWindowLevel+2];
		}

		[[self contentView] setBackgroundColor:[NSColor blackColor]];
		[self setBackgroundColor:[NSColor blackColor]];

		
	}
	return self;
}

- (NSInteger)screenMode
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)_screenIndex]])
	{
		return [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%lu", (unsigned long)_screenIndex]];
	}

	return 2;
}

@end

@interface DisplayOutputManager ()
{
	NSArray * _outputWindows;
	SlideContainer * _activeSlide;
}


@end

@implementation DisplayOutputManager

- (instancetype)init
{
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateScreens) name:NSApplicationDidChangeScreenParametersNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateScreens) name:DisplayLayoutViewModeChangedNotificationName object:nil];

		[self _updateScreens];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGSize)outputSize
{
	if ([_outputWindows lastObject])
	{
		return [[_outputWindows lastObject] frame].size;
	}

	return [[NSScreen mainScreen] frame].size;
}

- (CGFloat)outputAspectRatio
{
    if ([_outputWindows lastObject])
    {
        return [[_outputWindows lastObject] frame].size.width / [[_outputWindows lastObject] frame].size.height;
    }
    
    return 16.0f/9.0f;
}

- (void)_updateScreens
{
	for (OutputWindow * win in _outputWindows)
	{
		[win orderOut:nil];
	}
	_outputWindows = nil;

	[self displaySlideForContainer:_activeSlide];
}

- (void)displaySlideForContainer:(SlideContainer *)container
{
	_activeSlide = container;
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
			NSImage * slideImage = [renderer imageForSlideContainer:container renderSize:[win frame].size mask:[win screenMode] == 1];
			if ([win screenMode] == 0)
			{
				slideImage = nil;
			}
			[[win outputImageView] setImage:slideImage];
			[newWindows addObject:win];
		}

		_outputWindows = [NSArray arrayWithArray:newWindows];
	}
	else
	{
		for (OutputWindow * win in _outputWindows)
		{
			NSImage * slideImage = [renderer imageForSlideContainer:container renderSize:[win frame].size mask:[win screenMode] == 1];
			if ([win screenMode] == 0)
			{
				slideImage = nil;
			}
			[[win outputImageView] setImage:slideImage];
		}
	}

}

@end
