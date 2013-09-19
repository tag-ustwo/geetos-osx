//
//  SonosMenuItem.h
//  sonosMenu
//
//  Created by Geet on 18/09/2013.
//  Copyright (c) 2013 ustwo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SonosMenuItem : NSMenuItem

+(SonosMenuItem *) sonosMenuItemWithTitle: (NSString* )title andHouseHoldID: (NSString*) houseHoldID;


@property (nonatomic, strong) NSString *houseHoldID;

@end
