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
#import "Date+extra.h"
#import "NSData+serial.h"
#import "Localizer.h"

extern "C"{
#include "database.h"
}

#ifndef DEBUG
#define NSLog(arg...)
#endif

@interface SpringBoard {
}
-(BOOL)isLocked;
@end

@interface UIAlertViewController : NSObject<UIAlertViewDelegate>
@end

@interface SBBulletinBannerController {
}
+(id)sharedInstance;
-(void) observer:(id)o addBulletin:(id)b forFeed:(id)f;
@end

@interface SBAwayController {
}
+(id)sharedAwayController;
-(id)awayView;
-(id)bulletinController;        // pretend it belongs here to get rid of a warning
@end

@interface BBBulletin : NSObject {
}
-(id)init;
-(void)setTitle:(id)title;
-(void)setSubtitle:(id)subtitle;
-(void)setMessage:(id)message;
-(void)setSectionID:(id)section;
-(void)setDefaultAction:(id)action;
@end

@interface SBSMSClass0Alert : NSObject
-(void)initWithString:(NSString *)string;
-(void)activate;
-(void)deactivate;
-(void)setDelegate;
@end

static SpringBoard *springboard;
static Localizer *localizer;
static bool vibrate, enabled, alert_method;
static SystemSoundID sound;

@implementation UIAlertViewController
- (void)alertView:(UIAlertView *)av clickedButtonAtIndex:(int)index {
    [av dismissWithClickedButtonIndex:index animated:YES];
    [av release];
    [self release];
}
@end

/** 
 * @brief tell MobileSMS it needs to refresh the transcript
 */
static void refreshMobileSMS() {
    CFStringRef s= CFSTR("iphonedelivery.refresh");
    CFNotificationCenterRef nc = CFNotificationCenterGetDarwinNotifyCenter();

    if (nc != nil) CFNotificationCenterPostNotification(nc, s, NULL, NULL, NO);
}

/** 
 * @brief read the settings
 */
static void readDefaults() {
    Boolean exists;
    CFStringRef app = CFSTR("com.guilleme.deliveryreports");

    // set the default values
    vibrate = YES;
    enabled = YES;
    alert_method = 2;         // notif center
    sound = 0;

    NSLog(@"%s", __FUNCTION__);

    CFPreferencesSynchronize(app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
    enabled = CFPreferencesGetAppBooleanValue(CFSTR("dr-enabled"), app, &exists);
    if (!exists) enabled = true;
    vibrate = CFPreferencesGetAppBooleanValue(CFSTR("dr-vibrate"), app, &exists);
    if (!exists) vibrate = true;

    CFPropertyListRef value = CFPreferencesCopyValue(CFSTR("dr-style"), app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
    if (value) {
        CFNumberGetValue((CFNumberRef)value, kCFNumberIntType, &alert_method);
    }
    NSLog(@"style = %d value = %@", alert_method, value);

    // regarding the sound it is more appropriate to create it here
    if (sound)  {
        AudioServicesDisposeSystemSoundID(sound);
        sound = 0;
    }

    CFPropertyListRef p = CFPreferencesCopyValue(CFSTR("dr-sound"), app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
    if (p != nil) {
        CFStringRef s = (CFStringRef)p;
        NSLog(@"sound = %@", (NSString*)s);

#if 0
        NSURL *sound_url = [NSURL URLWithString:(NSString *)s];
        NSLog(@"sound URL=%@", sound_url);
        if (sound_url != nil) {
            AudioServicesCreateSystemSoundID((CFURLRef)sound_url, &sound);
            NSLog(@"sound = %@", sound);
        }
#endif
    }
}

/** 
 * @brief convert a phone number to a name
 * 
 * @param number to convert 
 * 
 * @return the name if the number was resolved 
 * @note we need an autoreleae pool
 */
static NSString *get_person(NSString *number) {
    char name[256], surname[256];

    if (convert_num_to_name([number UTF8String], name, surname) && name[0] && surname[0]) {
        return [localizer getTitle:[NSString stringWithUTF8String:name]
                           surname:[NSString stringWithUTF8String:surname]];
    }
    return number;
}

static NSString *get_localized_submit(NSDate *d, bool sameday) {
    NSString *s = [localizer getString:@"SUBMIT"];

    s = [s stringByReplacingOccurrencesOfString:@"%DATESPEC%" withString:[localizer formatDate:d
                                style:NSDateFormatterMediumStyle]];
    s = [s stringByReplacingOccurrencesOfString:@"%TIMESPEC%" withString:[localizer formatTime:d
                                style:sameday?NSDateFormatterMediumStyle:NSDateFormatterNoStyle]];
    return s;
}

static NSString *get_localized_deliver(NSDate *d, bool sameday) {
    NSString *s = [localizer getString:@"DELIVERED"];

    s = [s stringByReplacingOccurrencesOfString:@"%DATESPEC%" withString:[localizer formatDate:d
                                style:sameday?NSDateFormatterNoStyle:NSDateFormatterMediumStyle]];
    s = [s stringByReplacingOccurrencesOfString:@"%TIMESPEC%" withString:[localizer formatTime:d
                                style:sameday?NSDateFormatterMediumStyle:NSDateFormatterNoStyle]];
    return s;
}

static NSString *get_localized_status(uint8_t value) {
    return [localizer getString:[NSString stringWithFormat:@"STATUS_%d", value]];
}

static CFDataRef handle_submit (
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef d,
   void *info
) {
    NSData *data = (NSData*)d;
    NSDictionary *dict = [data unserialize];
    if (dict != nil) {
        const char *who = [[dict objectForKey:@"WHO"] UTF8String];
        uint8_t ref = [[dict objectForKey:@"REF"] intValue];
#ifdef DEBUG
        do {
            NSString *name = get_person([dict objectForKey:@"WHO"]);
            NSNumber *ref = [dict objectForKey:@"REF"];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"WHEN"] intValue]];
            NSLog(@"SMS to %@ sent at %@ ref=%@", name, date, ref);
        } while (0);
#endif
        set_ref_for_last_sent_sms(who, ref);    
        refreshMobileSMS();
        [dict release];
    }
    return nil;
}

static void showBulletin(NSString *title, NSString *subtitle, NSString *message, NSString *sectionID) {
    // dynamicaly get the class so we don´t need to link to a unavailable framework
    Class bf(objc_getClass("BBBulletin"));
    Class cf(objc_getClass("SBBulletinBannerController"));
    Class ca(objc_getClass("SBAwayController"));

    if ([springboard isLocked]) {
        // build a bulletin
        BBBulletin *b = [[bf alloc] init];
        [b setTitle:title];
        [b setSubtitle:message];
        [b setMessage:subtitle];
        [b setSectionID:sectionID];

        NSLog(@"%@ %@", b, [cf sharedInstance]);

        // and as a popup on the away screen
        [[[[ca sharedAwayController] awayView] bulletinController] observer:0 addBulletin:b forFeed:0];
        [b release];
    }
    else {
        // build a bulletin
        BBBulletin *b = [[bf alloc] init];
        [b setTitle:title];
        [b setMessage:[NSString stringWithFormat:@"%@ %@", subtitle, message]];
        [b setSectionID:sectionID];

        NSLog(@"%@ %@", b, [cf sharedInstance]);

        // publish it as a banner
        [[cf  sharedInstance] observer:0 addBulletin:b forFeed:0];
        [b release];
    }
}

static CFDataRef handle_report (
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef d,
   void *info
) {
    NSData *data = (NSData*)d;
    readDefaults();
    NSDictionary *dict = [data unserialize];
    if (dict != nil) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        time_t s_date = [[dict objectForKey:@"WHENSENT"] intValue];
        const char *who = [[dict objectForKey:@"WHO"] UTF8String];
        int status = [[dict objectForKey:@"STATUS"] intValue];
        int ref = [[dict objectForKey:@"REF"] intValue];
        int sent_date = get_sent_time_for_sms(who, ref);
        localizer = [[Localizer alloc] init];

        if (status == 0) {
            time_t d_date = [[dict objectForKey:@"WHENDELIVERED"] intValue];
            int delta = d_date - s_date;
            if (sent_date < 3600*24*365*10) { // ten years. There were no SMS in 1981?
                // HACK in case we don't get the sent date
                sent_date = time(NULL) - delta;
            }
            NSDate *submit_time = [NSDate dateWithTimeIntervalSince1970:sent_date];
            NSDate *deliver_time = [NSDate dateWithTimeIntervalSince1970:sent_date + delta];
            bool sameday = [submit_time isSameDayAs:deliver_time];

            update_sms_for_delivery(who, ref, status, s_date, d_date );

            switch (alert_method) {
            case 2:
                showBulletin(
                        get_person([dict objectForKey:@"WHO"]),
                        get_localized_submit(submit_time, sameday),
                        get_localized_deliver(deliver_time, sameday),
                        @"com.apple.MobileSMS");
                break;
            case 1: 
                if (status == 0 || status > 63) {
                    UIAlertViewController *y =[[UIAlertViewController alloc] init];
	                UIAlertView *x = [[UIAlertView alloc] 
                        initWithTitle:get_person([dict objectForKey:@"WHO"])
						      message:[NSString stringWithFormat:@"%@\n%@",
                                        get_localized_submit(submit_time, sameday),
                                        get_localized_deliver(deliver_time, sameday)] 
						     delegate:y
					cancelButtonTitle:nil
					otherButtonTitles:@"OK", nil];
                    [x show];
                }
                break;
            }
        }
        else {
            NSDate *submit_time = [NSDate dateWithTimeIntervalSince1970:sent_date];
            // update the database if it is a permanent error
            if (status > 63)
                update_sms_for_delivery(who, ref, status, s_date, NULL );

            switch (alert_method) {
            case 2:
                showBulletin(
                    get_person([dict objectForKey:@"WHO"]),
                    get_localized_submit(submit_time, false),
                    get_localized_status(status),
                    @"com.guilleme.deliveryreports");
                break;
            case 1: 
                if (status == 0 || status > 63) {
                    UIAlertViewController *y =[[UIAlertViewController alloc] init];
	                UIAlertView *x = [[UIAlertView alloc] 
                        initWithTitle:get_person([dict objectForKey:@"WHO"])
						      message: get_localized_submit(submit_time, NO)
						     delegate:y
					cancelButtonTitle:nil
					otherButtonTitles:@"", nil];
                    [x show];
                }
                break;
            }

        }

        [dict release];
        NSLog(@"CommCenter has received a report %@", dict);
        
        [Localizer release];
        [pool release];

        refreshMobileSMS();

        // play a sound
        if (vibrate) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        	//AudioServicesAddSystemSoundCompletion( kSystemSoundID_Vibrate, CFRunLoopGetCurrent(), NULL, CompletionCallback, NULL);
        }
        if (sound) {
            AudioServicesPlaySystemSound(sound);
        }
    }
    return nil;
}

static CFDataRef handle_start (
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
    showBulletin( @"iPhoneDelivery", nil,  @"Started...", nil);
    return nil;
}

static CFDataRef handle_receive (
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
    return nil;
}

static CFDataRef handle_enabled (
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
    readDefaults();
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:enabled]
                                                     forKey:@"ENABLED"];
    NSData *d = [NSData serializeFromDictionary:dict];
    return (CFDataRef)d;
}

static void register_port_handler(CFStringRef str, CFMessagePortCallBack cb)  {
    CFMessagePortRef port = CFMessagePortCreateLocal(NULL, str, cb, NULL, NULL);
    CFRunLoopSourceRef source =  CFMessagePortCreateRunLoopSource(NULL, port, 0);

    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
    CFRelease(port);
}

%hook SpringBoard

-(void) applicationDidFinishLaunching:(id)appl {
    %orig;
    springboard = appl;
    NSLog(@"%s", appl);
    register_port_handler(CFSTR("id.submit"), handle_submit);
    register_port_handler(CFSTR("id.report"), handle_report);
    register_port_handler(CFSTR("id.start"), handle_start);
    register_port_handler(CFSTR("id.receive"), handle_receive);
    register_port_handler(CFSTR("id.enabled"), handle_enabled);

    readDefaults();

    [[NSNotificationCenter defaultCenter] 
            addObserverForName:@"com.guilleme.refresh"
            object:nil 
            queue:nil
            usingBlock:^(NSNotification *){ readDefaults(); }];
}
%end
// vim: ft=objc ts=4 expandtab
