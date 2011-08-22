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
#import "Date+extra.h"

@implementation NSDate(_private)
-(bool) isYesterdayOf:(NSDate *)d {
	NSDate *d1 = [self dateByAddingTimeInterval:3600.0 * 24];
	return [d1 isSameDayAs:d];
}

-(bool) isSameDayAs:(NSDate *)d {
    int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *c1 = [[NSCalendar currentCalendar] components:flags 
                                fromDate:self],
                     *c2 = [[NSCalendar currentCalendar] components:flags 
                                fromDate:d];

    return   [c1 year] == [c2 year] && 
            [c1 month] == [c2 month] && 
              [c1 day] == [c2 day];
}

-(NSString *)descriptionOfDateWithLocale:(NSLocale *)locale  style:(NSDateFormatterStyle)style {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSTimeZone *tz = [NSTimeZone localTimeZone];

    [dateFormatter setLocale:locale];

    [dateFormatter setDateStyle:style];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

	// Ajust the time to our timezone
	[dateFormatter setTimeZone:tz];
    NSString *str = [dateFormatter stringFromDate:self];
	[dateFormatter release];
	return str;
}

-(NSString *)descriptionOfTimeWithLocale:(NSLocale *)locale  style:(NSDateFormatterStyle)style {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSTimeZone *tz = [NSTimeZone localTimeZone];

    [dateFormatter setLocale:locale];

    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:style];

	// Ajust the time to our timezone
	[dateFormatter setTimeZone:tz];
    NSString *str = [dateFormatter stringFromDate:self];
	[dateFormatter release];
	return str;
}
@end

// vim: set ts=4 expandtab
