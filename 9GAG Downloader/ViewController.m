//
//  ViewController.m
//  9GAG Downloader
//
//  Created by Avikant Saini on 8/4/15.
//  Copyright © 2015 avikantz. All rights reserved.
//

#import "ViewController.h"
#import "GagImage.h"

@implementation ViewController {
	CGFloat incProgress;
	NSString *currentSaveTitle;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view.
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults valueForKey:@"PATH"]) {
		_pathField.stringValue = [defaults valueForKey:@"PATH"];
		_numberOfItemsField.stringValue = [defaults valueForKey:@"ITEMS"];
		_startIDField.stringValue = [defaults valueForKey:@"STARTID"];
	}
}


- (IBAction)saveAction:(id)sender {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:_pathField.stringValue forKey:@"PATH"];
	[defaults setObject:_numberOfItemsField.stringValue	forKey:@"ITEMS"];
	[defaults setObject:_startIDField.stringValue forKey:@"STARTID"];
	
	_progressView.doubleValue = 0;
	incProgress = 100/(_numberOfItemsField.integerValue);
	
	NSString *section;
	switch (_sectionPicker.selectedSegment) {
		case 1: section = @"trending";
			break;
	    default: section = @"hot";
			break;
	}
	
	__block NSInteger savedCount = 0;
	__block NSString *next = @"0";
	if (_startIDField.stringValue != nil)
		next = _startIDField.stringValue;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		while (savedCount < _numberOfItemsField.integerValue) {
			NSError *error;
			NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self urlForSection:section andID:next]]];
			if (urlData) {
				NSData *data = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&error];
				
				if (!error && data) {
					NSMutableArray *gagImages = [GagImage returnArrayFromData:[data valueForKey:@"data"]];
					next = [[data valueForKey:@"paging"] valueForKey:@"next"];
					
					for (GagImage *gag in gagImages) {
						
						NSData *video = [NSData dataWithContentsOfURL:[NSURL URLWithString:gag.VideoGIFURL]];
						if (video) {
							[video writeToFile:[self imagesPathForFileName:[gag.VideoGIFURL lastPathComponent]] atomically:YES];
							currentSaveTitle = [NSString stringWithFormat:@"Saving GIF: '%@'", [gag.VideoGIFURL lastPathComponent]];
							dispatch_async(dispatch_get_main_queue(), ^{
								[_progressView incrementBy:incProgress];
								[_saveButton setTitle:currentSaveTitle];
							});
							savedCount += 1;
						}
						else {
							NSData *image = nil;
							NSString *imageURL = (_sizePicker.selectedSegment == 0) ? gag.ImageNormalURL : gag.ImageLargeURL;
							image = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
							if (image) {
								[image writeToFile:[self imagesPathForFileName:[imageURL lastPathComponent]] atomically:YES];
								currentSaveTitle = [NSString stringWithFormat:@"Saving: '%@'", [imageURL lastPathComponent]];
								dispatch_async(dispatch_get_main_queue(), ^{
									[_progressView incrementBy:incProgress];
									[_saveButton setTitle:currentSaveTitle];
								});
								savedCount += 1;
							}
						}
						if (savedCount >= _numberOfItemsField.integerValue)
							break;
					}
				}
			}
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[_progressView incrementBy:incProgress];
			[_saveButton setTitle:@"Done..."];
		});
	});
}

- (NSString *)urlForSection:(NSString *)section andID:(NSString *)ID {
	NSString *string = [NSString stringWithFormat:@"http://infinigag.eu01.aws.af.cm/%@/%@", section, ID];
	return string;
}

- (NSString *)imagesPathForFileName:(NSString *)name {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [NSString stringWithFormat:@"%@", [paths lastObject]];
	[manager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@/", [paths lastObject], _pathField.stringValue] withIntermediateDirectories:YES attributes:nil error:nil];
	return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", _pathField.stringValue, name]];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

@end
