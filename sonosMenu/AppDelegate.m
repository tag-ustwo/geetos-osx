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
NSString* const kItems = @"items";

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
    SonosMenuItem *item = (SonosMenuItem*)sender;
    NSLog(@"We clicked %@", item.title);
    

    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    // Remove old config and create new one
    NSString *docPath = LOCAL_SETTINGS_PATH;
    [manager removeItemAtPath:docPath error:&error];
    
    NSString *contents = [NSString stringWithFormat:@"HouseholdID: [%@]", item.houseHoldID];
    [contents writeToFile:docPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    
    // Quit and Relaunch Sonos App
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{

        NSURL* scriptURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"restart-sonos" ofType:@"scpt"]];
        
        NSAppleScript *sonos = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:nil];
        
        [sonos executeAndReturnError:nil];
    });
    
    
}
- (void) renderMenu {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *array = [prefs objectForKey:kItems];

    if (!array) {
        NSLog(@"No menu items saved yet");
        return;
    }

    // Clear menu
    [theMenu removeAllItems];


    // Create sonos items from the saved user defaults data
    for (NSDictionary *dict in array) {
        // TODO validate `dict` values
        NSString *title = [dict objectForKey:@"title"];
        NSString *householdID = [dict objectForKey:@"householdID"];

        SonosMenuItem *item = [SonosMenuItem sonosMenuItemWithTitle:title andHouseHoldID:householdID];

        item.action = @selector(onClick:);
        [theMenu addItem: item];
    }

    // Add separator & quit item
    [theMenu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *quitItem = [theMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    [quitItem setKeyEquivalentModifierMask:NSCommandKeyMask];


}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self addAppAsLoginItem];
    
    // Create status bar menu
    theMenu = [[NSMenu alloc] init];
    theMenu.delegate = self;
    theMenu.autoenablesItems = NO;

    // Create status bar item
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    statusItem.image = [NSImage imageNamed:@"status_item_icon"];
    statusItem.alternateImage = [NSImage imageNamed:@"status_item_highlighted_icon"];;
    
    statusItem.highlightMode = YES;
    statusItem.menu = theMenu;

    [self renderMenu];
    [self fetchNewSonosItems];

}

- (void)fetchNewSonosItems {
    NSLog(@"Fetching new Sonos items...");

    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.github.com/ustwo/geetos-osx/master/items.json"]];
    [NSURLConnection connectionWithRequest:req delegate:self];
}

- (void)retryRequestLater {
    NSLog(@".. going to retry request in a bit.");

    [NSTimer timerWithTimeInterval:30 target:self selector:@selector(fetchNewSonosItems) userInfo:nil repeats:NO];
}


#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu NS_AVAILABLE_MAC(10_5) {
    NSString *docPath = LOCAL_SETTINGS_PATH;
    
    
    NSString *contents = [NSString stringWithContentsOfFile:docPath encoding:NSUTF8StringEncoding error:nil];
    for (SonosMenuItem *item in theMenu.itemArray) {
        if (![item isKindOfClass:[SonosMenuItem class]]) {
            continue;
        }
        if (!contents || !item.houseHoldID || [contents rangeOfString:item.houseHoldID].location == NSNotFound) {
            item.state = NSOffState;
        } else {
            item.state = NSOnState;
        }
    }
}
#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Request did fail :(");
    [self retryRequestLater];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"received data %@", jsonString);

    NSError *error = nil;
    NSArray *jsonArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error || ![jsonArray isKindOfClass:[NSArray class]]) {
        NSLog(@"Invalid JSON data fetched!");
        [self retryRequestLater];
        return;
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSArray *savedItems = [prefs objectForKey:kItems];

    if ([savedItems isEqual:jsonArray]) {
        NSLog(@"No changes.");
        return;
    }
    // saving items
    [prefs setObject:jsonArray forKey:kItems];
    [prefs synchronize];


    [self renderMenu];
}

@end