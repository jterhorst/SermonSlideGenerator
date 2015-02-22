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

@implementation ThumbnailViewController

- (void)setThumbnailCollectionView:(NSCollectionView *)thumbnailCollectionView
{
	_thumbnailCollectionView = thumbnailCollectionView;
	_thumbnailCollectionView.delegate = self;

	[_thumbnailCollectionView setMaxNumberOfColumns:4];

	[self reloadData];
}

- (void)reloadData
{
	[_thumbnailCollectionView setBackgroundColors:@[[NSColor grayColor],[NSColor whiteColor]]];

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

	[_thumbnailCollectionView setContent:contentItems];
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
