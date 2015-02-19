//
//  Document.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/12/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import "Document.h"

#import "Slide.h"


@interface Document () <NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
		// Add your subclass-specific initialization here.
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.

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

	NSLog(@"%lu slides", (unsigned long)[_sermonContainer.slides count]);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"type"])
	{
		[_slidesTable reloadData];
	}
	else if ([keyPath isEqualToString:@"text"] || [keyPath isEqualToString:@"reference"] || [keyPath isEqualToString:@"mediaPath"])
	{
		// some kind of redraw without reloading the selection
		NSInteger slideIndex = [[_slidesArrayController arrangedObjects] indexOfObject:object];
		[_slidesTable reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:slideIndex] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [_sermonContainer.slides count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[_sermonContainer orderedSlides] objectAtIndex:row];
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
