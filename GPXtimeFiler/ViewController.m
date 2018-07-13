//
//  ViewController.m
//  GPXtimeFiler
//
//  Created by Anton Shebukov on 19/07/16.
//  Copyright © 2016 Anton Shebukov. All rights reserved.
//

#import "ViewController.h"

#import "CoreLocation/CoreLocation.h"

#import "DDXML.h"
#import "DDXMLElementAdditions.h"

@interface ViewController () {
    NSURL *filePath;
}

@end


@implementation ViewController

- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    NSLog(@"setRepresentedObject:");
    
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)Btn_SelectFileAction:(id)sender {
    NSLog(@"Btn_SelectFileAction:");
    
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    openDlg.canChooseFiles = YES;
    
    // Disable the selection of directories in the dialog.
    openDlg.canChooseDirectories = NO;
    
    // No multiple files
    openDlg.allowsMultipleSelection = NO;
    
    openDlg.allowedFileTypes = [NSArray arrayWithObject:@"gpx"];
    
    // Display the dialog.  If the OK button was pressed, process the files.
    if ( [openDlg runModal] == NSModalResponseOK ) {
        
        // Get an array containing the full filenames of all files and directories selected.
        NSArray<NSURL *> *files = [openDlg URLs];
        
        // Loop through all the files and process them.
        for( int i = 0; i < [files count]; i++ ) {
            filePath = [files objectAtIndex:i];
            
            // Do something with the filename.
            self.Lbl_FileName.stringValue = [filePath lastPathComponent];
        }
    }
}

- (IBAction)Btn_ProcessAction:(id)sender {
    NSLog(@"Btn_ProcessAction:");
    
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:[filePath path]]) {
        NSLog(@"Btn_ProcessAction: ! fileExistsAtPath:");
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
//    NSDate *dateTime = [NSDate date];
    
    NSLog(@"Btn_ProcessAction: XML opening");
    
    DDXMLDocument *xmlDocument;
    
    NSData *xmlData = [NSData dataWithContentsOfURL:filePath];
    xmlDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    
    NSLog(@"Btn_ProcessAction: XML getting first location");
    
    NSArray *messagesArray = [[xmlDocument rootElement] elementsForName:@"wpt"];
    
    DDXMLElement *prevLocationElement = [messagesArray firstObject];
    
    DDXMLElement *timeElement = [prevLocationElement elementForName:@"time"];
//    NSString *newTime = [dateFormatter stringFromDate:dateTime];
//    [timeElement setStringValue:newTime];
    NSString *oldTime = [timeElement stringValue];
    NSDate *dateTime = [dateFormatter dateFromString:oldTime];
    
    DDXMLNode *prevLat = [prevLocationElement attributeForName:@"lat"];
    DDXMLNode *prevLon = [prevLocationElement attributeForName:@"lon"];
    DDXMLNode *currLat = nil;
    DDXMLNode *currLon = nil;
    
    CLLocation *prevLocation = [[CLLocation alloc] initWithLatitude:[[prevLat stringValue] doubleValue] longitude:[[prevLon stringValue] doubleValue]];
    CLLocation *currLocation = nil;
    
    NSLog(@"Btn_ProcessAction: starting loop for %ld nodes", [messagesArray count]);
    
    for (int i = 1; i < [messagesArray count]; i++) {
        DDXMLElement *currElement = [messagesArray objectAtIndex:i];
        
        currLat = [currElement attributeForName:@"lat"];
        currLon = [currElement attributeForName:@"lon"];
        
        currLocation = [[CLLocation alloc] initWithLatitude:[[currLat stringValue] doubleValue] longitude:[[currLon stringValue] doubleValue]];
        
        double distanceKM = [currLocation distanceFromLocation:prevLocation] / 1000;
        double speedKMH = [[self.TextF_Speed stringValue] doubleValue];
        
        double timeH = distanceKM / speedKMH;
        double timeS = timeH * 3600; // time duration in seconds
        
        if (timeS < 1)
            timeS = 1;
        
        dateTime = [dateTime dateByAddingTimeInterval:timeS];
        
        DDXMLElement *timeElement = [currElement elementForName:@"time"];
        NSString *newTime = [dateFormatter stringFromDate:dateTime];
        [timeElement setStringValue:newTime];
        
        // curr => prev
        prevLocationElement = currElement;
        prevLat = currLat;
        prevLon = currLon;
        prevLocation = currLocation;
    }
    
    NSLog(@"Btn_ProcessAction: XML writing to file");
    
    xmlData = [xmlDocument XMLDataWithOptions:DDXMLNodePrettyPrint];
    
    BOOL result = [xmlData writeToURL:filePath atomically:YES];
    
    NSLog(@"Btn_ProcessAction: Done");
}

    

@end
    
    
