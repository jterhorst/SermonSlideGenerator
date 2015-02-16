//
//  Document.h
//  Sermon Slide Generator
//
//  Created by Jason Terhorst on 2/12/15.
//  Copyright (c) 2015 Jason Terhorst. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSPersistentDocument
@property (nonatomic, weak) IBOutlet NSTableView * slidesTable;

- (IBAction)addSlide:(id)sender;
@end
