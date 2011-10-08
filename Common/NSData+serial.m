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
#import "NSData+serial.h"

@implementation NSData(serial) 
-(NSDictionary *)unserialize {
    NSString *error = nil;
	NSPropertyListFormat format;
	NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:self
								mutabilityOption:NSPropertyListImmutable
								format:&format
								errorDescription:&error];
	if (error != nil) {
        NSLog(@"Deserialization error: %@", error);
        [error release];
	}
	
	if (dict != nil) {
		[dict retain];
	}
	return dict;
}

+(NSData *)serializeFromDictionary:(NSDictionary *)dict {
    NSString *error = nil;
#ifdef DEBUG
	NSLog(@"serialize %@", dict);
#endif
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:dict
                                       format:NSPropertyListXMLFormat_v1_0
                                       errorDescription:&error];
	if (error != nil) {
        NSLog(@"Serialization error: %@", error);
        [error release];
	}
	if (data != nil) {
		[data retain];
#ifdef DEBUG
		NSLog(@"serialize = %d bytes", [data length]);
#endif
	}
	return data;
}
@end
// vim: set ts=4 expandtab
