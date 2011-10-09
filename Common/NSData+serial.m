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
	NSLog(@"%s %@", __FUNCTION__, self);
    NSError *error = nil;
	NSPropertyListFormat format;
	NSDictionary *dict = [NSPropertyListSerialization 
					propertyListWithData:self
								 options:NSPropertyListImmutable
								  format:&format
								   error:&error];
	if (error != nil) {
        NSLog(@"Deserialization error: %@", error);
	}
	[dict retain];
	NSLog(@"%s %@ %@", __FUNCTION__, dict, error);
	return dict;
}

+(NSData *)serializeFromDictionary:(NSDictionary *)dict {
    NSError *error = nil;
	NSLog(@"%s %@", __FUNCTION__, dict);
#ifdef DEBUG
	NSLog(@"serialize %@", dict);
#endif
    NSData *data = [NSPropertyListSerialization 
								dataWithPropertyList:dict
											  format:NSPropertyListBinaryFormat_v1_0
											 options:NSPropertyListImmutable
											   error:&error];
	NSLog(@"%s %@ %@", __FUNCTION__, data, error);
	if (error != nil) {
        NSLog(@"Serialization error: %@", error);
	}
	[data retain];
	return data;
}
@end
// vim: set ts=4 expandtab
