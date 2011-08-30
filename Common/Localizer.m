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
#import "UIKit/UIKit.h"
#import "Localizer.h"
#import "Date+extra.h"

static Localizer *instance = nil;

@implementation Localizer

+(Localizer *)currentInstance {
	if (instance == nil)
		instance = [[Localizer alloc] init];
	return instance;
}

-(id)init {
	self = [super init];

	CFArrayRef pref = CFLocaleCopyPreferredLanguages();
	CFStringRef key = CFArrayGetValueAtIndex(pref, 0);
	NSLog(@"First language = %@", key);

	for (int i = 0; dict == nil && i < 2; i++) {
		NSLog(@"%s key = %@", __FUNCTION__, key);
		NSString *path = [NSBundle pathForResource:(NSString*)key
											ofType:@"plist" 
									   inDirectory:@"/Library/Application Support/ID.bundle"];
		NSLog(@"%s try path %@", __FUNCTION__, path);
		dict = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
		if (dict == nil) 
			key = CFSTR("en");
	}
	NSLog(@"Localization dict => %@", dict);
	return self;
}

-(void)dealloc {
	[dict release];
	[super dealloc];
}

-(NSString *)getString:(NSString *)key {
	return [dict objectForKey:key];
}

-(NSString *)getTitle:(NSString *)name surname:(NSString*)surname { 
	NSString *title = [self getString:@"TITLE"];
	return title != nil ? [[title stringByReplacingOccurrencesOfString:@"%SURNAME%" withString:surname]
								  stringByReplacingOccurrencesOfString:@"%NAME%" withString:name]
						: [NSString stringWithFormat:@"%@ %@", surname, name];

}

-(NSString *)formatDate:(NSDate *)date style:(NSDateFormatterStyle)style {
	NSDate *now = [NSDate date];
	NSLocale *loc = [NSLocale currentLocale];
	NSString *s = nil;

	if ([date isSameDayAs:now])  {
		if (style != NSDateFormatterNoStyle) s = [self getString:@"TODAY"];
		return s == nil ? @"" : s;
	}
	else if ([date isYesterdayOf:now]) {
		s = [self getString:@"YESTERDAY"];
		if (s != nil) return nil;
	}

	NSString *sd = [date descriptionOfDateWithLocale:loc style:style];
	s = [self getString:@"DATE"];
	if (s != nil) return [s stringByReplacingOccurrencesOfString:@"%DATE%" withString:sd];
	return sd;
}

-(NSString *)formatTime:(NSDate*)date style:(NSDateFormatterStyle)style {
	NSLocale *loc = [NSLocale currentLocale];
	NSString *s = nil;

	NSString *sd = [date descriptionOfTimeWithLocale:loc style:style ];
	s = [self getString:@"TIME"];
	if (s != nil) return [s stringByReplacingOccurrencesOfString:@"%TIME%" withString:sd];
	return sd;
}
@end
// vim: set ts=4 expandtab
