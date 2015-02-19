//
//  WKTTableRow.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/15/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import "WKTTableRow.h"
#import "Slide.h"

@implementation WKTTableRow

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    /*
	if (!_typeSelection)
	{
		_typeSelection = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(10, self.bounds.size.height - 35, 150, 25) pullsDown:NO];
		_typeSelection.autoresizingMask = NSViewMaxXMargin|NSViewMinYMargin;
		[self addSubview:_typeSelection];
		[_typeSelection addItemsWithTitles:@[@"Blank",@"Title",@"Point",@"Media",@"Scripture"]];

		[_typeSelection bind:@"selectedIndex" toObject:self.objectValue withKeyPath:@"type" options:(@{NSContinuouslyUpdatesValueBindingOption : @YES, NSAllowsEditingMultipleValuesSelectionBindingOption : @YES,
																										NSConditionallySetsEditableBindingOption : @YES, NSRaisesForNotApplicableKeysBindingOption : @YES })];
		
	}
	 */

	NSArray * titleArray = @[@"Blank slide",@"Title slide",@"Point slide",@"Media slide",@"Scripture slides"];

	self.textField.stringValue = @"";

	NSColor * textColor = [NSColor blackColor];


	if (self.backgroundStyle == NSBackgroundStyleDark)
	{
		textColor = [NSColor whiteColor];
	}

	Slide * activeSlide = self.objectValue;
	NSString * subtext = @"";

	[[titleArray objectAtIndex:activeSlide.type] drawAtPoint:NSMakePoint(10, self.bounds.size.height - 20) withAttributes:@{NSFontAttributeName:[NSFont boldSystemFontOfSize:14], NSForegroundColorAttributeName:textColor}];

	if (activeSlide.type == 1 || activeSlide.type == 2 || activeSlide.type == 4)
	{
		subtext = activeSlide.text;
	}

	[subtext drawInRect:NSMakeRect(10, 10, self.bounds.size.width - 20, self.bounds.size.height - 30) withAttributes:@{NSFontAttributeName:[NSFont systemFontOfSize:14], NSForegroundColorAttributeName:textColor}];

	if (activeSlide.type == 3)
	{
		NSImage * imageFile = [[NSImage alloc] initWithContentsOfFile:activeSlide.mediaPath];
		[imageFile drawInRect:NSMakeRect(10, 10, self.bounds.size.height - 35, self.bounds.size.height - 35)];
	}
	else if (activeSlide.type == 4)
	{
		NSColor * referenceColor = [NSColor darkGrayColor];
		if (self.backgroundStyle == NSBackgroundStyleDark)
		{
			referenceColor = [NSColor whiteColor];
		}
		[activeSlide.reference drawAtPoint:NSMakePoint(130, self.bounds.size.height - 20) withAttributes:@{NSFontAttributeName:[NSFont systemFontOfSize:14], NSForegroundColorAttributeName:referenceColor}];
	}
}

@end
