//
//  Slide.h
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/15/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sermon;

typedef enum {
	SlideTypeBlank = 0,
	SlideTypeTitle = 1,
	SlideTypePoint = 2,
	SlideTypeMedia = 3,
	SlideTypeScripture = 4
} SlideType;

@interface Slide : NSManagedObject

@property (nonatomic, retain) NSString * label;
@property (nonatomic) int64_t type;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * reference;
@property (nonatomic, retain) NSString * mediaPath;
@property (nonatomic, retain) Sermon *sermon;
@property (nonatomic) int64_t slideIndex;

@end
