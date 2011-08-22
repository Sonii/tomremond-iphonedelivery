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

#ifndef RUN_CLANG_STATIC_ANALYZER
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#import <QuartzCore/QuartzCore.h>

#import "DeliveryDateView.h"

#if DEBUG
#define  NSLog(arg...) NSLog(arg)
#else
#define NSLog(arg...) do { } while (0)
#endif

#define max(a,b) ((a) < (b) ? (b) : (a))

#define TAG 9876

static UIView *current_view = NULL;
static int current_rowid = -1;

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
+(void)setRowid:(int)rowid {
    current_rowid = rowid;
}

+(int)rowid {
    return current_rowid;
}

-(id)initWithDate:(NSDate *)d forBalloonRect:(CGRect)balloon andRowid:(int)rowid {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];

    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    text1 =  [dateFormatter stringFromDate:d];

    NSLog(@"text1 = %@", text1);

    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];

    text2 =  [dateFormatter stringFromDate:d];

    NSLog(@"text2 = %@", text2);

    font = [UIFont systemFontOfSize:13.0];
    CGSize sz1, sz2;
    
    sz1 = [text1 sizeWithFont:font];
    sz2 = [text2 sizeWithFont:font];

    bool vertical = true;
	
	switch ([[UIDevice currentDevice] orientation]) {
	case UIDeviceOrientationLandscapeLeft:
	case UIDeviceOrientationLandscapeRight:
		vertical = false;
		break;
	default:
        if (CGRectGetWidth(balloon) < 160)
			vertical = false;
		break;
	}

    rect1 = CGRectMake(0, 0, vertical?max(sz1.width,sz2.width):sz1.width, sz1.height);
    if (vertical) {
        rect2 = CGRectMake(0, 0, max(sz1.width,sz2.width), sz2.height);
        rect2 = CGRectOffset(rect2, 0, CGRectGetHeight(rect1)); 
    }
    else {
        rect2 = CGRectMake(0, 0, sz2.width, max(sz1.height,sz2.height));
        rect2 = CGRectOffset(rect2, 8, 0);
        rect2 = CGRectOffset(rect2, CGRectGetWidth(rect1), 0);
    }

    rect1 = CGRectOffset(rect1, 6, 4);
    rect2 = CGRectOffset(rect2, 6, 4);

    CGRect r = CGRectUnion(rect1, rect2);

    r = CGRectOffset(r, CGRectGetMinX(balloon), 0);     // set its left to the left side of the balloon
    r = CGRectOffset(r, -CGRectGetWidth(r), 0);         // shift it left so it is immediately left of the ballon
    r = CGRectOffset(r, -14,  3);                       // slide it left and down
    r = CGRectInset(r, -7, -5);                         // make it slightly bigger

    [text1 retain];
    [text2 retain];

    current_rowid = rowid;
    current_view = self;

    [super initWithFrame:r];

    self.tag=TAG;
    self.opaque=NO;
    self.clearsContextBeforeDrawing=NO;

    return self;
}

-(void)dealloc { 
    [text1 release]; 
    [text2 release]; 
    [super dealloc];
}

-(void)drawRect:(CGRect)rect {
    UIColor *bg = [UIColor whiteColor],
            *fg = [UIColor blueColor];

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

+(bool)undisplay:(UIView *)v {
    bool res = true;

    if (current_view != nil) {
        if ([v viewWithTag:TAG] == current_view)
            res = false;
        [current_view removeFromSuperview];
        [current_view release];
        current_rowid = -1;
        current_view = NULL;
    }
    return res;
}
@end
// vim: set ts=4 sw=4 ts=4 sts=4 ff=unix expandtab
