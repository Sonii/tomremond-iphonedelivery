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

static SBApplication * get_front_app() {
    NSArray *apps = [[objc_getClass("SBApplicationController") sharedInstance] allApplications];
    BOOL (^is_front)(id obj, NSUInteger idx, BOOL *stop)= ^BOOL (SBApplication *a, NSUInteger n,BOOL*stop) { 
        if (a.process.frontmost) {
            *stop = YES;
            return YES;
        }
        return NO;
    };
    NSUInteger n = [apps indexOfObjectPassingTest:is_front];
    return n == NSNotFound ? nil : [apps objectAtIndex:n];
}

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
    BBBulletin *b2, *b = [[objc_getClass("BBBulletin") alloc] init];
    b.title = title;
    b.sectionID = sectionID;
    b.clearable = YES;
    b.date = date;
    b.bulletinID = [NSString stringWithFormat:@"DeliveryReport_%f", [[NSDate date] timeIntervalSince1970]];
    b.message = [NSString stringWithFormat:@"%@ %@", subtitle, message];

    if (group_id > 0) {
        b.defaultAction = [objc_getClass("BBLaunchAction") 
            actionWithLaunchURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:/open?groupid=%d", group_id]]
            callblock:^(id o) {
                // it does not work anyway
                NSLog(@"BBLaunchAction block called %@", o);
                [blc observer:observer removeBulletin:b];
            }];
    }

    b2 = [[objc_getClass("BBBulletin") alloc] init];
    b2.title = title;
    b2.subtitle = message;
    b2.message = subtitle;
    b2.sectionID = sectionID;
    b2.clearable = YES;
    b2.date = date;
    b2.bulletinID = b.bulletinID;
    b2.defaultAction = b.defaultAction;

    NSString *s = b.message;
    CGSize size = [s sizeWithFont:[UIFont systemFontOfSize:8]];
    NSLog(@"Bulletin width = %.1f", size.width);

    if ([springboard isLocked]) {
        id controller = nil;
        // and as a popup on the away screen
        controller = [[[objc_getClass("SBAwayController") sharedAwayController] awayView] bulletinController];
        [controller observer:observer addBulletin:b2 forFeed:0];
    }
    else {
        id controller = nil;
        // publish it as a banner
        controller = [objc_getClass("SBBulletinBannerController") sharedInstance] ;

        [controller observer:observer addBulletin:b forFeed:0];
    }

    // if the fron app is sms something then do not inset the bulletin
    SBApplication *front = get_front_app();
    NSLog(@"front app = %@", front);
    if (front == nil || ! [[[front bundleIdentifier] uppercaseString] hasSuffix:@"SMS"]) { 
        NSLog(@"insert notification");
        // depending on the length of the message we use the one line/two lines version of the bulletin
        if (size.width > 180)
            [blc observer:observer addBulletin:b2 forFeed:0];
        else
            [blc observer:observer addBulletin:b forFeed:0];
    }
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
