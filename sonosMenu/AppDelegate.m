//
//  AppDelegate.m
//  sonosMenu
//
//  Created by Geet on 18/09/2013.
//  Copyright (c) 2013 ustwo. All rights reserved.
//

#import "AppDelegate.h"
#import "SonosMenuItem.h"

@implementation AppDelegate

NSStatusItem *statusItem;
NSMenu *theMenu;



- (void)dealloc
{
    
}
- (IBAction)onClick:(id)sender
{
    SonosMenuItem *tItem = (SonosMenuItem*)sender;
    
    NSLog(@"We clicked %@", tItem.title);
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    NSString *path = @"Library/Application Support/Sonos/jffs/localsettings.txt";
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:path];

    [manager removeItemAtPath:docPath error:&error];

    NSString *contents = [NSString stringWithFormat:@"HouseholdID: [%@]", tItem.houseHoldID];
    [contents writeToFile:docPath atomically:YES encoding:NSUTF8StringEncoding error:&error];

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    
    NSMenuItem *tItem = nil;
    
    theMenu = [[NSMenu alloc] initWithTitle:@""];
    [theMenu setAutoenablesItems:NO];
    
    [theMenu addItem: [SonosMenuItem sonosMenuItemWithTitle:@"Playground" andHouseHoldID:@"Sonos_Oo0VFqMAPbF3umyHMLjremCNbe"]];
    [theMenu addItem: [SonosMenuItem sonosMenuItemWithTitle:@"JFPI™" andHouseHoldID:@"Sonos_nCLMAzUVvYT0fNQXCrQSdyYQEs"]];
    [theMenu addItem: [SonosMenuItem sonosMenuItemWithTitle:@"The Penthouse" andHouseHoldID:@"Sonos_5WvYLO189Sai40ssNe5th4uxON"]];
    
    theMenu.delegate = self;
    
    [theMenu addItem:[NSMenuItem separatorItem]];
    
    
    for (NSMenuItem *item in theMenu.itemArray) {
        item.action = @selector(onClick:);
    }
    
    tItem = [theMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    [tItem setKeyEquivalentModifierMask:NSCommandKeyMask];


    statusItem = [[NSStatusBar systemStatusBar]statusItemWithLength:NSSquareStatusItemLength];
    NSImage *statusImage = [NSImage imageNamed:@"status_item_icon"];
    [statusItem setImage:statusImage];
    NSImage *altStatusImage = [NSImage imageNamed:@"status_item_highlighted_icon"];
    [statusItem setAlternateImage:altStatusImage];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:theMenu];
    
    
    
}



#pragma mark - NSMenuDelegate
- (void)menuWillOpen:(NSMenu *)menu NS_AVAILABLE_MAC(10_5) {
    NSString *path = @"Library/Application Support/Sonos/jffs/localsettings.txt";
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    
    NSString *contents = [NSString stringWithContentsOfFile:docPath encoding:NSUTF8StringEncoding error:nil];
    for (SonosMenuItem *item in theMenu.itemArray) {
        if ([contents rangeOfString:item.houseHoldID].location == NSNotFound) {
            item.state = NSOffState;
        } else {
            item.state = NSOnState;
        }
    }
}
@end