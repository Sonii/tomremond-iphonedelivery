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

@interface SBBulletinListController  {
}
+(id)sharedInstance;
-(void)observer:(id)observer addBulletin:(id)bulletin forFeed:(unsigned)feed;
-(void)observer:(id)observer modifyBulletin:(id)bulletin;
-(void)observer:(id)observer removeBulletin:(id)bulletin;
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

@interface NSString(xxx)
-(BOOL)hasTelephonyScheme;
-(BOOL)isAssistantTelephonyURL;
-(BOOL)isValidFaceTimeURL;
-(BOOL)isWebcalURL;
-(BOOL)isStoreServicesURL;

-(void)doesNotRecognizeSelector:(SEL)sel;
@end

@implementation NSString(xxx)
-(BOOL)hasTelephonyScheme {
    return NO;
}
-(BOOL)isAssistantTelephonyURL {
    return NO;
}
-(BOOL)isValidFaceTimeURL {
    return NO;
}
-(BOOL)isWebcalURL {
    return NO;
}
-(BOOL)isStoreServicesURL {
    return NO;
}

-(void)doesNotRecognizeSelector:(SEL)sel {
    NSLog(@"%s %s", __FUNCTION__, sel);
}
@end;

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
    BBBulletin *b = [[objc_getClass("BBBulletin") alloc] init];
    [b setTitle:title];
    [b setSectionID:sectionID];

    // probably not relevant.... Actually it seems to have no impact whatsoever
    b.clearable = YES;
    b.date = date;
    b.expirationDate = [NSDate dateWithTimeIntervalSinceNow:60]; // FIXME change to 3600?
    b.endDate = [NSDate dateWithTimeIntervalSinceNow:60]; // FIXME change to 3600?
    b.bulletinID = [NSString stringWithFormat:@"DeliveryReport_%f", [[NSDate date] timeIntervalSince1970]];

    if (group_id > 0)
        b.defaultAction = [objc_getClass("BBAction") 
#if 0
            actionWithLaunchURL:[NSString stringWithFormat:@"sms:/open?groupid=%d", group_id] 
#else
            actionWithLaunchBundleID:@"com.apple.MobileSMS"
#endif
            callblock:nil];

    if ([springboard isLocked]) {
        [b setSubtitle:message];
        [b setMessage:subtitle];

        // and as a popup on the away screen
        controller = [[[objc_getClass("SBAwayController") sharedAwayController] awayView] bulletinController];
    }
    else {
        [b setMessage:[NSString stringWithFormat:@"%@ %@", subtitle, message]];

        // publish it as a banner
        controller = [objc_getClass("SBBulletinBannerController") sharedInstance] ;
    }
    [controller observer:observer addBulletin:b forFeed:0];
    [blc observer:observer addBulletin:b forFeed:0];
    [b release];
}
// vim: ft=objc ts=4 expandtab
