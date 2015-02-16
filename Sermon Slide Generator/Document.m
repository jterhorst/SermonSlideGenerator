//
//  Document.m
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/12/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import "Document.h"

#import "Slide.h"
#import "Sermon.h"

@interface Document () <NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, strong) Sermon * sermonContainer;
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

	for (Slide * slide in _sermonContainer.slides)
	{
		[slide addObserver:self forKeyPath:@"type" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
	}

	NSLog(@"%lu slides", (unsigned long)[_sermonContainer.slides count]);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"type"])
	{
		[_slidesTable reloadData];
	}
}

- (void)dealloc
{
	for (Slide * slide in _sermonContainer.slides)
	{
		[slide removeObserver:self forKeyPath:@"type"];
	}
}

- (IBAction)addSlide:(id)sender
{
	Slide * newSlide = [NSEntityDescription insertNewObjectForEntityForName:@"Slide" inManagedObjectContext:self.managedObjectContext];
	newSlide.slideIndex = [_sermonContainer.slides count];
	[_sermonContainer addSlidesObject:newSlide];

	[_slidesTable reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [_sermonContainer.slides count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[_sermonContainer orderedSlides] objectAtIndex:row];
}



- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	Slide * activeSlide = [[_sermonContainer orderedSlides] objectAtIndex:row];
	switch (activeSlide.type) {
		case SlideTypeTitle:
			return 88;
			break;
		case SlideTypePoint:
			return 88;
			break;
		case SlideTypeMedia:
			return 124;
			break;
		case SlideTypeScripture:
			return 88;
			break;
	  default:
			break;
	}

	return 44;
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
