

#import "WKCollectionViewCell.h"

@implementation WKCollectionViewCell

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

		self.titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, 22)];
		[self.titleLabel setAutoresizingMask:NSViewWidthSizable];
		[self.titleLabel setFont:[NSFont boldSystemFontOfSize:14]];
		[self.titleLabel setTextColor:[NSColor whiteColor]];
		[self.titleLabel setEditable:NO];
		[self.titleLabel setBordered:NO];
		[self.titleLabel setSelectable:NO];
		[self.titleLabel setBackgroundColor:[NSColor clearColor]];
		[self.titleLabel setAlignment:NSCenterTextAlignment];
		[self.titleLabel setStringValue:@"Test"];

		[self addSubview:self.titleLabel];


		self.thumbnailImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 22, frame.size.width, frame.size.height - 22)];
		[self.thumbnailImageView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

		[self addSubview:self.thumbnailImageView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    [[NSColor blackColor] set];
	[[NSBezierPath bezierPathWithRect:[self bounds]] fill];
}

@end
