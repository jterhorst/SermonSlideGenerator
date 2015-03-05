//
//  ThumbnailViewController.h
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/22/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@class Document;
@class WKCollectionView;

@protocol ThumbnailViewControllerDelegate <NSObject>
@required
- (CGFloat)aspectRatioForThumbnails;
- (void)userClickedCellAtIndex:(NSInteger)cellIndex;
@end

@interface ThumbnailViewController : NSObject <NSCollectionViewDelegate>

@property (nonatomic, weak) IBOutlet id<ThumbnailViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet WKCollectionView * collectionView;
@property (nonatomic, weak) IBOutlet Document * document;

- (void)setPlayingCell:(NSInteger)playingCell;

- (void)reloadData;

@end
