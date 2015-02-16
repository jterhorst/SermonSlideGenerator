//
//  WKTTableRow.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/15/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import "WKTTableRow.h"

@implementation WKTTableRow

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
	if (!_typeSelection)
	{
		_typeSelection = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(10, self.bounds.size.height - 35, 150, 25) pullsDown:NO];
		_typeSelection.autoresizingMask = NSViewMaxXMargin|NSViewMinYMargin;
		[self addSubview:_typeSelection];
		[_typeSelection addItemsWithTitles:@[@"Blank",@"Title",@"Point",@"Media",@"Scripture"]];

		[_typeSelection bind:@"selectedIndex" toObject:self.objectValue withKeyPath:@"type" options:(@{NSContinuouslyUpdatesValueBindingOption : @YES, NSAllowsEditingMultipleValuesSelectionBindingOption : @YES,
																										NSConditionallySetsEditableBindingOption : @YES, NSRaisesForNotApplicableKeysBindingOption : @YES })];
		
	}

	self.textField.stringValue = @"";
	
}

@end
