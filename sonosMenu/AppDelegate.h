//
//  AppDelegate.h
//  sonosMenu
//
//  Created by Geet on 18/09/2013.
//  Copyright (c) 2013 ustwo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, NSURLConnectionDelegate>

@property (assign) IBOutlet NSWindow *window;



#pragma mark - NSMenuDelegate
- (void)menuWillOpen:(NSMenu *)menu NS_AVAILABLE_MAC(10_5);

@end
