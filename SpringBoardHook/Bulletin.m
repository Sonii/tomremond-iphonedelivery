/*
 Copyright (C) 2011 - F. Guillemé
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#include <objc/runtime.h>

#import "SpringBoard.h" 
#import "Bulletin.h" 

@interface SpringBoard {
}
-(BOOL)isLocked;
@end

// Global
static SpringBoard *springboard;
static bool vibrate;
static NSString *sound;

void setDeliveryVibrate(bool v) { vibrate = v; }
bool getDeliveryVibrate() { return vibrate; }
void setDeliverySound(NSString *s) { [sound release]; sound = [s retain]; }
NSString *getDeliverySound() { return sound; }
void setSpringBoard(id o) { springboard = o; }

/** 
 * @brief display an alert through the notification center. If the screen is locked it accumulates
 *        otherwise it is display as a banner that appears a couple of seconds
 * 
 * @param title 
 * @param subtitle 
 * @param message 
 * @param sectionID 
 */
void showBulletin(NSString *title, NSString *subtitle, NSString *message, NSString *sectionID, int group_id, NSDate *date) {
    SBBulletinListController *blc = [objc_getClass("SBBulletinListController") sharedInstance];
    static id observer = nil;
    
    // build a bulletin
    id controller = nil;
    BBBulletin *b2 = nil, *b = [[objc_getClass("BBBulletin") alloc] init];
    [b setTitle:title];
    [b setSectionID:sectionID];
    b.clearable = YES;
    b.date = date;
    b.bulletinID = [NSString stringWithFormat:@"DeliveryReport_%f", [[NSDate date] timeIntervalSince1970]];
    [b setMessage:[NSString stringWithFormat:@"%@ %@", subtitle, message]];

    if (group_id > 0) {
        b.defaultAction = [objc_getClass("BBLaunchAction") 
            actionWithLaunchURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:/open?groupid=%d", group_id]]
            callblock:^(id o) {
                NSLog(@"BBLaunchAction block called %@", o);
                [blc observer:observer removeBulletin:b];
            }];
    }

    if ([springboard isLocked]) {
        b2 = [[objc_getClass("BBBulletin") alloc] init];
        
        [b2 setTitle:title];
        [b2 setSubtitle:message];
        [b2 setMessage:subtitle];
        b2.clearable = YES;
        b2.date = date;
        b2.bulletinID = b.bulletinID;
        b2.defaultAction = b.defaultAction;

        // and as a popup on the away screen
        controller = [[[objc_getClass("SBAwayController") sharedAwayController] awayView] bulletinController];
    }
    else {
        b2 = [b retain];

        // publish it as a banner
        controller = [objc_getClass("SBBulletinBannerController") sharedInstance] ;
    }
    [controller observer:observer addBulletin:b2 forFeed:0];
    [blc observer:observer addBulletin:b forFeed:0];
    [b release];
    [b2 release];
}

void showBulletinBannerOnly(NSString *title, NSString *subtitle, NSString *message, NSString *sectionID, int group_id, NSDate *date) {
    static id observer = nil;

    // build a bulletin
    id controller = nil;
    BBBulletin *b = [[objc_getClass("BBBulletin") alloc] init];
    [b setTitle:title];
    [b setSectionID:sectionID];
    b.clearable = YES;
    b.date = date;
    b.bulletinID = [NSString stringWithFormat:@"DeliveryReport_%f", [[NSDate date] timeIntervalSince1970]];
    [b setMessage:[NSString stringWithFormat:@"%@ %@", subtitle, message]];

    if (group_id > 0)
        b.defaultAction = [objc_getClass("BBLaunchAction") 
            actionWithLaunchURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:/open?groupid=%d", group_id]]
                      callblock:nil];

    // publish it as a banner
    controller = [objc_getClass("SBBulletinBannerController") sharedInstance] ;
    [controller observer:observer addBulletin:b forFeed:0];
    [b release];
}
// vim: ft=objc ts=4 expandtab
