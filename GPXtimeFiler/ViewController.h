//
//  ViewController.h
//  GPXtimeFiler
//
//  Created by Anton Shebukov on 19/07/16.
//  Copyright © 2016 Anton Shebukov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSButton *Btn_SelectFile;
@property (weak) IBOutlet NSTextField *Lbl_FileName;
@property (weak) IBOutlet NSTextField *Lbl_Speed;
@property (weak) IBOutlet NSTextField *TextF_Speed;
@property (weak) IBOutlet NSButton *Btn_Process;

- (IBAction)Btn_SelectFileAction:(id)sender;
- (IBAction)Btn_ProcessAction:(id)sender;

@end

