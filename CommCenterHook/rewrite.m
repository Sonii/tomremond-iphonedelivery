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

#include "debug.h"
#include "utils.h"
#include "rewrite.h"
 
@interface NSDate(private)
-(NSString *)descriptionWithLocale:(NSLocale *)locale;
@end

@implementation NSDate(private)

-(NSString *)descriptionWithLocale:(NSLocale *)locale {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSTimeZone *tz = [NSTimeZone localTimeZone];

    [dateFormatter setLocale:locale];

    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];

	// Ajust the time to our timezone
	[dateFormatter setTimeZone:tz];
    NSString *str = [dateFormatter stringFromDate:self];
	[dateFormatter release];
	return str;
}
@end

static int storeStringInBuffer(NSString *message, uint8_t *dest, NSStringEncoding enc) {
    char buffer[256];
    NSUInteger n;
    NSRange range = NSMakeRange(0, [message length] );
	int total_bytes = 0;

    while (range.length > 0) {
        if (![message   getBytes:buffer 
                        maxLength:sizeof(buffer) 
                        usedLength:&n
                        encoding:enc 
                        options:NSStringEncodingConversionAllowLossy
                        range:range
                        remainingRange:&range]) break;
		memcpy(dest, buffer, n);
		dest += n;
		total_bytes += n;
    }
    return total_bytes;
}

uint8_t *rewrite_cts(uint8_t *payload, size_t n, size_t *pn, int *offset, NSString **pmesg, bool visible) {
	bool flash = true;
	bool unicode = false;
	char number[32];
	uint8_t *p = malloc(256);
	int index1 = 0, index2 = 0;

	DUMP(payload, n, "original payload len = %d", n);

	// SMSC length + address
	memcpy(&p[0], &payload[0], payload[0] + 1);
	index1 = index2 = payload[0] + 1;

	p[index1++] = 4; index2++;		// SM-DELIVER

	index2++;	// skip ref

	// xtract and copy phone number
	uint8_t l = p[index1++] = payload[index2++];
	xtract_phone_number(&payload[index2], l, number);
	l = 1 + ( l + 1) / 2;
	memcpy(&p[index1], &payload[index2], l);
	index1 += l;
	index2 += l;

	NSString *realname = [[NSString alloc] initWithUTF8String:number];

	// set encoding and class type
	p[index1++] = visible ? 0x00 : 0x40;		// invisible
	p[index1++] = flash ? 0x14 : unicode ? 0x08 : 0x04;

	// xtract the dates
	time_t sent_date, delivery_date;
	sent_date = xtract_time(&payload[index2]);
	delivery_date = xtract_time(&payload[index2+7]);
	memcpy(&p[index1], &payload[index2], 7);
	index1 += 7; index2 += 14;

	// get the status we will need it to determine the message content
	uint8_t status = payload[index2];

	NSString *message = nil;

	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr"];
	NSString *str1 = [[[NSDate alloc] initWithTimeIntervalSince1970:sent_date] descriptionWithLocale:locale];
	NSString *str2 = [[[NSDate alloc] initWithTimeIntervalSince1970:delivery_date] descriptionWithLocale:locale];

	switch (status) {
	case 0:
		message = [[NSString alloc] initWithFormat:@"émis %@ reçu %@", str1, str2];
		break;
	case 48:
		message = [[NSString alloc] initWithFormat:@"émis %@ en attente", str1];
		break;
	default:
		message = [[NSString alloc] initWithFormat:@"émis %@ status: %d", str1, status];
		break;
	}
	NSString *full_message = [[NSString alloc] initWithFormat:@"Message pour %@ %@", realname, message];

    p[index1] = storeStringInBuffer(full_message, &p[index1+1], unicode?NSUTF16BigEndianStringEncoding:NSUTF8StringEncoding);
	[locale release];
	[str1 release];
	[str2 release];
	[full_message release];

	*pmesg = message;		// transfer ownership of message to *pmesg
	[realname release];
	*offset = index1 + 1;
	*pn = index1 + p[index1] + 1;
	DUMP(p, *pn, "new payload len = %d", *pn);
	return p;
}
// vim: set ts=4 expandtab
