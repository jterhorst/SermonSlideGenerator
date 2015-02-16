//
//  Sermon.h
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/15/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Sermon : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSSet *slides;

- (NSArray *)orderedSlides;

@end

@interface Sermon (CoreDataGeneratedAccessors)

- (void)addSlidesObject:(NSManagedObject *)value;
- (void)removeSlidesObject:(NSManagedObject *)value;
- (void)addSlides:(NSSet *)values;
- (void)removeSlides:(NSSet *)values;

@end
