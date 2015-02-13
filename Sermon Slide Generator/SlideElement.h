//
//  SlideElement.h
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/13/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

typedef enum {
    SlideElementTypeText = 0,
    SlideElementTypeImage = 1
} SlideElementType;

typedef enum {
    SlideVerticalAlignmentTop = 0,
    SlideVerticalAlignmentMiddle = 1,
    SlideVerticalAlignmentBottom = 2
} SlideVerticalAlignment;

@interface SlideElement : NSObject
@property (nonatomic, assign) SlideElementType elementType;
@property (nonatomic, strong) NSString * textValue;
@property (nonatomic, assign) NSTextAlignment * textAlignment;
@property (nonatomic, assign) SlideVerticalAlignment verticalAlignment;
@property (nonatomic, strong) NSString * imageFilePath;
@end
