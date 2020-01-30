//
//  AppDelegate.m
//  Amphetamine Enhancer
//
//  Created by William Gustafson on 9/30/19.
//  Copyright © 2019 William Gustafson. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{
    PFMoveToApplicationsFolderIfNecessary();
    [self.mainWindow makeKeyAndOrderFront:self];
    [self.mainWindow center];
    [self setupEnhancementTable];
    [self runLaunchChecks];
}


- (void) runLaunchChecks
{
    bool willTerminate = NO;
           
    // MAKE SURE AMPHETAMINE IS INSTALLED, AND IN THE CORRECT LOCATION
    NSString *ampAppPath = @"/Applications/Amphetamine.app";
    NSBundle *bundle = [NSBundle bundleWithPath:ampAppPath];
    
    if ((!bundle) && (!willTerminate))
    {
        willTerminate = YES;
            
        [self displayAlert:
         
         @"Amphetamine is not installed.":@"Amphetamine Enhancer could not find Amphetamine on this Mac. If you have not installed Amphetamine, please install it from the Mac App Store.\n\nIf Amphetamine is installed, but is not in the Applications folder, please move Amphetamine to the Applications folder and relaunch Amphetamine Enhancer.\n\nAmphetamine Enhancer will now quit.":YES
         
         ];
    }
    
    // MAKE SURE AMPHETAMINE HAS BEEN UPDATED TO THE MINIMUM VERSION NUMBER FOR USE WITH AMPHETAMINE ENHANCER
    NSString *amphVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *amphVersionMod = [amphVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    int amphVersionInt = [amphVersionMod intValue];
    
    if ((amphVersionInt < 43) && (!willTerminate))
    {
        [self displayAlert:
         
         @"Amphetamine needs to be updated.":[NSString stringWithFormat:@"Amphetamine Enhancer only works with Amphetamine 4.3 and higher. You currently have Amphetamine %@ installed.\n\nPlease upgrade Amphetamine via the Mac App Store. If you have multiple copies of Amphetamine installed, please delete all copies and then download the current version of Amphetamine from the Mac App Store.\n\nAmphetamine Enhancer will now quit.", amphVersion]:YES
         
         ];
    }
    
    // MUST MAKE SURE CDMMANAGER CAN ALSO LAUNCH
    NSString *cmd = [NSString stringWithFormat:@"xattr -r -d com.apple.quarantine '%@'", [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/CDMManager/CDMManager.app"]];
    [self runTask: [NSArray arrayWithObjects:@"-c", cmd, nil]];
}


- (void) setupEnhancementTable
{
    if ([self isMacBook])
    {
        [self.enhancementArrayController addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     @"Closed-Display Mode Fail-Safe", @"Title",
                                                     @"This enhancement acts as a fail-safe for Amphetamine's closed-display mode feature.\n\nInstalling this enhancement will put a script on your Mac that periodically checks whether Amphetamine is running. If Amphetamine is not running, the script will ensure that your Mac reverts to the expected behavior of sleeping when your Mac's display is closed.\n\nIf Amphetamine is running, this script checks to make sure a session is active. If a session is not active, the script will ensure your Mac reverts to the expected behavior of sleeping when your Mac's display is closed. ", @"Description",
                                                     kClosedDisplayPlist, @"PlistFile",
                                                     kClosedDisplay, @"PlistName",
                                                     nil]];
    }
    
    [self.enhancementArrayController addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    @"Enhanced App & Process Monitoring", @"Title",
                                                    @"This enhancement allows Amphetamine to see additional apps and processes that are normally not available for use with Amphetamine's app-based sessions and App Trigger criterion. The sandboxing feature of macOS prevents Amphetamine from seeing these additional apps and processes directly.\n\nInstalling this enhancement will put a script on your Mac that periodically creates a list of all of the apps and processes running on your Mac. This list is written to a file on your Mac which Amphetamine can then read and react to.", @"Description",
                                                    kAllProcessesPlist, @"PlistFile",
                                                    kAllProcesses, @"PlistName",
                                                    nil]];
    
    // SELECT THE FIRST ROW IN THE TABLE
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex: 0];
    [self.enhancementTable selectRowIndexes: indexSet byExtendingSelection: NO];
}


- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
    [self maintainMainWindow];
}


- (void) maintainMainWindow
{
    NSInteger selectedRowIndex = [self.enhancementTable selectedRow];
    NSMutableDictionary *dict = [self.enhancementArrayController.arrangedObjects objectAtIndex: selectedRowIndex];
    
    self.enhancementDescription.stringValue = [dict objectForKey:@"Description"];
    
    NSString *plistName = [dict valueForKey:@"PlistFile"];
    bool agentInstalled = [self isAgentInstalled:plistName];
    
    self.enhancementStatus.stringValue = (agentInstalled) ? (@"Status: Installed") : (@"Status: Not Installed");
    self.enhancementAction.title = (agentInstalled) ? (@"Uninstall") : (@"Install");
    self.enhancementStatus.textColor = (agentInstalled) ? (NSColor.greenColor) : (NSColor.redColor);
}


// TEST WHETHER AN AGENT IS INSTALLED
// ONLY TESTS IF FILE IS IN CORRECT PATH
// DOES NOT TEST IF AGENT IS LOADED/UNLOADED
- (bool) isAgentInstalled : (NSString *) agentName
{
    //SET UP PATH
    NSString *basePath = @"/Users/";
    NSString *userName =[basePath stringByAppendingString:NSUserName()];
    NSString *homePath =[userName stringByAppendingString:@"/Library/LaunchAgents/"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
        
    // CHECK FOR LAUNCHAGENT
    NSString *agentPath = [homePath stringByAppendingString:agentName];

    // LAUNCHAGENT FOUND
    if ([fileManager fileExistsAtPath:agentPath])
    {
        return YES;
    }
    else // NOT FOUND
    {
        return NO;
    }
}


// NOT USED CURRENTLY. KEEPING IT HERE FOR FUTURE USE
- (bool) testIfLaunchAgentIsLoaded : (NSString *) agentName
{
    // SET UP TASK & RUN
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObjects:@"list", nil]];

    NSPipe *out = [NSPipe pipe];
    [task setStandardOutput:out];

    [task launch];
    [task waitUntilExit];

    // GET OUTPUT FROM TASK
    NSFileHandle * read = [out fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    
    // LAUNCHAGENT IS LOADED
    if ([stringRead rangeOfString:agentName].location != NSNotFound)
    {
        return YES;
    }
    else // NOT LOADED
    {
        return NO;
    }
}


// CALLED BY INSTALL/UNINSTALL BUTTON IN MAIN WINDOW
- (IBAction) installUninstallEnhancement: (id) sender
{
    bool actionSuccessful = NO;
    NSString *action = @"";
    
    // SET UP PATH
    NSString *basePath = @"/Users/";
    NSString *userName =[basePath stringByAppendingString:NSUserName()];
    NSString *launchAgentsFolderPath =[userName stringByAppendingString:@"/Library/LaunchAgents/"];
    
    // CREATE LAUNCHAGENTS FOLDER IF IT DOES NOT ALREADY EXIST
    @try
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:launchAgentsFolderPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    @catch (NSException *exception) {} @finally {}
    
    // DETERMINE WHICH ENHANCEMENT IS SELECTED
    NSInteger selectedRowIndex = [self.enhancementTable selectedRow];
    NSMutableDictionary *dict = [self.enhancementArrayController.arrangedObjects objectAtIndex: selectedRowIndex];
    
    NSString *plistName = [dict valueForKey:@"PlistName"];
    NSString *plistFile = [dict valueForKey:@"PlistFile"];
    bool agentInstalled = [self isAgentInstalled:plistFile];
    
    // UNINSTALL ACTION
    if (agentInstalled)
    {
        action = @"Uninstall";
        
        @try
        {
            // APPEND PATH WITH SPECIFIC FILE NAME
            NSString *launchAgentPath = [launchAgentsFolderPath stringByAppendingString:plistFile];
            
            // FIRST UNLOAD AGENT FROM LAUNCHD
            NSTask *task = [[NSTask alloc] init];
            [task setLaunchPath:@"/bin/launchctl"];
            [task setArguments:[NSArray arrayWithObjects:@"unload", @"-w", launchAgentPath, nil]];
            [task launch];
            [task waitUntilExit];
            
            // THEN DELETE THE FILE
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:launchAgentPath error:&error];
            
            actionSuccessful = YES;
        }
        @catch (NSException *exception) {} @finally {}
    }
    // INSTALL ACTION
    else
    {
        action = @"Install";
        
        @try
        {
            // GET URL FOR LAUNCH AGENT FILE IN THE APP BUNDLE
            NSURL *source = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]];
            
            // COPY LAUNCH AGENT TO NEW DESTINATION
            NSString *launchAgentPath = [launchAgentsFolderPath stringByAppendingString:plistFile];
            [[NSFileManager defaultManager] copyItemAtURL:source toURL:[NSURL fileURLWithPath:launchAgentPath] error:nil];
            
            // LOAD LAUNCH AGENT IN TO LAUNCHD
            NSTask *task = [[NSTask alloc] init];
            [task setLaunchPath:@"/bin/launchctl"];
            [task setArguments:[NSArray arrayWithObjects:@"load", @"-w", launchAgentPath, nil]];
            [task launch];
            [task waitUntilExit];
            
            actionSuccessful = YES;
        }
        @catch (NSException *exception) {} @finally {}
    }
    
    // CREATE AN ALERT WITH STATUS OF INSTALL/UNINSTALL
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    
    if (actionSuccessful)
    {
        [alert setMessageText:[NSString stringWithFormat:@"%@ was successful", action]];
        [alert setInformativeText:@"If you find Amphetamine and its Enhancer useful, please consider supporting its development."];
        [alert addButtonWithTitle:@"Support Development"];
    }
    else
    {
        [alert setMessageText:@"Installation failed."];
        [alert setInformativeText:@"For troubleshooting guides and assistance, visit iffy.freshdesk.com."];
        [alert addButtonWithTitle:@"Visit Support Site"];
    }
    
    // SHOW ALERT
    [alert beginSheetModalForWindow:self.mainWindow completionHandler:^(NSInteger result)
    {
        // OK BUTTON CLICKED
        if (result == NSAlertFirstButtonReturn)
        {
            [[alert window] orderOut:nil];
        }
        else
        {
            [[alert window] orderOut:nil];
            
            if (actionSuccessful)
            {
                [[NSWorkspace sharedWorkspace] openURL:
                [NSURL URLWithString:@"https://iffy.freshdesk.com/support/solutions/articles/48000078222-supporting-amphetamine-s-development"]];
            }
            else
            {
                [self getHelpOnline:self];
            }
        }
    }];
 
    [self maintainMainWindow];
}


- (void) displayAlert: (NSString *) message : (NSString *) informativeText : (bool) terminate
{
    for (NSRunningApplication * app in [NSRunningApplication runningApplicationsWithBundleIdentifier: @"com.if.Amphetamine Enhancer"])
    {
        @autoreleasepool
        {
            [app activateWithOptions: NSApplicationActivateIgnoringOtherApps];
            break;
        }
    }
    
    [NSApp activateIgnoringOtherApps: YES];
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.informativeText = informativeText;
    alert.messageText = message;
    [alert addButtonWithTitle: @"OK"];

    [alert beginSheetModalForWindow:self.mainWindow completionHandler:^(NSModalResponse returnCode) { if (terminate) [NSApp terminate:self];}];
}


- (IBAction) getHelpOnline : (id) sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://iffy.freshdesk.com/support/solutions/folders/48000662280"]];
}


- (IBAction) openPreferencesWindow : (id) sender
{
    [self.mainWindow beginSheet: self.preferencesWindow completionHandler: ^(NSModalResponse returnCode) {}];
}


- (IBAction) closePreferencesWindow : (id) sender
{
    [NSApp endSheet: self.preferencesWindow];
    [self.preferencesWindow orderOut: nil];
}


// REOPEN THE MAIN WINDOW IF CLOSED WHEN THE DOCK ICON IS CLICKED
- (BOOL) applicationShouldHandleReopen : (NSApplication *) theApplication hasVisibleWindows : (BOOL) flag
{
    if (flag)
    {
        return NO;
    }
    else
    {
        [self.mainWindow makeKeyAndOrderFront:self];
        [self.mainWindow center];
        return YES;
    }
}


- (bool) isMacBook
{
    // MAKE SURE THIS IS A MACBOOK
    bool macIsBook = NO;
    size_t length = 0;
    sysctlbyname("hw.model", NULL, &length, NULL, 0);
 
    if (length)
    {
        char *m = malloc(length * sizeof(char));
        sysctlbyname("hw.model", m, &length, NULL, 0);
        NSString *model = [NSString stringWithUTF8String: m];
    
        macIsBook = ([model rangeOfString: @"Book"].location == NSNotFound) ? NO : YES;
             
        free(m);
    }
    
    return macIsBook;
}


- (IBAction)showAboutWindow: (id) sender
{
    [self.aboutWindow makeKeyAndOrderFront:self];
}


- (NSString *) runTask : (NSArray *) argsArray
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
        
    [task setArguments:argsArray];
        
    NSPipe * taskOutput = [NSPipe pipe];
    [task setStandardOutput:taskOutput];
        
    [task launch];
    [task waitUntilExit];
        
    NSFileHandle * read = [taskOutput fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * taskOutputString = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    
    return taskOutputString;
}


- (void) applicationWillTerminate : (NSNotification *) aNotification
{
}


@end
