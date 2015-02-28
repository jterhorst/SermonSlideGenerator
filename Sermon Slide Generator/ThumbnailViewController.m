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
	
	/*
	NSMutableArray * contentItems = [NSMutableArray array];
	SlideRenderer * renderer = [[SlideRenderer alloc] init];

	for (Slide * slide in [_document.sermonContainer orderedSlides])
	{
		NSCollectionViewItem * item = [[NSCollectionViewItem alloc] init];

		NSArray * slidesArray = [self _slideElementsForSlide:slide];

		SlideContainer * container = [[SlideContainer alloc] init];
		container.slideElements = slidesArray;

		item.imageView.image = [renderer imageMaskForSlideContainer:container renderSize:CGSizeMake(1280, 1020)];
	}
	*/
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

- (NSImage *)imageForCellAtIndex:(NSInteger)cellIndex section:(NSInteger)section inView:(WKCollectionView *)view
{
	SlideRenderer * renderer = [[SlideRenderer alloc] init];
	NSArray * slidesArray = [self _slideElementsForSlide:[[_document.sermonContainer orderedSlides] objectAtIndex:cellIndex]];

	SlideContainer * container = [[SlideContainer alloc] init];
	container.slideElements = slidesArray;

	return [renderer imageForSlideContainer:container renderSize:CGSizeMake(320, 320 / [self.delegate aspectRatioForThumbnails])];
}

- (NSString *)titleForCellAtIndex:(NSInteger)cellIndex section:(NSInteger)section inView:(WKCollectionView *)view
{
	return @"";//[[[_document.sermonContainer orderedSlides] objectAtIndex:cellIndex] label];
}


- (NSArray *)_slideElementsForSlide:(Slide *)slide
{
	NSMutableArray * slideElements = [NSMutableArray array];
	if (slide.type == SlideTypeMedia)
	{
		SlideElement * element = [[SlideElement alloc] init];
		element.verticalAlignment = SlideVerticalAlignmentMiddle;
		element.elementType = SlideElementTypeImage;
		element.imageFilePath = slide.mediaPath;
		[slideElements addObject:element];
	}
	else if (slide.type == SlideTypeBlank)
	{
		return slideElements;
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
		[slideElements addObject:element];
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
		[slideElements addObject:element];
	}
	else if (slide.type == SlideTypeScripture)
	{
		SlideElement * bodyElement = [[SlideElement alloc] init];
		bodyElement.textValue = slide.text;
		bodyElement.textAlignment = NSLeftTextAlignment;
		bodyElement.verticalAlignment = SlideVerticalAlignmentBottom;
		bodyElement.elementType = SlideElementTypeText;
		bodyElement.fontName = @"MyriadPro-Bold";
		bodyElement.fontSize = 40;
		[slideElements addObject:bodyElement];

		SlideElement * referenceElement = [[SlideElement alloc] init];
		referenceElement.textValue = slide.reference;
		referenceElement.textAlignment = NSLeftTextAlignment;
		referenceElement.verticalAlignment = SlideVerticalAlignmentBottom;
		referenceElement.elementType = SlideElementTypeText;
		referenceElement.fontName = @"MyriadPro";
		referenceElement.fontSize = 40;
		[slideElements addObject:referenceElement];
	}
	return slideElements;
}


@end
