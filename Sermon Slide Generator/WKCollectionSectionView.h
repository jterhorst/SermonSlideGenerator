

#import <Cocoa/Cocoa.h>

#import "WKCollectionViewSectionHeaderView.h"

#import "WKCollectionViewCell.h"

@class WKCollectionSectionView;

@protocol WKCollectionSectionViewDelegate <NSObject>

- (NSString *)titleForSectionView:(WKCollectionSectionView *)view;

- (NSInteger)numberOfCellsPerRowInSectionView:(WKCollectionSectionView *)view;
- (NSInteger)numberOfCellsInSectionView:(WKCollectionSectionView *)view;

- (CGSize)sizeForCellAtIndex:(NSInteger)cellIndex inSectionView:(WKCollectionSectionView *)view;
- (NSImage *)imageForCellAtIndex:(NSInteger)cellIndex inSectionView:(WKCollectionSectionView *)view;
- (NSString *)titleForCellAtIndex:(NSInteger)cellIndex inSectionView:(WKCollectionSectionView *)view;

@end

@interface WKCollectionSectionView : NSView

@property (nonatomic, assign) id<WKCollectionSectionViewDelegate> delegate;

@property (nonatomic, strong) WKCollectionViewSectionHeaderView * headerView;

@property (nonatomic, assign) NSInteger sectionIndex;

@property (nonatomic, strong) NSTextField * titleLabel;

@end
