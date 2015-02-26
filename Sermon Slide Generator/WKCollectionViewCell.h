

#import <Cocoa/Cocoa.h>

@interface WKCollectionViewCell : NSView

@property (nonatomic, assign) NSInteger cellIndex;

@property (nonatomic, strong) NSTextField * titleLabel;
@property (nonatomic, strong) NSImageView * thumbnailImageView;

@end
