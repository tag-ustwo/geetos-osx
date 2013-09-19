//
//  SonosMenuItem.m
//  sonosMenu
//
//  Created by Geet on 18/09/2013.
//  Copyright (c) 2013 ustwo. All rights reserved.
//

#import "SonosMenuItem.h"

@implementation SonosMenuItem
@synthesize houseHoldID;

+(SonosMenuItem *) sonosMenuItemWithTitle: (NSString* )title andHouseHoldID: (NSString*) houseHoldID {
    SonosMenuItem *item = [[SonosMenuItem alloc] init];
    
    item.title = title;
    item.houseHoldID = houseHoldID;
    
    return item;
}
@end
