/** 
 Copyright (C) 2009 - François Guillemé
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

#include <stdio.h>
#include <fcntl.h>
#include <time.h>
#include <unistd.h>

#include <objc/runtime.h>

#include <substrate.h>

#ifndef RUN_CLANG_STATIC_ANALYZER
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "ChatKit.h"

extern "C"{
#import "AppSupport.h"
}

#import "DeliveryDateView.h"
#import "MarkView.h"

extern "C" {
#import "../sms_db.h"
}

#define ZZHOOK(ret,name, arg...) \
    static IMP _ ## name; \
    static ret $ ## name (id self, SEL sel, arg)

#define ZZHOOK_METHOD(cls,sel,imp) do { \
    Class _cls(objc_getClass(#cls)); \
    Method _method = class_getInstanceMethod(_cls,  @selector(sel)); \
    if (_method == NULL) \
        NSLog(@"%s:%d class_getInstanceMethod(%s,%s) returned nil\n", __FUNCTION__, __LINE__, # cls, #sel); \
    else \
        _ ## imp = method_setImplementation(_method,  (IMP)$ ## imp); \
    NSLog(@"%s:%d hook %s %s\n", __FILE__, __LINE__, # sel, (  _ ## imp != NULL ?  "succeeded" : "failed") ); \
} while(0)

#define DEBUG 1
#if DEBUG
#define  NSLog(arg...) NSLog(arg)
#else
#define NSLog(arg...) do { } while (0)
#endif

#define TRACE(arg...) NSLog(arg)

#define SMS_DB "/private/var/mobile/Library/SMS/sms.db"
#define AB_DB "/private/var/mobile/Library/AddressBook/AddressBook.sqlitedb"

#define MAX_STR_SIZE 128

static CPRecordStoreRef sms_db;

static NSString *failed_mark, *delivered_mark, *expired_mark, *pending_mark;
static int marking_mode;
static BOOL isEditing;
static UIColor *tick_color=nil;
static Boolean convert_smiley = true;

@interface SMSApplication : NSObject {
}
-(CKConversationListController*)conversationListController;
@end

// TODO we must use a cache dict to avoid reading the db too often
enum {
	e_pending,
	e_delivered,
	e_noinfo,
	e_expired,
	e_error
};

int get_message_status(int rowid, int *ref, int  *date) {
	int rc = info4rowid(rowid, ref, date);

	if (rc == 0 && *ref != 0 && *date == 0)
		return e_pending;
	else if (rc == 0 && *ref == 0 && *date > 1)
		return e_delivered;
	else if (rc == 0 && *ref == 0 && *date == 1)
		return e_expired;
	else if (rc == 0 && *ref == 0 && *date == 0)
		return e_noinfo;
	else
		return e_error;
}

/** 
 * @brief called when the CommCenter changes the text  of the SMS and the MobileSMS app needs to refresh the bubble
 * 
 * @param center 
 * @param observer 
 * @param name 
 * @param object 
 * @param userInfo 

 * TODO we might also refreh the conversation list
 */
static void launch_cb (
   CFNotificationCenterRef center,
   void *observer,
   CFStringRef name,
   const void *object,
   CFDictionaryRef userInfo
) {
    SMSApplication *appl =(id) observer;

	if (appl == nil) appl = [UIApplication sharedApplication];

	CKConversationListController *cc = [appl conversationListController];
	CKTranscriptController *tc = [cc transcriptController];

    NSLog(@"%s:%s %@\n", __FILE__, __FUNCTION__, appl);

	// this is the secret! invalidate the cache so the store is reloaded from disk
    if (sms_db != NULL) CPRecordStoreInvalidateCaches(sms_db);

	if (tc != nil) {
    	id conv = [tc conversation];
    	if (conv != nil) {
			// reload the conversation
        	[conv _reloadMessagesToLimit];

			// refresh the transcript
        	[tc _refreshTranscript];
		}
    		
		// reset the status (one of these is probably enough...) othersise it thinks it is sending more messages
		CKTranscriptStatusController *sb = [tc _statusBar];

		NSLog(@"%s %@", __FUNCTION__, sb);

		[sb _finishProgress];
		if ([sb respondsToSelector:@selector(_resetProgress)])
			[sb _resetProgress];
		[sb reset];
	}
}

ZZHOOK(void, CKMessageEntryView_initWithFrame, CGRect frame) {
	_CKMessageEntryView_initWithFrame(self, sel, frame);
	while (0) {
		const unichar cc[] = { 0x0e56 };
		NSString *smiley = [NSString stringWithCharacters:cc length:1];
		UIFont *f = [UIFont systemFontOfSize:24];
		CGSize sz = [smiley sizeWithFont:f];
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, sz.width+16, sz.height+16)];
		button.titleLabel.font = f;

		[button setTitle:smiley forState:UIControlStateNormal];

		[button setBackgroundColor:[UIColor clearColor]];  
		button.showsTouchWhenHighlighted = YES;

		//[button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:button];
		[button release];
	}
}

/** 
 * @brief hook the application launch to receive notifications from CommCenter
 */
ZZHOOK(void, SMSApplication_applicationDidFinishLaunching, id appl) {
    CFNotificationCenterRef nc = CFNotificationCenterGetDarwinNotifyCenter();
    
    CFNotificationCenterAddObserver(nc, appl, launch_cb,  
            CFSTR("com.iphonedelivery.MobileSMS.refresh"), NULL,
            CFNotificationSuspensionBehaviorCoalesce);

    NSLog(@"%s:%s\n", __FILE__, __FUNCTION__);
    _SMSApplication_applicationDidFinishLaunching(self, sel, appl);
}

void iOS4_SMSApplication_applicationDidFinishLaunching(id appl) {
    CFNotificationCenterRef nc = CFNotificationCenterGetDarwinNotifyCenter();
    
    CFNotificationCenterAddObserver(nc, appl, launch_cb,  
            CFSTR("com.iphonedelivery.MobileSMS.refresh"), NULL,
            CFNotificationSuspensionBehaviorCoalesce);

    NSLog(@"%s:%s\n", __FILE__, __FUNCTION__);
}

static void load_preferences();

ZZHOOK(void, SMSApplication_applicationWillEnterForeground, id appl) {
	_SMSApplication_applicationWillEnterForeground(self, sel, appl);
	load_preferences();
}

/** 
 * @brief hook to remember the reference of the SMS store
 */
MSHook(CPRecordStoreRef, CPRecordStoreCreateWithPath, CFStringRef name) {
    CPRecordStoreRef res= _CPRecordStoreCreateWithPath(name);
    NSLog(@"%s %@\n", __FUNCTION__, name);
    if (CFStringHasSuffix(name, CFSTR("sms.db"))) {
        sms_db = res;
    }
    return res;
}

/** 
 * @brief find out the rowid from the cell. Needed to get the row from the db and find out its status
 * 
 * @param tc Transcript controller managing the table owning this cell
 * @param row number
 * @param cell to investigate
 * 
 * @return the rowid or ..... well it is not supposed to fail...
 */
static int rowid4cell(CKTranscriptController *tc, int row, id cell) {

	CKSMSMessage *message = [[tc bubbleData] messageAtIndex:row];

	if (message == nil) return 0;

	// check if the message is outgoing or has not been sent yet
	if ([message sentCount] == 0 || ![message isOutgoing]) return 0;

	CKSMSRecordRef msg;
	int n= [message messageCount];

	if (n == 0) return 0;

	msg = [[message messages] objectAtIndex:0];

	// Ok it is very ugly but I have no idea about the kind of object it is
	return  ((int *)msg)[3];
}

/** 
 * @brief hook single tap
 I want to display the delivery date as a menu...
 */
ZZHOOK(void, CKTranscriptController_messageCellTappedBalloon, id cell) {
	if (!isEditing) {
		NSIndexPath *path = [[self transcriptTable] indexPathForCell:cell];
		CKMessageCell *c = cell;
		CKBalloonView *bv = c.balloonView;
		int rowid = rowid4cell(self, [path row], cell);
		int date=0, ref=0;
		int status = get_message_status(rowid, &ref, &date);

		if ([DeliveryDateView undisplay:bv] && status == e_delivered && date > 1) {
			NSDate *d = [NSDate dateWithTimeIntervalSince1970:date];

			DeliveryDateView *dv = [[DeliveryDateView alloc] initWithDate:d 
				forBalloonRect:[bv balloonBounds]
				andRowid:rowid];
			[bv addSubview:dv];

		}
	}
    _CKTranscriptController_messageCellTappedBalloon(self, sel, cell);
}

static NSString *replaceSmileys(NSString *s) {
	struct {
		NSString *str, *repl;
	}
	smileys[]= {
		{	@":-)",  @"",	},		// smile: 0xe414
		{	@":)",  @"",	},		// smile: 0xe414

		{	@"^^",  @"",	},		// smile: 0xe056
		
		{	@":-(",	@""	},		// sad: e058
		{	@":(",	@""	},		// sad: e058
		
		{	@":-D",	@""	},		// laugh: e057
		{	@":D",	@""	},		// laugh: e057
		{	@"lol",	@""	},		// laugh: e415

		{	@"(L)",	@""	},		// e106
		{	@"(K)",	@"" 	},		// e418
		{	@"(H)",	@"" 	},		// e402
		
		{	@":-P",	@""	},		// tongue: e105
		{	@":P",	@""	},		// tongue: e105

		{  	@";-)",	@"" 	},		// wink: e405
		{  	@";)",	@"" 	},		// wink: e405
		
		{	@":o",	@""	},		// surprised: e40d
		{	@":-o",	@""	},		// surprised: e40d
		
		{	@":|",	@""	},		// e404
		{	@" :/",	@""	},		// e108
		{	@":-/",	@""	},		// e108
		{	@":x",	@""	},		// e407

		{	@">_<",	@""	},		// e409
		{	@"-_-",	@""	},		// e40e

		{ 	@":@", 	@""	},		// angry: e416
		{ 	@":-@", @""	},		// angry: e416

		{	@":-S",	@"" 	},		// crossed: e407
		{	@":S",	@"" 	},		// crossed: e407

		{ 	@":$", 	@"" 	},		// dumb : e417
		{ 	@":-$", @"" 	},		// dumb : e417 

		{	@"B-)",	@""	},		// star: e106 but not correct

		{	@":'(",	@""	},		// crying: e401

		{	@":-*",	@""	},		// kiss: e418
		{	@":*",	@""	},		// kiss: e418
	};

	for (int i = 0; i < sizeof(smileys)/sizeof(smileys[0]); i++) {
			s = [s stringByReplacingOccurrencesOfString:smileys[i].str 
				                              withString:smileys[i].repl
				                                options:NSCaseInsensitiveSearch   
												range:NSMakeRange(0, [s length])];
	}

	return s;
}

static NSString *replaceEmoji(NSString *s) {
	struct {
		NSString *repl, *str;
	}
	smileys[]= {
		{	@":-)",  @"",	},		// smile: 0xe056
		{	@":-(",	@""	},		// sad: e058
		{	@":(",	@""	},		// sad: e058
		{	@":-D",	@""	},		// laugh: e057
		{	@":-P",	@""	},		// tongue: e105
		{  	@";-)",	@"" 	},		// wink: e405
		{	@":-o",	@""	},		// surprised: e107
		{ 	@":@", 	@""	},		// angry: e416
		{	@":-S",	@"" 	},		// crossed: e407
		{ 	@":$", 	@"" 	},		// embarassed: e40d
		{	@"B-)",	@""	},		// star: e106 but not correct
		{	@":'(",	@""	},		// crying: e413
		{	@":-*",	@""	},		// kiss: e418
	};

	for (int i = 0; i < sizeof(smileys)/sizeof(smileys[0]); i++) {
		if ([s rangeOfString:smileys[i].str].location != NSNotFound) {
			s = [s stringByReplacingOccurrencesOfString:smileys[i].str  withString:smileys[i].repl
					options:NSCaseInsensitiveSearch   range:NSMakeRange(0, [s length])];
		}
	}

	return s;
}


#define DEFAULT_PENDING_MARK @"♒ "
#define DEFAULT_DELIVERED_MARK @"✔"
#define DEFAULT_EXPIRED_MARK @"☹"
#define DEFAULT_ERROR_MARK @"☹"

/** 
 * @brief remove those ugly marks
 */
ZZHOOK(NSString *, CKTranscriptBubbleData_textAtIndex, int n) {
	NSString *s = _CKTranscriptBubbleData_textAtIndex(self, sel, n);
	NSString *prefix[] = {
		pending_mark,
		delivered_mark,
		failed_mark,
		expired_mark,
		DEFAULT_PENDING_MARK,
		DEFAULT_DELIVERED_MARK,
		DEFAULT_EXPIRED_MARK,
		DEFAULT_ERROR_MARK,
	};

	for (int i = 0; i < sizeof(prefix)/sizeof(prefix[0]); i++) {
    	if ([s hasPrefix:prefix[i]]) {
			s = [s substringFromIndex:[prefix[i] length]];
			break;
		}
	}

	if (convert_smiley == YES)
		s = replaceSmileys(s);

	return s;
}

ZZHOOK(int, CKTranscriptBubbleData_heightAtIndex, int n) {
	CKTranscriptBubbleData *_self = self;
	int height = (int)_CKTranscriptBubbleData_heightAtIndex(self, sel, n);
	Class c = [_self balloonClassAtIndex:n];
	NSString *str = [_self textAtIndex:n];

	if (1 || [str containsEmoji]) {
		CGFloat w = _self.balloonWidth;
		height = [c heightForText:str width:w];
	}
	return height;
}

ZZHOOK(UITableViewCell *, CKTranscriptController_cellForRowAtIndexPath, id tv,  NSIndexPath *path) {
	id cell = _CKTranscriptController_cellForRowAtIndexPath(self, sel,tv,  path);

	if ([cell isKindOfClass:[CKMessageCell class]]) {
		int date = 0, ref = 0;
		CKMessageCell *c = cell;
		CKBalloonView *v = c.balloonView;
		int rowid = rowid4cell(self, [path row], cell);

		v.alpha =1.0;

		// as view are reused remove the mark if any
		[MarkView removeMark:v];

		// if it is a reuse, remove the date popup
		if (rowid != 0 && rowid != [DeliveryDateView rowid])
			[DeliveryDateView undisplay:v];

		if (rowid > 0) {
			int status = get_message_status(rowid, &ref, &date);

			//NSLog(@"status = %d", status);

			switch (status) {
			case e_noinfo:											// no indication
				v.alpha =1.0;
				if (marking_mode == 1) {							// normal only
					[v addSubview:[[MarkView alloc]
						init:delivered_mark 
						size:16 
						leftOf:[v balloonBounds]
						markColor:[UIColor lightGrayColor]]];
				}
				break;

			case e_delivered:
				v.alpha = 1.0;

				if (marking_mode == 1) {							// normal only
					[v addSubview:[[MarkView alloc]
						init:delivered_mark 
						size:16 
						leftOf:[v balloonBounds]
						markColor:tick_color]];
				}
				break;

			case e_expired:
				v.alpha = 0.7;

				if (marking_mode == 0 || marking_mode == 1) {		// discreet and normal
					[v addSubview:[[MarkView alloc]
						init:expired_mark
						size:24
						leftOf:[v balloonBounds]
						markColor:[UIColor redColor]]];
				}
				break;

			case e_error:
				v.alpha = 0.7;

				if (marking_mode == 0 || marking_mode == 1) {
					[v addSubview:[[MarkView alloc]
						init:failed_mark
						size:24
						leftOf:[v balloonBounds]
						markColor:[UIColor redColor]]];
				}
				break;

			case e_pending:
				v.alpha = 0.6;
				break;

			default:
				NSLog(@"%s:%d bad message status", __FUNCTION__, __LINE__);
				break;
			}
		}
	}
	return cell;
}

ZZHOOK(void,CKTranscriptController_setEditing_animated,BOOL editing, BOOL animated) {
	isEditing = editing;
	//NSLog(@"%s: editing=%d animated=%d", __FUNCTION__, editing, animated);

	_CKTranscriptController_setEditing_animated(self, sel, editing, animated);
}

ZZHOOK(void,CKTranscriptController_startCreatingNewMessageForSending, CKMessageStandaloneComposition *c) {
	// only replace outgoing emojis if text starts with a space 
	// otherwise iphone to iphone sms would result into bad sms as
	// the recipient would need a JB iphone with iphonedelivery to view emojis
	if ([[c textString] hasPrefix:@" "])
		[c setTextString:replaceEmoji([c textString])];

	_CKTranscriptController_startCreatingNewMessageForSending(self, sel, c);
}

static uint32_t ReplaceSystemSound(uint32_t inSystemSoundID) {
    static SystemSoundID codes[] = { 0, 1012, 1008, 1009, 1010, 1012, 1013, 1014, 1011 };
    NSNumber *sms_sound = (NSNumber *)CFPreferencesCopyAppValue (CFSTR("sms-sound"), CFSTR("com.apple.springboard"));
    int snd = (sms_sound != nil ? [sms_sound intValue]:1);

    TRACE(@"%d %d %d\n", (int)inSystemSoundID, snd, (int)codes[snd]);

    if (snd >= 0 && snd <= 7 && inSystemSoundID == codes[snd]) {
        int dr_fd = open("/var/tmp/last_dr", O_RDONLY);

        if (dr_fd >= 0) {
            struct {
                time_t then;
                uint8_t status;
            } sig;
            time_t now = time(NULL);
        
            TRACE(@"now = %d\n", (int)now);

            if (sizeof(sig) == read(dr_fd, &sig, sizeof(sig))) {
                NSNumber *dr_sound = (NSNumber *)CFPreferencesCopyAppValue (CFSTR("dr-sound"), CFSTR("com.apple.springboard"));

                TRACE(@"dr_time = %d, diff = %d\n", (int)sig.then, (int)(now-sig.then));

                if (dr_sound != nil)
                    TRACE(@"configured dr_sound = %d\n", [dr_sound intValue]);

                if (now <= sig.then + 1) {
                    // disable the sound if the message was a temporary one or we have a bad setting
                    if  ((sig.status & 32) == 0 && dr_sound != nil && [dr_sound intValue] >= 0 && [dr_sound intValue] <= 8)
                        inSystemSoundID = codes[[dr_sound intValue]];
                    else
                        inSystemSoundID = 0;
                }
                TRACE(@"selected dr-sound = %d\n", (int)inSystemSoundID);
                if (dr_sound != NULL) [dr_sound release];
            }
            close(dr_fd);
        }
    }
    [sms_sound release];

    TRACE(@"inSystemSoundID = %d\n", (int)inSystemSoundID);
	return inSystemSoundID;
}

MSHook(void, AudioServicesPlaySystemSound, SystemSoundID sound) {
	sound = ReplaceSystemSound(sound);
	if (sound != 0 && _AudioServicesPlaySystemSound != NULL) 
		_AudioServicesPlaySystemSound(sound);
}

UIColor *load_color(const CFStringRef key, UIColor *defColor) {
    const void *data = CFPreferencesCopyAppValue(key, kCFPreferencesCurrentApplication);
	UIColor *color = defColor;
	
	if (data != NULL) {
		CFTypeID type = CFGetTypeID(data);
		NSLog(@"color-data = %@", CFCopyDescription(data));
	
		if (CFArrayGetTypeID() == type) {
			CFArrayRef rgb = (CFArrayRef)data;
			NSLog(@"rgb = %@", rgb);
			if (CFArrayGetCount(rgb) == 3) {
					float r, g, b;
					NSLog(@"count=4");
					CFNumberGetValue((CFNumberRef)CFArrayGetValueAtIndex(rgb, 0), kCFNumberFloat32Type, &r);
					CFNumberGetValue((CFNumberRef)CFArrayGetValueAtIndex(rgb, 1), kCFNumberFloat32Type, &g);
					CFNumberGetValue((CFNumberRef)CFArrayGetValueAtIndex(rgb, 2), kCFNumberFloat32Type, &b);

					color = [[[UIColor alloc] initWithRed:r green:g blue:b alpha:1.0] retain];
					NSLog(@"color=%@", color);
			}
		}
	}

	return color;
}

static void load_preferences() {

	failed_mark = (NSString *)CFPreferencesCopyAppValue(CFSTR("error-mark"), kCFPreferencesCurrentApplication);
	if (failed_mark == nil) 
		failed_mark = @"✘";

	delivered_mark = (NSString *)CFPreferencesCopyAppValue(CFSTR("delivered-mark"), kCFPreferencesCurrentApplication);
	if (delivered_mark == nil) 
		delivered_mark = @"✔";

	expired_mark = (NSString *)CFPreferencesCopyAppValue(CFSTR("expired-mark"), kCFPreferencesCurrentApplication);
	if (expired_mark == nil) 
		expired_mark =  @"☹";

	pending_mark = (NSString *)CFPreferencesCopyAppValue(CFSTR("pending-mark"), kCFPreferencesCurrentApplication);
	if (pending_mark == nil) 
		pending_mark = @"♒ ";

	marking_mode = CFPreferencesGetAppIntegerValue(CFSTR("DeliveryMark"), kCFPreferencesCurrentApplication, NULL);

	Boolean exists = NO;
	convert_smiley = CFPreferencesGetAppBooleanValue(CFSTR("convert-smiley"), kCFPreferencesCurrentApplication, &exists);
	if (exists == false) convert_smiley = YES;

	NSLog(@"convert_smiley = %d", convert_smiley);

	CFPreferencesSetValue(CFSTR("convert-smiley"), [NSNumber numberWithBool:convert_smiley], kCFPreferencesCurrentApplication,
			kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);

	tick_color = load_color(CFSTR("tick-color"), [UIColor orangeColor]);
	NSLog(@"tick-color = %@", tick_color);
}

static CFDataRef handle_hasmessage (
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
	const void *ptr = CFDataGetBytePtr(data);
	int ref = *(const int *)ptr;

	NSLog(@"CommCenter asks if message %d is valid", ref);

	uint16_t ret = has_message_in_db(ref);
	return CFDataCreate(NULL, (const UInt8*)&ret, sizeof(ret));
}

static CFDataRef handle_sendingdate (
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
	const void *ptr = CFDataGetBytePtr(data);
	int ref = *(const int *)ptr;

	NSDate *d = sendingDate(ref);
	NSLog(@"CommCenter asks the sending date of %d -> %@", ref, d);
	
	int n;

	if (d == nil)
		n = 0;
	else
		n = [d timeIntervalSince1970];

	return CFDataCreate(NULL, (const unsigned char *)&n, sizeof(n));
}

static CFDataRef handle_messagerowid (
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
	const void *ptr = CFDataGetBytePtr(data);

	NSLog(@"CommCenter asks rowid of last message to %s", ptr);

	uint32_t rowid =  rowid_of_sent_sms((const char*)ptr);
	return  CFDataCreate(NULL, (const unsigned char *)&rowid, sizeof(rowid));
}

static CFDataRef handle_num2person (
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
	const void *ptr = CFDataGetBytePtr(data);

	NSLog(@"CommCenter asks name of %s", ptr);

	char name[256];
	char *surname = name + 128;
	CFDataRef answer = NULL;

	if (name4num((const char *)ptr, name, surname)) {
		int n = strlen(name) + 1 + strlen(surname) + 1;
		strcpy(name + strlen(name)+1, surname );

		answer = CFDataCreate(NULL, (const UInt8*)name, n);
	}
	return answer;
}

#if 0
static CFDataRef handle_num2person (
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
	CFDataRef result = NULL;
	NSError *error = nil;
	NSLog(@"data = %@", data);
	NSString *caller = [NSPropertyListSerialization propertyListWithData:(NSData*)data
								options:0
								format:(NSPropertyListFormat*)NSPropertyListXMLFormat_v1_0
								error:&error];

	NSLog(@"caller = %@", caller);

	if (caller != nil && [caller isKindOfClass:[NSArray class]]) {
		char name[256];
		char *surname = name + 128;

		NSLog(@"CommCenter asks name of %s", caller);
		if (name4num([caller UTF8String], name, surname)) {
			NSString *error = nil;
			NSArray *answer = [NSArray arrayWithObjects:
					[NSString stringWithUTF8String:name],
					[NSString stringWithUTF8String:surname],
					nil];
			result = (CFDataRef)[NSPropertyListSerialization dataFromPropertyList:answer
                                       	   format:NSPropertyListXMLFormat_v1_0
                                       	   errorDescription:&error];
			if (error != nil) {
				NSLog(@"%s: %@", __FUNCTION__, error);
				[error release];
			}
		}
	}
	else if (error != nil) {
		NSLog(@"%s: %@", __FUNCTION__, error);
		[error release];
	}
	return result;
}
#endif

static CFDataRef handle_status_error (
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
	const void *ptr = CFDataGetBytePtr(data);
	int ref = *(const int *)ptr;

	NSLog(@"CommCenter set %d as error", ref);
	update_message_status(ref, 0, -1000);
	return NULL;
}

static CFDataRef handle_updatestatus(
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
	const void *ptr = CFDataGetBytePtr(data);
	 struct { uint32_t a, b; } msg;
	
	memcpy(&msg, ptr, sizeof(msg));

	NSLog(@"CommCenter set status of %d : %d", msg.a, msg.b);
	update_message_status(msg.a, 0, msg.b);

	CFStringRef s= CFSTR("com.iphonedelivery.MobileSMS.refresh");
	CFNotificationCenterRef nc = CFNotificationCenterGetDarwinNotifyCenter();

	NSLog(@"posting SMS notification  %@", s);

    if (nc != nil) CFNotificationCenterPostNotification(nc, s, NULL, NULL, NO);

	return NULL;
}

static CFDataRef handle_smscref(
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
	const void *ptr = CFDataGetBytePtr(data);
	 struct { uint32_t a, b; } msg;
	
	memcpy(&msg, ptr, sizeof(msg));

	NSLog(@"CommCenter set smsc ref of %d : %d", msg.a, msg.b);
	set_smsc_ref(msg.a, msg.b);
	return NULL;
}

static CFDataRef handle_getsound(
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
	NSLog(@"CommCenter needs sound");
	uint32_t n = get_delivery_sound();
	return  CFDataCreate(NULL, (const unsigned char *)&n, sizeof(n));
}

static CFDataRef handle_getlocale(
   CFMessagePortRef local,
   SInt32 msgid,
   CFDataRef data,
   void *info
) {
	char locale[8];
	
	NSLog(@"CommCenter needs locale");
	get_locale(locale);
	return  CFDataCreate(NULL, (const unsigned char *)locale, sizeof(locale));
}

static void register_port_handler(CFStringRef str, CFMessagePortCallBack cb)  {
	CFMessagePortRef port = CFMessagePortCreateLocal(NULL, str, cb, NULL, NULL);
	CFRunLoopSourceRef source =  CFMessagePortCreateRunLoopSource(NULL, port, 0);

	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
	CFRelease(source);
	CFRelease(port);
}

extern "C" void iPhoneDeliveryMSInitialize() {

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];

	NSLog(@"injecting iPhoneDelivery in %@ at %@", identifier, [[NSBundle mainBundle] bundlePath]);
#if 0
	if ([identifier isEqualToString:@"com.apple.springboard"]) {
		MSHookFunction(AudioServicesPlaySystemSound, $AudioServicesPlaySystemSound,
				&_AudioServicesPlaySystemSound);

		register_port_handler(CFSTR("iphonedelivery.hasmessage"), handle_hasmessage);
		register_port_handler(CFSTR("iphonedelivery.messagerowid"), handle_messagerowid);
		register_port_handler(CFSTR("iphonedelivery.sendingdate"), handle_sendingdate);
		register_port_handler(CFSTR("iphonedelivery.num2person"), handle_num2person);
		register_port_handler(CFSTR("iphonedelivery.status_error"), handle_status_error);
		register_port_handler(CFSTR("iphonedelivery.updatestatus"), handle_updatestatus);
		register_port_handler(CFSTR("iphonedelivery.smscref"), handle_smscref);
		register_port_handler(CFSTR("iphonedelivery.getsound"), handle_getsound);
		register_port_handler(CFSTR("iphonedelivery.getlocale"), handle_getlocale);
	}

    if ([identifier isEqualToString:@"com.apple.MobileSMS"]) {
		load_preferences();

	    MSHookFunction(CPRecordStoreCreateWithPath, MSHake(CPRecordStoreCreateWithPath));
    	ZZHOOK_METHOD(SMSApplication,applicationDidFinishLaunching:, SMSApplication_applicationDidFinishLaunching);
		ZZHOOK_METHOD(SMSApplication, applicationWillEnterForeground:, SMSApplication_applicationWillEnterForeground);
		
		iOS4_SMSApplication_applicationDidFinishLaunching(nil);

		ZZHOOK_METHOD(CKTranscriptBubbleData, textAtIndex:, CKTranscriptBubbleData_textAtIndex);
		ZZHOOK_METHOD(CKTranscriptBubbleData, heightAtIndex:, CKTranscriptBubbleData_heightAtIndex);

    	ZZHOOK_METHOD(CKTranscriptController, messageCellTappedBalloon:, CKTranscriptController_messageCellTappedBalloon);
    	ZZHOOK_METHOD(CKTranscriptController, tableView:cellForRowAtIndexPath:, CKTranscriptController_cellForRowAtIndexPath);
    	ZZHOOK_METHOD(CKTranscriptTableView, setEditing:animated:, CKTranscriptController_setEditing_animated);
    	ZZHOOK_METHOD(CKTranscriptController, _startCreatingNewMessageForSending:, CKTranscriptController_startCreatingNewMessageForSending);

		ZZHOOK_METHOD(CKMessageEntryView, initWithFrame:, CKMessageEntryView_initWithFrame);
	}
#else
	NSArray *bundles = [NSBundle allBundles];

	for (NSBundle *b in bundles) {
		NSLog(@"Bundle %@ at %@", [b bundleIdentifier], [b bundlePath]);
	}
#endif
	
	[pool release];
}

// vim: set ts=4 sw=4 ts=4 sts=4 ff=unix expandtab
