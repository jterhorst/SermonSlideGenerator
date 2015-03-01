

#import <Cocoa/Cocoa.h>

@class WKCollectionSectionView;

@interface WKCollectionViewCell : NSView

@property (nonatomic, assign) NSInteger cellIndex;

@property (nonatomic, strong) NSTextField * titleLabel;
@property (nonatomic, strong) NSImageView * thumbnailImageView;

@property (nonatomic, weak) WKCollectionSectionView * sectionView;

@end
