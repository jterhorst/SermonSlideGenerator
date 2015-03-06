//
//  Document.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/12/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import "Document.h"

#import "DisplayOutputManager.h"

#import "ThumbnailViewController.h"
#import "Slide.h"
#import "SlideRenderer.h"
#import "SlideContainer.h"
#import "SlideElement.h"

@interface Document () <NSTableViewDataSource, NSTableViewDelegate, ThumbnailViewControllerDelegate>
{
	DisplayOutputManager * _outputManager;
	NSInteger _playingSlideIndex;
	NSArray * _generatedSlides;
}
@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
		// Add your subclass-specific initialization here.
		_playingSlideIndex = 0;
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.

	_outputManager = [[DisplayOutputManager alloc] init];

	NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Sermon"];
	NSArray * sermons = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
	if ([sermons count] > 0)
	{
		_sermonContainer = [sermons firstObject];
	}
	else
	{
		_sermonContainer = [NSEntityDescription insertNewObjectForEntityForName:@"Sermon" inManagedObjectContext:self.managedObjectContext];
	}

	if ([_sermonContainer.slides count] == 0)
	{
		NSMutableSet * newSlides = [NSMutableSet set];
		Slide * newSlide = [NSEntityDescription insertNewObjectForEntityForName:@"Slide" inManagedObjectContext:self.managedObjectContext];
		newSlide.label = @"Test Slide";
		[newSlides addObject:newSlide];
		_sermonContainer.slides = newSlides;
	}

	_sermonObjectController.content = _sermonContainer;

	for (Slide * slide in _sermonContainer.slides)
	{
		[slide addObserver:self forKeyPath:@"type" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
		[slide addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
		[slide addObserver:self forKeyPath:@"reference" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
		[slide addObserver:self forKeyPath:@"mediaPath" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
	}

	//NSLog(@"%lu slides", (unsigned long)[_sermonContainer.slides count]);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"type"])
	{
		_generatedSlides = nil;
		NSIndexSet * selectedIndexSet = [_slidesArrayController selectionIndexes];
		[_slidesTable reloadData];
		[_slidesArrayController setSelectionIndexes:selectedIndexSet];

		[_thumbnailController reloadData];
	}
	else if ([keyPath isEqualToString:@"text"] || [keyPath isEqualToString:@"reference"] || [keyPath isEqualToString:@"mediaPath"])
	{
		_generatedSlides = nil;
		// some kind of redraw without reloading the selection
		NSInteger slideIndex = [[_slidesArrayController arrangedObjects] indexOfObject:object];
		[_slidesTable reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:slideIndex] columnIndexes:[NSIndexSet indexSetWithIndex:0]];

		[_thumbnailController reloadData];
	}
}

- (void)dealloc
{
	for (Slide * slide in _sermonContainer.slides)
	{
		[slide removeObserver:self forKeyPath:@"type"];
		[slide removeObserver:self forKeyPath:@"text"];
		[slide removeObserver:self forKeyPath:@"reference"];
		[slide removeObserver:self forKeyPath:@"mediaPath"];
	}
}

- (IBAction)addSlide:(id)sender
{
	Slide * newSlide = [NSEntityDescription insertNewObjectForEntityForName:@"Slide" inManagedObjectContext:self.managedObjectContext];
	newSlide.slideIndex = [_sermonContainer.slides count];
	[_sermonContainer addSlidesObject:newSlide];

	_sermonObjectController.content = _sermonContainer;
	_slidesArrayController.content = [_sermonContainer orderedSlides];
	[_slidesTable reloadData];
}

- (IBAction)chooseMedia:(id)sender
{
	NSOpenPanel * openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setAllowedFileTypes:@[@"jpg",@"png",@"gif"]];
	NSInteger panelStatus = [openPanel runModal];
	if (panelStatus == NSFileHandlingPanelOKButton)
	{
		Slide * slide = [[_slidesArrayController selectedObjects] firstObject];
		slide.mediaPath = [[[openPanel URLs] firstObject] path];
	}
}

- (CGFloat)aspectRatioForThumbnails
{
    return [_outputManager outputAspectRatio];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [_sermonContainer.slides count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[_sermonContainer orderedSlides] objectAtIndex:row];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{

}




- (NSArray *)generatedSlides
{
	if (_generatedSlides) return _generatedSlides;

	NSMutableArray * slides = [NSMutableArray array];

	for (NSInteger iterator = 0; iterator < [[self.sermonContainer slides] count]; iterator++)
	{
		[slides addObjectsFromArray:[self _slideContainersForSlide:[[self.sermonContainer orderedSlides] objectAtIndex:iterator]]];
	}

	_generatedSlides = [NSArray arrayWithArray:slides];
	return _generatedSlides;
}




- (void)userClickedCellAtIndex:(NSInteger)cellIndex
{
	_playingSlideIndex = cellIndex;
	[_outputManager displaySlideForContainer:[[self generatedSlides] objectAtIndex:cellIndex]];
}

- (void)leftArrowPressed
{
	if (_playingSlideIndex > 0)
	{
		_playingSlideIndex--;
		[_outputManager displaySlideForContainer:[[self generatedSlides] objectAtIndex:_playingSlideIndex]];
		[_thumbnailController setPlayingCell:_playingSlideIndex];
	}
}

- (void)rightArrowPressed
{
	NSLog(@"right arrow");
	if (_playingSlideIndex < [[self generatedSlides] count] - 1)
	{
		_playingSlideIndex++;
		[_outputManager displaySlideForContainer:[[self generatedSlides] objectAtIndex:_playingSlideIndex]];
		[_thumbnailController setPlayingCell:_playingSlideIndex];
	}
}

- (void)spaceBarPressed
{
	if (_playingSlideIndex < [[self generatedSlides] count] - 1)
	{
		_playingSlideIndex++;
		[_outputManager displaySlideForContainer:[[self generatedSlides] objectAtIndex:_playingSlideIndex]];
		[_thumbnailController setPlayingCell:_playingSlideIndex];
	}
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
	NSScanner *scanner = [NSScanner scannerWithString:slideText];

	SlideRenderer * renderer = [[SlideRenderer alloc] init];
	NSMutableArray * slides = [NSMutableArray array];

	NSMutableString * currentSlide = [NSMutableString string];
	while (![scanner isAtEnd]) {

		NSString * currentString = nil;

		if ([scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&currentString])
		{
			if ([renderer lineCountForScriptureText:[currentSlide stringByAppendingFormat:@" %@", currentString] renderSize:[_outputManager outputSize]] > 3)
			{
				[slides addObject:currentSlide];
				currentSlide = [NSMutableString string];
			}

			if ([currentSlide length] > 0)
			{
				[currentSlide appendString:@" "];
			}
			[currentSlide appendString:currentString];
		}
	}

	if ([currentSlide length] > 0)
	{
		[slides addObject:currentSlide];
	}

	return slides;
}

float heightForStringDrawing(NSString *myString, NSFont *myFont, float myWidth)
{
	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:myString];
	NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(myWidth, FLT_MAX)];
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
	[layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:layoutManager];
	[textStorage addAttribute:NSFontAttributeName value:myFont range:NSMakeRange(0, [textStorage length])];
	[textContainer setLineFragmentPadding:0.0];

	(void) [layoutManager glyphRangeForTextContainer:textContainer];
	return [layoutManager usedRectForTextContainer:textContainer].size.height;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	Slide * activeSlide = [[_sermonContainer orderedSlides] objectAtIndex:row];
	switch (activeSlide.type) {
		case SlideTypeTitle:
		case SlideTypePoint:
		case SlideTypeScripture:
		{
			NSString * slideText = activeSlide.text;
			if (!slideText) slideText = @"";
			float textSize = heightForStringDrawing(slideText, [NSFont boldSystemFontOfSize:14], tableView.frame.size.width - 20);
			return 30 + textSize;
		}
			break;
		case SlideTypeMedia:
			return 124;
			break;
	  default:
			break;
	}

	return 28;
}

+ (BOOL)autosavesInPlace {
	return YES;
}

- (NSString *)windowNibName {
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"Document";
}

@end
