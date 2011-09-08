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
void showBulletin(NSString *title, NSString *subtitle, NSString *message, NSString *sectionID) {
    if ([springboard isLocked]) {
        // build a bulletin
        BBBulletin *b = [[objc_getClass("BBBulletin") alloc] init];
        [b setTitle:title];
        [b setSubtitle:message];
        [b setMessage:subtitle];
        [b setSectionID:sectionID];

        NSLog(@"%@", b);

        // and as a popup on the away screen
        [[[[objc_getClass("SBAwayController") sharedAwayController] awayView] bulletinController] observer:0 addBulletin:b forFeed:0];
        [b release];
    }
    else {
        // build a bulletin
        BBBulletin *b = [[objc_getClass("BBBulletin") alloc] init];
        [b setTitle:title];
        [b setMessage:[NSString stringWithFormat:@"%@ %@", subtitle, message]];
        [b setSectionID:sectionID];

        // publish it as a banner
        [[objc_getClass("SBBulletinBannerController")  sharedInstance] observer:0 addBulletin:b forFeed:0];
        [b release];
    }
}
// vim: ft=objc ts=4 expandtab
