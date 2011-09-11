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
@interface  Localizer : NSObject {
	NSDictionary *dict;
}

+(Localizer *)sharedInstance;
-(id)init;
-(void)dealloc;
-(NSString *)getString:(NSString *)key;
-(NSString *)getTitle:(NSString *)name surname:(NSString*)surname;
-(NSString *)formatDate:(NSDate *)date style:(NSDateFormatterStyle)style;
-(NSString *)formatTime:(NSDate*)date style:(NSDateFormatterStyle)style;
@end
// vim: set ts=4 expandtab
