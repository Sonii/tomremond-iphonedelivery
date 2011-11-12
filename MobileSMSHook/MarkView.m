/** 
 Copyright (C) 2011 - François Guillemé
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
#import <QuartzCore/QuartzCore.h>
#import <CoreFoundation/CoreFoundation.h>

#import "MarkView.h"

#undef DEBUG

extern bool showMark;

static UIImage *get_image_for_status(int status) {
    static bool inited = false;
    static UIImage *images[4];

    if (!inited) {
		int i;
		NSString *scale = [[UIScreen mainScreen] scale] == 2.0 ? @"@2x" : @"";
		NSString *pfx = @"/Library/Application Support/ID.bundle/";
		NSString *arr[] = { @"pending", @"delivered", @"expired", @"error" };

        inited = true;
		for (i = 0; i < 4; i++) {
			UIImage *im = [UIImage alloc]; 
			NSString *path = [NSString stringWithFormat:@"%@%@%@.png", pfx, arr[i], scale];

			if ([[NSFileManager defaultManager] fileExistsAtPath:path])
				images[i] = [im initWithContentsOfFile:path];
			else {
				NSString *path = [NSString stringWithFormat:@"%@%@.png", pfx, arr[i]];
				if ([[NSFileManager defaultManager] fileExistsAtPath:path])
			        images[i] = [im initWithContentsOfFile:path];
				else
					images[i] = im;
			}
		}	
    }
    return status >= 0 && status < 4 ? images[status] : nil;
}

@implementation MarkView
-(id)init:(int)state cell:(CKMessageCell*)cell status:(uint16_t)status {
    UIImage *im = get_image_for_status(state);
	CGRect balloon_frame = [cell balloonView].frame;
    CGRect frame;
    frame.origin.x = (- im.size.width);
    frame.origin.y = (balloon_frame.size.height / 2 - im.size.height / 2);
    frame.size.width = im.size.width;
    frame.size.height = im.size.height;

#ifdef DEBUG
    NSLog(@"Ballon frame = <%d,%d,%d,%d>", (int)balloon_frame.origin.x, (int)balloon_frame.origin.y, 
            (int)balloon_frame.size.width, (int)balloon_frame.size.height);
    NSLog(@"Mark frame = <%d,%d,%d,%d>", (int)frame.origin.x, (int)frame.origin.y, 
            (int)frame.size.width, (int)frame.size.height);
#endif

	self = [super initWithFrame:frame];
	if (status != 1002 && status != 1004)
    	self.image = im;
    self.backgroundColor = [UIColor clearColor];
    [self sizeToFit];

	if (state == 3 && status != 0 && status != 1002 && status != 1004) {

		// if it is an error display the code next to the mark
		NSString *str = [NSString stringWithFormat:@"%d", status];
		UIFont *font = [UIFont systemFontOfSize:10];
		CGSize size = [str sizeWithFont:font];
		CGRect label_frame = CGRectMake(-size.width, (frame.size.height - size.height) / 2, size.width, size.height);
		UILabel *label = [[UILabel alloc] initWithFrame:label_frame];
		label.text = str;
		label.font = font;
		label.textColor = [UIColor redColor];
		label.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = NO;
		[self addSubview:label];
		[label release];
	}
	else if (showMark == NO)
		self.hidden = YES;

	self.alpha = 1.0;
	self.tag = TAG;

	return self;
}
@end
// vim: set ts=4 sw=4 ts=4 sts=4 ff=unix expandtab
