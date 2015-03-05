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

@interface ThumbnailViewController ()
{
	NSInteger _selectedCellIndex;
}

@end

@implementation ThumbnailViewController

- (void)setPlayingCell:(NSInteger)playingCell
{
	_selectedCellIndex = playingCell;

	[_collectionView reloadData];
}

- (void)reloadData
{
	[_collectionView reloadData];
}

- (void)clickOnCellAtIndex:(NSInteger)cellIndex section:(NSInteger)section inView:(WKCollectionView *)view;
{
	_selectedCellIndex = cellIndex;
	[self.delegate userClickedCellAtIndex:cellIndex];
	[_collectionView reloadData];
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
	return [[_document generatedSlides] count];
}

- (NSString *)collectionView:(WKCollectionView *)view titleForHeaderInSection:(NSInteger)section
{
	return @"";
}

- (NSImage *)imageForCellAtIndex:(NSInteger)cellIndex section:(NSInteger)section inView:(WKCollectionView *)view
{
	SlideRenderer * renderer = [[SlideRenderer alloc] init];

	SlideContainer * container = [[_document generatedSlides] objectAtIndex:cellIndex];

	return [renderer imageForSlideContainer:container renderSize:CGSizeMake(320, 320 / [self.delegate aspectRatioForThumbnails]) mask:NO];
}

- (NSString *)titleForCellAtIndex:(NSInteger)cellIndex section:(NSInteger)section inView:(WKCollectionView *)view
{
	return @"";//[[[_document.sermonContainer orderedSlides] objectAtIndex:cellIndex] label];
}

- (BOOL)cellSelectionStateAtIndex:(NSInteger)cellIndex section:(NSInteger)section inView:(WKCollectionView *)view
{
	if (cellIndex == _selectedCellIndex)
	{
		return YES;
	}

	return NO;
}

@end
