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
#import <objc/runtime.h>
#import "Date+extra.h"
#import "NSData+serial.h"
#import "Localizer.h"
#import "SpringBoard.h"

extern "C"{
#import "database.h"
#import "Bulletin.h"
}

#ifndef DEBUG
#define NSLog(arg...)
#endif

static Localizer *localizer;
static Boolean deliveryEnabled;
static int deliveryAlertMethod;

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
static void refreshMobileSMS(NSDictionary *d) {
    CFStringRef s= CFSTR("iphonedelivery.refresh");
    CFNotificationCenterRef nc = CFNotificationCenterGetDarwinNotifyCenter();

    if (nc != nil) CFNotificationCenterPostNotification(nc, s, NULL, NULL, NO);

    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)s object:nil userInfo:d];
}

/** 
 * @brief read the settings
 */
static void readDefaults() {
    Boolean vibrate =  YES;
    Boolean enabled =  YES;
    int alert_method = 2;       // default is notification center
    Boolean exists;
    CFStringRef app = CFSTR("com.guilleme.deliveryreports");

    NSLog(@"%s", __FUNCTION__);

    CFPreferencesSynchronize(app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
    enabled = CFPreferencesGetAppBooleanValue(CFSTR("dr-enabled"), app, &exists);
    if (!exists) enabled = true;
    deliveryEnabled = enabled;

    vibrate = CFPreferencesGetAppBooleanValue(CFSTR("dr-vibrate"), app, &exists);
    if (!exists) vibrate = true;
    setDeliveryVibrate(vibrate);

    CFPropertyListRef value = CFPreferencesCopyValue(CFSTR("dr-style"), app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
    if (value) {
        CFNumberGetValue((CFNumberRef)value, kCFNumberIntType, &alert_method);
    }
    deliveryAlertMethod = alert_method;

    NSLog(@"style = %d value = %@", deliveryAlertMethod, value);

    CFPropertyListRef p = CFPreferencesCopyValue(CFSTR("dr-sound"), app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
    if (p != nil) {
        setDeliverySound((NSString *)(CFStringRef)p);
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
        refreshMobileSMS(dict);
        [dict release];
    }
    return nil;
}

static void playVibeAndSound() {
    bool vibrate = getDeliveryVibrate();
    if (vibrate) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    NSString *s = getDeliverySound();
    if (s != nil) {
        AudioServicesPlaySystemSound([[TLToneManager sharedRingtoneManager] soundIDForToneIdentifier:s]);
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

            switch (deliveryAlertMethod) {
            case 0:     // no alert
                playVibeAndSound();
                break;
            case 1:     // full screen
                if (status == 0 || status > 63) {
                    NSString *str = [NSString stringWithFormat:@"%@\n%@\n%@", 
                                              get_person([dict objectForKey:@"WHO"]),
                                              get_localized_submit(submit_time, sameday),
                                        get_localized_deliver(deliver_time, sameday)];

                    CGRect r = [UIScreen mainScreen].bounds;
                    SBSMSClass0Alert *alert = [[objc_getClass("SBSMSClass0Alert") alloc] initWithString:str];
                    //SBUSSDAlertDisplay *display = [alert display];
                    [alert activate];

                    // the alert dis
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10LL * 1000 * 1000* 1000),
                            dispatch_get_current_queue(), ^{ [alert deactivate]; [alert release]; });

                    playVibeAndSound();
                }
                break;
            case 2:     // notification center
                showBulletin(
                        get_person([dict objectForKey:@"WHO"]),
                        get_localized_submit(submit_time, sameday),
                        get_localized_deliver(deliver_time, sameday),
                        @"com.apple.MobileSMS");
                break;
            case 3:     // simple alert 
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
                    playVibeAndSound();
                }
                break;
            case 4:     // inserted in conversation
                break;
            }
        }
        else {
            NSDate *submit_time = [NSDate dateWithTimeIntervalSince1970:sent_date];
            // update the database if it is a permanent error
            if (status > 63)
                update_sms_for_delivery(who, ref, status, s_date, NULL );

            switch (deliveryAlertMethod) {
            case 0:     // no alert
                playVibeAndSound();
                break;
            case 1:     // full screen
                if (status == 0 || status > 63) {
                    NSString *str = [NSString stringWithFormat:@"%@\n%@\n%@", 
                                              get_person([dict objectForKey:@"WHO"]),
                                              get_localized_submit(submit_time, NO),
                                              get_localized_status(status)];

                    SBSMSClass0Alert *alert = [[objc_getClass("SBSMSClass0Alert") alloc] initWithString:str];
                    [alert activate];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 60LL * 1000 * 1000* 1000),
                            dispatch_get_current_queue(), ^{ [alert deactivate]; [alert release]; });
                    playVibeAndSound();
                }
                break;
            case 2:
                showBulletin(
                    get_person([dict objectForKey:@"WHO"]),
                    get_localized_submit(submit_time, false),
                    get_localized_status(status),
                    @"com.guilleme.deliveryreports");
                break;
            case 3: 
                if (status == 0 || status > 63) {
                    UIAlertViewController *y =[[UIAlertViewController alloc] init];
	                UIAlertView *x = [[UIAlertView alloc] 
                        initWithTitle:get_person([dict objectForKey:@"WHO"])
						      message: [NSString stringWithFormat:@"%@\n%@", 
                                       get_localized_submit(submit_time, NO),
                                       get_localized_status(status)]
						     delegate:y
					cancelButtonTitle:nil
					otherButtonTitles:@"", nil];
                    [x show];
                    playVibeAndSound();
                }
                break;
            case 4:
                break;
            }
        }
        refreshMobileSMS(dict);

        [dict release];
        NSLog(@"CommCenter has received a report %@", dict);
        
        [Localizer release];
        [pool release];


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
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:deliveryEnabled]
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

extern "C" void initObjCLog();
extern "C" void instrumentObjcMessageSends(BOOL); 

%hook SpringBoard

-(void) applicationDidFinishLaunching:(id)appl {
    %orig;
    setSpringBoard(appl);
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
