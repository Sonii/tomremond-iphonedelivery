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
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "NSData+serial.h"

#include "debug.h"
#include "notify.h"

/*
   calls a remote method and pass it data
   return a data
   */
static NSData *remote_call(NSString *method, NSData *data) {
	CFDataRef rv = NULL;
    CFMessagePortRef port = CFMessagePortCreateRemote(NULL, (CFStringRef)method);
    if (port != NULL) {
        CFMessagePortSendRequest (port, 0, (CFDataRef)data, 1.0, 1.0, kCFRunLoopDefaultMode, &rv);
        CFRelease(port);
    }
	return rv != NULL ? [[[NSData dataWithBytes:CFDataGetBytePtr(rv) length:CFDataGetLength(rv)] retain] autorelease] : nil;
}

/** 
 * @brief send a signal to another process
 * 
 * @param method to call
 * @param payload data (itis a serialized dictionary)
 */
static void remote_signal(NSString *method, NSData *data) {
    CFMessagePortRef port = CFMessagePortCreateRemote(NULL, (CFStringRef)method);
    if (port != NULL) {
        CFMessagePortSendRequest (port, 0, (CFDataRef)data, 1.0, 0, NULL, NULL);
        CFRelease(port);
    }
}

/** 
 * @brief notify about a submit Used to bind a number to a SMSC ref
 * 
 * @param ref 
 * @param when 
 * @param who 
 */
void notify_submit(int ref, time_t when, const char *who) {
#ifdef DEBUG
	char tmp[32];
	strftime(tmp, sizeof(tmp), "%D %T", localtime(&when));
	LOG("SMS submited to %s at %s ref = %d", who, tmp, ref);
#endif

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSString stringWithUTF8String:who], @"WHO",
			[NSNumber numberWithInt:when], @"WHEN",
			[NSNumber numberWithInt:ref], @"REF",
			nil];
		remote_signal(@"id.submit", [[NSData serializeFromDictionary:dict] autorelease]);
	[pool release];
}

void notify_report(int ref, time_t when_sent, time_t when_delivered, const char *who, uint8_t status, uint8_t *payload, size_t size) { 
#ifdef DEBUG
	char tmp1[32];
	char tmp2[32];

	strftime(tmp1, sizeof(tmp1), "%D %T", localtime(&when_sent));
	strftime(tmp2, sizeof(tmp2), "%D %T", localtime(&when_delivered));
	LOG("Report from %s sent at %s delivered at %s ref = %d status %d", who, tmp1, tmp2, ref, status);
#endif

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSString stringWithUTF8String:who], @"WHO",
			[NSNumber numberWithInt:when_sent], @"WHENSENT",
			[NSNumber numberWithInt:when_delivered], @"WHENDELIVERED",
			[NSNumber numberWithInt:ref], @"REF",
			[NSNumber numberWithInt:status], @"STATUS",
			[NSData dataWithBytes:payload length:size], @"PAYLOAD",
			nil];
		remote_signal(@"id.report", [[NSData serializeFromDictionary:dict] autorelease]);
	[pool release];
}

void notify_started() {
	remote_signal(@"id.start", NULL);
}

/** 
 * @brief I had a report the the CommCenter crashed if there are two many destination
 *        so in case we cache the enable value to avoid talking too much with the SpringBoard
 * 
 * @return 
 */
bool report_enabled() {
	static time_t last_time = 0;
	static bool cached_enabled = true;
	bool rc = true;

	time_t now = time(NULL);
	if (now - last_time > 60) { 
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSData *data = remote_call(@"id.enabled", NULL);
		if (data != nil) {
			NSDictionary *dict = [[data unserialize] autorelease];
			rc = [[dict objectForKey:@"ENABLED"] boolValue];
		}
		[pool release];

		cached_enabled = rc;
		last_time = now;
	}
	else {
		rc = cached_enabled;
	}
	return rc;
}

bool notify_received(uint8_t *payload, size_t size) {
	NSData *data = [[NSData alloc] initWithBytes:payload length:size];
	remote_signal(@"id.receive", data);
	[data release];
	return true;
}
// vim: set ts=4 expandtab
