//
//  AppDelegate.h
//  Amphetamine Enhancer
//
//  Created by William Gustafson on 9/30/19.
//  Copyright © 2019 William Gustafson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h>
#include <sys/sysctl.h>
@import LetsMove;
//@import Sparkle;

#define kClosedDisplay @"amphetamine-enhancer-cdmManager"
#define kClosedDisplayPlist @"amphetamine-enhancer-cdmManager.plist"

#define kAllProcesses @"amphetamine-enhancer-allProcesses"
#define kAllProcessesPlist @"amphetamine-enhancer-allProcesses.plist"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDelegate>

// WINDOWS
@property (strong) IBOutlet NSWindow *preferencesWindow;
@property (strong) IBOutlet NSWindow *mainWindow;
@property (strong) IBOutlet NSWindow *aboutWindow;

// ENHANCEMENT WINDOW (MAIN WINDOW)
@property (strong) IBOutlet NSTextField *enhancementDescription;
@property (strong) IBOutlet NSTextField *enhancementStatus;
@property (strong) IBOutlet NSButton *enhancementAction;

// ENHANCEMENT TABLE
@property (strong) IBOutlet NSArrayController *enhancementArrayController;
@property (strong) IBOutlet NSTableView *enhancementTable;

@end

