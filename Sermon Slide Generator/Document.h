//
//  Document.h
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/12/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Sermon.h"
#import "ThumbnailViewController.h"

@interface Document : NSPersistentDocument

@property (nonatomic, weak) IBOutlet NSTableView * slidesTable;
@property (nonatomic, strong) Sermon * sermonContainer;
@property (nonatomic, weak) IBOutlet ThumbnailViewController * thumbnailController;

- (IBAction)addSlide:(id)sender;

- (IBAction)chooseMedia:(id)sender;

@property (nonatomic, weak) IBOutlet NSObjectController * sermonObjectController;
@property (nonatomic, weak) IBOutlet NSArrayController * slidesArrayController;

@end
