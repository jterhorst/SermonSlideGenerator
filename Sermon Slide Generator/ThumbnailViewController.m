//
//  ThumbnailViewController.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/22/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import "ThumbnailViewController.h"

#import "Document.h"
#import "Sermon.h"
#import "Slide.h"

#import "SlideRenderer.h"
#import "SlideContainer.h"
#import "SlideElement.h"

#import "WKCollectionView.h"

@implementation ThumbnailViewController


- (void)reloadData
{
	[_collectionView reloadData];
}

- (void)clickOnCellAtIndex:(NSInteger)cellIndex section:(NSInteger)section inView:(WKCollectionView *)view;
{
	[self.delegate userClickedCellAtIndex:cellIndex];
}

- (CGFloat)aspectRatioForCellsInCollectionView:(WKCollectionView *)view
{
	return [self.delegate aspectRatioForThumbnails];
}

- (NSInteger)numberOfSectionsInCollectionView:(WKCollectionView *)view
{
	return 1;
}

- (NSInteger)collectionView:(WKCollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
	return [[_document.sermonContainer slides] count];
}

- (NSString *)collectionView:(WKCollectionView *)view titleForHeaderInSection:(NSInteger)section
{
	return @"";
}

- (NSArray *)_generatedSlides
{
	NSMutableArray * slides = [NSMutableArray array];

	for (NSInteger iterator = 0; iterator < [[_document.sermonContainer slides] count]; iterator++)
	{
		[slides addObjectsFromArray:[self _slideContainersForSlide:[[_document.sermonContainer orderedSlides] objectAtIndex:iterator]]];
	}

	return [NSArray arrayWithArray:slides];
}

- (NSImage *)imageForCellAtIndex:(NSInteger)cellIndex section:(NSInteger)section inView:(WKCollectionView *)view
{
	SlideRenderer * renderer = [[SlideRenderer alloc] init];

	SlideContainer * container = [[self _generatedSlides] objectAtIndex:cellIndex];

	return [renderer imageForSlideContainer:container renderSize:CGSizeMake(320, 320 / [self.delegate aspectRatioForThumbnails]) mask:NO];
}

- (NSString *)titleForCellAtIndex:(NSInteger)cellIndex section:(NSInteger)section inView:(WKCollectionView *)view
{
	return @"";//[[[_document.sermonContainer orderedSlides] objectAtIndex:cellIndex] label];
}


- (NSArray *)_slideContainersForSlide:(Slide *)slide
{
	NSMutableArray * slideContainers = [NSMutableArray array];
	if (slide.type == SlideTypeMedia)
	{
		SlideElement * element = [[SlideElement alloc] init];
		element.verticalAlignment = SlideVerticalAlignmentMiddle;
		element.elementType = SlideElementTypeImage;
		element.imageFilePath = slide.mediaPath;

		SlideContainer * container = [[SlideContainer alloc] init];
		container.slideElements = @[element];
		[slideContainers addObject:container];
	}
	else if (slide.type == SlideTypeBlank)
	{
		SlideContainer * container = [[SlideContainer alloc] init];

		return @[container];
	}
	else if (slide.type == SlideTypeTitle)
	{
		SlideElement * element = [[SlideElement alloc] init];
		element.textValue = slide.text;
		element.textAlignment = NSCenterTextAlignment;
		element.verticalAlignment = SlideVerticalAlignmentBottom;
		element.elementType = SlideElementTypeText;
		element.fontName = @"MyriadPro-Bold";
		element.fontSize = 45;

		SlideContainer * container = [[SlideContainer alloc] init];
		container.slideElements = @[element];
		[slideContainers addObject:container];
	}
	else if (slide.type == SlideTypePoint)
	{
		SlideElement * element = [[SlideElement alloc] init];
		element.textValue = slide.text;
		element.textAlignment = NSCenterTextAlignment;
		element.verticalAlignment = SlideVerticalAlignmentBottom;
		element.elementType = SlideElementTypeText;
		element.fontName = @"MyriadPro-Bold";
		element.fontSize = 40;

		SlideContainer * container = [[SlideContainer alloc] init];
		container.slideElements = @[element];
		[slideContainers addObject:container];
	}
	else if (slide.type == SlideTypeScripture)
	{
		NSArray * textSlides = [self _splitTextForScriptureSlideText:slide.text];
		NSLog(@"text slides: %@", textSlides);

		for (NSString * text in textSlides)
		{
			SlideElement * bodyElement = [[SlideElement alloc] init];
			bodyElement.textValue = text;
			bodyElement.textAlignment = NSLeftTextAlignment;
			bodyElement.verticalAlignment = SlideVerticalAlignmentBottom;
			bodyElement.elementType = SlideElementTypeText;
			bodyElement.fontName = @"MyriadPro-Bold";
			bodyElement.fontSize = 40;

			SlideElement * referenceElement = [[SlideElement alloc] init];
			referenceElement.textValue = slide.reference;
			referenceElement.textAlignment = NSLeftTextAlignment;
			referenceElement.verticalAlignment = SlideVerticalAlignmentBottom;
			referenceElement.elementType = SlideElementTypeText;
			referenceElement.fontName = @"MyriadPro";
			referenceElement.fontSize = 40;

			SlideContainer * container = [[SlideContainer alloc] init];
			container.slideElements = @[bodyElement, referenceElement];
			[slideContainers addObject:container];
		}
	}

	return [NSArray arrayWithArray:slideContainers];
}

- (NSArray *)_splitTextForScriptureSlideText:(NSString *)slideText
{
	SlideRenderer * renderer = [[SlideRenderer alloc] init];
	NSMutableArray * slides = [NSMutableArray array];

	NSMutableArray * verseComponents = [NSMutableArray arrayWithArray:[slideText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	while ([verseComponents count] > 0) {
		NSMutableString * currentSlide = [NSMutableString string];

		while ([verseComponents count] > 0 && [renderer sizeForScriptureText:currentSlide renderSize:CGSizeMake(1280, 1024)].height < 1024 * 0.1) {
			if ([currentSlide length] > 0)
			{
				[currentSlide appendString:@" "];
			}
			if ([verseComponents firstObject])
			{
				[currentSlide appendString:[verseComponents firstObject]];
			}
			if ([verseComponents count] > 0)
				[verseComponents removeObjectAtIndex:0];
		}

		if ([currentSlide length] > 0)
		{
			[slides addObject:currentSlide];
		}
	}

	return slides;
}

@end
