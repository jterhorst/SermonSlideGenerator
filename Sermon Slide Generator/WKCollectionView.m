

#import "WKCollectionView.h"


@interface WKCollectionView ()
{
	NSMutableArray * _sectionViews;
}

@end


@implementation WKCollectionView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self reloadData];

		_cellSizeWidth = 150;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self reloadData];

		_cellSizeWidth = 150;
	}
	return self;
}

- (void)setFrame:(NSRect)frameRect
{
	CGFloat minimumFrameHeight = frameRect.size.height;
	CGFloat totalHeight = 0;

	NSInteger numberOfSections = [self _numberOfSections];

	NSInteger iterator = 0;
	for (iterator = 0; iterator < numberOfSections; iterator++)
	{
		totalHeight = totalHeight + [self _sizeForSectionAtIndex:iterator].height + 10;
	}

	totalHeight = totalHeight + 10;

	if (minimumFrameHeight < totalHeight)
	{
		minimumFrameHeight = totalHeight;
	}

	if (minimumFrameHeight < [self superview].bounds.size.height)
	{
		minimumFrameHeight = [self superview].bounds.size.height;
	}

	[super setFrame:NSMakeRect(frameRect.origin.x, [self superview].bounds.size.height - minimumFrameHeight, frameRect.size.width, minimumFrameHeight)];

	[self _layoutSections];
}

- (void)setFrameSize:(NSSize)newSize
{
	[super setFrameSize:newSize];

	[self setNeedsLayout:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    [[NSColor whiteColor] set];
	[[NSBezierPath bezierPathWithRect:dirtyRect] fill];
}


- (NSInteger)_numberOfSections
{
	return [self.dataSource numberOfSectionsInCollectionView:self];
}

//- (void)layout
//{
//	[super layout];
//
//	[self _layoutSections];
//}

- (void)layoutSubtreeIfNeeded
{
	[super layoutSubtreeIfNeeded];

	[self _layoutSections];
}

- (void)_layoutSections
{
	if (!_sectionViews)
	{
		_sectionViews = [NSMutableArray array];
	}

	//NSLog(@"collection view frame: %@", NSStringFromRect([self frame]));

	NSInteger numberOfSections = [self _numberOfSections];

	CGFloat currentSectionYPoint = 10;

	NSInteger iterator = 0;
	for (iterator = 0; iterator < numberOfSections; iterator++)
	{
		WKCollectionSectionView * sectionView = [self _sectionViewForIndex:iterator];

		if ([sectionView superview] != self)
		{
			[self addSubview:sectionView];
		}

		sectionView.frame = CGRectMake(10, self.bounds.size.height - currentSectionYPoint - [self _sizeForSectionAtIndex:iterator].height, [self _sizeForSectionAtIndex:iterator].width, [self _sizeForSectionAtIndex:iterator].height);

		currentSectionYPoint = currentSectionYPoint + [self _sizeForSectionAtIndex:iterator].height + 10;
	}
}

- (NSString *)titleForSectionView:(WKCollectionSectionView *)view;
{
	return [self.dataSource collectionView:self titleForHeaderInSection:view.sectionIndex];
}

- (NSInteger)numberOfCellsInSectionView:(WKCollectionSectionView *)view;
{
	return [self.dataSource collectionView:self numberOfItemsInSection:view.sectionIndex];
}

- (CGSize)sizeForCellAtIndex:(NSInteger)cellIndex inSectionView:(WKCollectionSectionView *)view;
{
	return [self _sizeForCells];
}

- (NSInteger)numberOfCellsPerRowInSectionView:(WKCollectionSectionView *)view
{
	return [self numberOfSubCellsPerRow];
}

- (NSImage *)imageForCellAtIndex:(NSInteger)cellIndex inSectionView:(WKCollectionSectionView *)view;
{
	return [self.dataSource imageForCellAtIndex:cellIndex section:view.sectionIndex inView:self];
}

- (NSString *)titleForCellAtIndex:(NSInteger)cellIndex inSectionView:(WKCollectionSectionView *)view;
{
	return [self.dataSource titleForCellAtIndex:cellIndex section:view.sectionIndex inView:self];
}

- (WKCollectionSectionView *)_sectionViewForIndex:(NSInteger)section
{
	WKCollectionSectionView * sectionView = nil;

	for (WKCollectionSectionView * view in _sectionViews)
	{
		if (view.sectionIndex == section)
		{
			sectionView = view;
		}
	}

	if (!sectionView)
	{
		sectionView = [[WKCollectionSectionView alloc] initWithFrame:NSMakeRect(0, 0, [self _sizeForSectionAtIndex:section].width, [self _sizeForSectionAtIndex:section].height)];
		sectionView.sectionIndex = section;
		sectionView.delegate = self;

		if (!_sectionViews)
		{
			_sectionViews = [NSMutableArray array];
		}

		[_sectionViews addObject:sectionView];
	}

	return sectionView;
}

- (CGFloat)_currentAspectRatio
{
	if ([self.dataSource respondsToSelector:@selector(aspectRatioForCellsInCollectionView:)])
	{
		return [self.dataSource aspectRatioForCellsInCollectionView:self];
	}

	return 16.0f / 9.0f;
}

- (CGSize)_sizeForCells
{
	CGFloat ratio = [self _currentAspectRatio];

	CGFloat height = _cellSizeWidth / ratio;

	return CGSizeMake(_cellSizeWidth, height );
}

- (NSInteger)numberOfSubCellsPerRow;
{
    NSInteger width = _cellSizeWidth + 20;

    CGRect rect = self.frame;

    NSInteger subCells = rect.size.width / width;

    return subCells;
}

- (CGSize)_sizeForSectionAtIndex:(NSInteger)sectionIndex
{
	CGFloat cellRowHeight = 0;

    NSInteger numberOfSlides = [self.dataSource collectionView:self numberOfItemsInSection:sectionIndex];

	NSInteger subCellRows = numberOfSlides / [self numberOfSubCellsPerRow];
	if (numberOfSlides % [self numberOfSubCellsPerRow]) subCellRows++;

	cellRowHeight = (subCellRows * ([self _sizeForCells].height + 20));

	return CGSizeMake(self.bounds.size.width - 20, 22 + cellRowHeight);//[self _sizeForCells].height + 42);
}

- (void)reloadData
{
	CGSize resultingSize = CGSizeZero;
	resultingSize.width = self.frame.size.width;

	CGFloat totalHeight = 0;

	NSInteger numberOfSections = [self _numberOfSections];

	NSInteger iterator = 0;
	for (iterator = 0; iterator < numberOfSections; iterator++)
	{
		totalHeight = totalHeight + [self _sizeForSectionAtIndex:iterator].height + 10;
	}

	resultingSize.height = totalHeight;

	[self setFrameSize:resultingSize];

	[self setNeedsLayout:YES];
}

@end
