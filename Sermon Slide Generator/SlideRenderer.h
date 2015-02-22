//
//  SlideRenderer.h
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/13/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SlideContainer;

@interface SlideRenderer : NSObject
- (NSImage *)imageForSlideContainer:(SlideContainer *)slide renderSize:(CGSize)renderSize;
- (NSImage *)imageMaskForSlideContainer:(SlideContainer *)slide renderSize:(CGSize)renderSize;
@end
