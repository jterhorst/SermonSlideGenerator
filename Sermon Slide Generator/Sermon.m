//
//  Sermon.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/15/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import "Sermon.h"


@implementation Sermon

@dynamic title;
@dynamic subtitle;
@dynamic slides;

- (NSArray *)orderedSlides
{
	return [self.slides sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"slideIndex" ascending:YES]]];
}

@end
