//
//  SlideRenderer.h
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/13/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SlideContainer;
@class SlideElement;

@interface SlideRenderer : NSObject
- (NSImage *)imageForSlideContainer:(SlideContainer *)slide renderSize:(CGSize)renderSize mask:(BOOL)mask;
- (CGSize)sizeForSlideElement:(SlideElement *)element renderSize:(CGSize)renderSize;
- (CGSize)sizeForScriptureText:(NSString *)text renderSize:(CGSize)renderSize;
@end
