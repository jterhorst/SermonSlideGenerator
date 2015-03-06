//
//  DisplayOutputManager.h
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/24/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SlideContainer;

@interface DisplayOutputManager : NSObject

- (CGSize)outputSize;
- (CGFloat)outputAspectRatio;

- (void)displaySlideForContainer:(SlideContainer *)container;

@end
