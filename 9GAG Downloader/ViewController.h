//
//  ViewController.h
//  9GAG Downloader
//
//  Created by Avikant Saini on 8/4/15.
//  Copyright © 2015 avikantz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSSegmentedControl *sectionPicker;
@property (weak) IBOutlet NSSegmentedControl *sizePicker;
@property (weak) IBOutlet NSTextField *pathField;
@property (weak) IBOutlet NSTextField *numberOfItemsField;
@property (weak) IBOutlet NSProgressIndicator *progressView;
@property (weak) IBOutlet NSTextField *startIDField;
@property (weak) IBOutlet NSButton *saveButton;

@end

