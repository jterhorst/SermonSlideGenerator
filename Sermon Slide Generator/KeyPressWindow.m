//
//  KeyPressWindow.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 3/4/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import "KeyPressWindow.h"

@implementation KeyPressWindow

- (void)keyDown:(NSEvent *)e
{
	// every app with eye candy needs a slow mode invoked by the shift key
	//	if ([e modifierFlags] & (NSAlphaShiftKeyMask|NSShiftKeyMask))
	//	[CATransaction setValue:[NSNumber numberWithFloat:2.0f] forKey:@"animationDuration"];

	switch ([e keyCode])
	{
		case 123:				/* LeftArrow */
		{
			if ([_keyPressDelegate respondsToSelector:@selector(leftArrowPressed)])
				[_keyPressDelegate leftArrowPressed];
			break;
		}
		case 124:				/* RightArrow */
		{
			if ([_keyPressDelegate respondsToSelector:@selector(rightArrowPressed)])
				[_keyPressDelegate rightArrowPressed];
			break;
		}
		case 125:				/* Up */
		{
			if ([_keyPressDelegate respondsToSelector:@selector(upArrowPressed)])
				[_keyPressDelegate upArrowPressed];
			break;
		}
		case 126:				/* Down */
		{
			if ([_keyPressDelegate respondsToSelector:@selector(downArrowPressed)])
				[_keyPressDelegate downArrowPressed];
			break;
		}
		case 36:				/* RET */
		{
			if ([_keyPressDelegate respondsToSelector:@selector(returnKeyPressed)])
				[_keyPressDelegate returnKeyPressed];
			break;
		}
		case 49:
		{
			if ([_keyPressDelegate respondsToSelector:@selector(spaceBarPressed)])
				[_keyPressDelegate spaceBarPressed];
			break;
		}
		case 53:
		{
			if ([_keyPressDelegate respondsToSelector:@selector(escapeKeyPressed)])
				[_keyPressDelegate escapeKeyPressed];
			break;
		}
		default:
		{
			NSLog (@"unhandled key event: %d\n", [e keyCode]);
			[super keyDown:e];
		}
	}
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

@end
