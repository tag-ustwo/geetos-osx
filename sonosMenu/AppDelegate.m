//
//  AppDelegate.m
//  sonosMenu
//
//  Started by Geet.... Finished by AJAX!!! on 18/09/2013.
//  Copyright (c) 2013 ustwo. All rights reserved.
//

#import "AppDelegate.h"
#import "SonosMenuItem.h"

@implementation AppDelegate

NSStatusItem *statusItem;
NSMenu *theMenu;

NSString* const kSettingsPath = @"Library/Application Support/Sonos/jffs/localsettings.txt";

#define LOCAL_SETTINGS_PATH [NSHomeDirectory() stringByAppendingPathComponent:kSettingsPath];

-(void) addAppAsLoginItem{
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
    // This will retrieve the path for the application
    // For example, /Applications/test.app
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
    // Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        //Insert an item to the list.
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
        if (item){
            CFRelease(item);
        }
    }
    
    CFRelease(loginItems);
}

- (void)dealloc
{
    
}
- (IBAction)onClick:(id)sender
{
    SonosMenuItem *tItem = (SonosMenuItem*)sender;
    
    NSLog(@"We clicked %@", tItem.title);
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    NSString *docPath = LOCAL_SETTINGS_PATH;
    
    [manager removeItemAtPath:docPath error:&error];
    
    NSString *contents = [NSString stringWithFormat:@"HouseholdID: [%@]", tItem.houseHoldID];
    [contents writeToFile:docPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    
    // Quit and Relaunch Sonos App
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{

        NSURL* scriptURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"restart-sonos" ofType:@"scpt"]];
        
        NSAppleScript *sonos = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:nil];
        
        [sonos executeAndReturnError:nil];
    });
    
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self addAppAsLoginItem];
    
    
    theMenu = [[NSMenu alloc] initWithTitle:@""];
    theMenu.delegate = self;
    theMenu.autoenablesItems = NO;
    
    // Add items
    [theMenu addItem: [SonosMenuItem sonosMenuItemWithTitle:@"Playground" andHouseHoldID:@"Sonos_Oo0VFqMAPbF3umyHMLjremCNbe"]];
    [theMenu addItem: [SonosMenuItem sonosMenuItemWithTitle:@"JFDI™" andHouseHoldID:@"Sonos_nCLMAzUVvYT0fNQXCrQSdyYQEs"]];
    [theMenu addItem: [SonosMenuItem sonosMenuItemWithTitle:@"The Penthouse" andHouseHoldID:@"Sonos_5WvYLO189Sai40ssNe5th4uxON"]];
    
    for (SonosMenuItem *item in theMenu.itemArray) {
        item.action = @selector(onClick:);
    }
    
    // Add separator & quit item
    [theMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *tItem = [theMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    [tItem setKeyEquivalentModifierMask:NSCommandKeyMask];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    statusItem.image = [NSImage imageNamed:@"status_item_icon"];
    statusItem.alternateImage = [NSImage imageNamed:@"status_item_highlighted_icon"];;
    
    statusItem.highlightMode = YES;
    statusItem.menu = theMenu;
}




#pragma mark - NSMenuDelegate
- (void)menuWillOpen:(NSMenu *)menu NS_AVAILABLE_MAC(10_5) {
    NSString *docPath = LOCAL_SETTINGS_PATH;
    
    NSString *contents = [NSString stringWithContentsOfFile:docPath encoding:NSUTF8StringEncoding error:nil];
    for (SonosMenuItem *item in theMenu.itemArray) {
        if (![item isKindOfClass:[SonosMenuItem class]]) {
            continue;
        }
        if ([contents rangeOfString:item.houseHoldID].location == NSNotFound) {
            item.state = NSOffState;
        } else {
            item.state = NSOnState;
        }
    }
}
@end