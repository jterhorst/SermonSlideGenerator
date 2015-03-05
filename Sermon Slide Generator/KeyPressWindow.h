//
//  KeyPressWindow.h
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 3/4/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol KeyPressWindowDelegate <NSObject>

@optional
- (void)leftArrowPressed;
- (void)rightArrowPressed;
- (void)upArrowPressed;
- (void)downArrowPressed;
- (void)returnKeyPressed;
- (void)spaceBarPressed;
- (void)escapeKeyPressed;

@end

@interface KeyPressWindow : NSWindow

@property (nonatomic, weak) IBOutlet id<KeyPressWindowDelegate> keyPressDelegate;

@end
