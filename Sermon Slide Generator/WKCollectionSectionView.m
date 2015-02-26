

#import "WKCollectionSectionView.h"

@interface WKCollectionSectionView ()
{
	NSMutableArray * _sectionCells;
}

@end

@implementation WKCollectionSectionView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

		self.headerView = [[WKCollectionViewSectionHeaderView alloc] initWithFrame:NSMakeRect(0, frame.size.height - 22, frame.size.width, 22)];

		[self addSubview:self.headerView];

		self.titleLabel = [[NSTextField alloc] initWithFrame:[self.headerView bounds]];
		[self.titleLabel setEditable:NO];
		[self.titleLabel setBordered:NO];
		[self.titleLabel setSelectable:NO];
		[self.titleLabel setTextColor:[NSColor whiteColor]];
		[self.titleLabel setBackgroundColor:[NSColor clearColor]];
		[self.titleLabel setFont:[NSFont boldSystemFontOfSize:14]];

		[self.headerView addSubview:self.titleLabel];
		[self.titleLabel setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

		if ([self.delegate titleForSectionView:self])
			[self.titleLabel setStringValue:[self.delegate titleForSectionView:self]];
		
    }
    return self;
}

- (void)setFrame:(NSRect)frameRect
{
	[super setFrame:frameRect];

	[self.headerView setFrame:NSMakeRect(0, self.bounds.size.height - 22, self.bounds.size.width, 22)];

	if ([self.delegate titleForSectionView:self])
		[self.titleLabel setStringValue:[self.delegate titleForSectionView:self]];

	[self _layoutCells];
}

- (WKCollectionViewCell *)_cellForIndex:(NSInteger)cellIndex
{
	if (!_sectionCells)
	{
		_sectionCells = [NSMutableArray array];
	}

	WKCollectionViewCell * cell = nil;

	for (WKCollectionViewCell * aCell in _sectionCells)
	{
		if (aCell.cellIndex == cellIndex)
		{
			cell = aCell;
		}
	}

	if (!cell)
	{
		cell = [[WKCollectionViewCell alloc] initWithFrame:NSMakeRect(0, 0, [self.delegate sizeForCellAtIndex:cellIndex inSectionView:self].width, [self.delegate sizeForCellAtIndex:cellIndex inSectionView:self].height)];
		cell.cellIndex = cellIndex;

		[_sectionCells addObject:cell];
	}

	cell.titleLabel.stringValue = [self.delegate titleForCellAtIndex:cellIndex inSectionView:self];
	cell.thumbnailImageView.image = [self.delegate imageForCellAtIndex:cellIndex inSectionView:self];

	if ([cell superview] != self)
	{
		[self addSubview:cell];
	}

	return cell;
}

- (NSInteger)_numberOfRows
{
	NSInteger cellCount = [self.delegate numberOfCellsInSectionView:self];
	NSInteger numberOfCellsPerRow = [self.delegate numberOfCellsPerRowInSectionView:self];

	return cellCount / numberOfCellsPerRow;
}

- (void)_layoutCells
{
	NSInteger iterator = 0;
	NSInteger cellCount = [self.delegate numberOfCellsInSectionView:self];

	for (iterator = 0; iterator < cellCount; iterator++)
	{
		WKCollectionViewCell * cell = [self _cellForIndex:iterator];

		cell.frame = NSMakeRect([self _pointForCellAtIndex:iterator].x, self.frame.size.height - [self _pointForCellAtIndex:iterator].y - cell.frame.size.height - 22, cell.frame.size.width, cell.frame.size.height);
	}
}

- (CGPoint)_pointForCellAtIndex:(NSInteger)cellIndex
{
	NSInteger cellCount = [self.delegate numberOfCellsInSectionView:self];
	NSInteger numberOfCellsPerRow = [self.delegate numberOfCellsPerRowInSectionView:self];

	CGFloat expectedTotalCellWidth = numberOfCellsPerRow * [self.delegate sizeForCellAtIndex:cellIndex inSectionView:self].width;
	CGFloat gapWidth = (self.bounds.size.width - 20 - expectedTotalCellWidth) / numberOfCellsPerRow;

	BOOL shouldCenterCells = cellCount >= numberOfCellsPerRow;

	CGFloat centeredXOriginPoint = gapWidth * 2;

	if (!shouldCenterCells)
	{
		centeredXOriginPoint = 10;
		gapWidth = 10;
	}



	NSInteger iterator = 0;

	NSInteger rowIndex = 0;
	NSInteger columnIndex = 0;

	while (iterator < cellIndex) {
		if (columnIndex < numberOfCellsPerRow - 1)
		{
			columnIndex++;
		}
		else
		{
			columnIndex = 0;
			rowIndex++;
		}

		iterator++;
	}

	CGFloat xPosition = 10 + (([self.delegate sizeForCellAtIndex:cellIndex inSectionView:self].width + gapWidth) * columnIndex);
	CGFloat yPosition = 10 + (([self.delegate sizeForCellAtIndex:cellIndex inSectionView:self].height + 10) * rowIndex);

	return CGPointMake(xPosition, yPosition);
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	//[[NSColor blueColor] set];
	//[[NSBezierPath bezierPathWithRect:[self bounds]] fill];
}

@end
