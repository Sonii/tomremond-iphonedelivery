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
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DeliveryDateView.h"
#import "Date+extra.h"

#define max(a,b) ((a) < (b) ? (b) : (a))

static void CGContextAddRoundRect(CGContextRef context, CGRect rect, float radius)
{
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, 
        radius, M_PI, M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, 
        rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, 
        rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, 
        radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, 
        -M_PI / 2, M_PI, 1);
}

@implementation DeliveryDateView;

-(id)initWithDate:(NSDate *)d1  date:(NSDate *)d2 view:(UIView *)v {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	bool sameday = [d1 isSameDayAs:d2];
	NSDateFormatterStyle format = NSDateFormatterMediumStyle ;
	CGRect r, rr;

    [dateFormatter setLocale:[NSLocale currentLocale]];
    font = [UIFont systemFontOfSize:10.0];

	do {
    	[dateFormatter setDateStyle:format];
    	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    	text1 =  [dateFormatter stringFromDate:d1];

    	[dateFormatter setDateStyle:sameday ? NSDateFormatterNoStyle : format];
    	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    	text2 =  [dateFormatter stringFromDate:d2];

		text1 = [NSString stringWithFormat:@"%@ ⇡", text1];
		text2 = [NSString stringWithFormat:@"%@ ⇣", text2];

    	CGSize sz1, sz2;

    	sz1 = [text1 sizeWithFont:font];
    	sz2 = [text2 sizeWithFont:font];

    	rect1 = CGRectMake(3, 2, sz1.width + 8, sz1.height);
    	rect2 = CGRectMake(3, 1 + sz1.height, sz2.width + 8 , sz2.height);

		// align the second rect on the right 
		if ([NSLocale characterDirectionForLanguage:[[NSLocale currentLocale] identifier]] == kCFLocaleLanguageDirectionLeftToRight)
			rect2.origin.x += (rect1.size.width - rect2.size.width);

    	r = CGRectUnion(rect1, rect2);
		r.size.width += 6;
		r.size.height += 4;

		// put it on the left
		r = CGRectOffset(r, -max(sz1.width, sz2.width) - 20, 0.0);

		rr = [v convertRect:r toView:v.superview];

		if (format == NSDateFormatterMediumStyle) 
			format = NSDateFormatterShortStyle;
		else if (format == NSDateFormatterShortStyle) 
			format = NSDateFormatterNoStyle;
		else
			break;
	} while (rr.origin.x < 4.0);

	[dateFormatter release];
    [text1 retain];
    [text2 retain];

    self = [super initWithFrame:r];

    self.opaque = NO;

    return self;
}

-(void)dealloc { 
    [text1 release]; 
    [text2 release]; 
    [super dealloc];
}

-(void)drawRect:(CGRect)rect {
	[super drawRect:rect];

	UIColor *bg = [UIColor colorWithHue:0.5 saturation:0.5 brightness:0.9 alpha:1.0],
            *fg = [UIColor darkTextColor];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRoundRect(context, CGRectInset(self.bounds, 2.0, 2.0), 6.0);
    CGContextSetFillColorWithColor(context, bg.CGColor);
    CGContextSetStrokeColorWithColor(context, fg.CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);

    // Draw the text
    [fg set];
    [text1 drawInRect:rect1 withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    [text2 drawInRect:rect2 withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
}
@end
// vim: set ts=4 sw=4 ts=4 sts=4 ff=unix expandtab
