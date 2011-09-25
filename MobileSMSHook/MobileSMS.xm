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
extern "C" {
#import "database.h"
#import "localizer.h"
#import "smiley.h"
}

#import "MarkView.h"
#import "DeliveryDateView.h"
#import <dispatch/dispatch.h>

#if !defined(DEBUG)
#define NSLog(...) 
#endif

@interface CKSMSMessage
-(int)rowID;
@end

@interface CKTranscriptBubbleData
-(id)messageAtIndex:(int)index;
- (id)textAtIndex:(int)arg1;
- (CGSize)sizeAtIndex:(int)arg1;
- (Class)balloonClassAtIndex:(int)arg1;
@end

@interface CKTranscriptController 
-(id)bubbleData;
-(void)_reloadTranscriptLayer;
@end

@interface CKUIBehavior
+ (id)sharedBehaviors;
-(UIFont *)balloonTextFont;
- (float)balloonTextFontSize;
@end

@interface CKSimpleBalloonView
+ (struct CGSize)balloonSizeConstrainedToWidth:(float)arg1 text:(id)arg2 subject:(id)arg3 textBalloonSize:(struct CGSize *)arg4 subjectBalloonSize:(struct CGSize *)arg5;
+ (float)heightForText:(id)arg1 width:(float)arg2 includeBuffers:(BOOL)arg3;
@end

static id currentTranscript = nil;
static bool showSmileys = YES;
static bool showPictures = NO;
static float smallFontSize = NO;

bool showMark = YES;

static int tapped_rowid = -1;
static NSDate *inpectionTime = nil;             // date when last tapped to see the date
static UIView *lastDateView = nil;              // displayed date view

/** 
 * @brief called when the MobileSMS app needs to refresh the bubble
 * 
 * @param center 
 * @param observer 
 * @param name 
 * @param object 
 * @param userInfo 

 * TODO we might also refreh the conversation list
 */
static void launch_cb (
   CFNotificationCenterRef center,
   void *observer,
   CFStringRef name,
   const void *object,
   CFDictionaryRef userInfo
) {
    [currentTranscript _reloadTranscriptLayer];
}

/** 
 * @brief read settings
 */
static void readDefaults() {
    Boolean exists;
    CFStringRef app = CFSTR("com.guilleme.deliveryreports");

    CFPreferencesSynchronize(app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
    showSmileys = CFPreferencesGetAppBooleanValue(CFSTR("dr-smileys"), app, &exists);
    if (!exists) showSmileys = true;
    
    showMark = CFPreferencesGetAppBooleanValue(CFSTR("dr-tick"), app, &exists);
    if (!exists) showMark = true;

    showPictures = CFPreferencesGetAppBooleanValue(CFSTR("dr-pictures"), app, &exists);
    if (!exists) showPictures = false;

    smallFontSize = CFPreferencesGetAppBooleanValue(CFSTR("dr-small"), app, &exists);
    if (!exists) smallFontSize = false;

}

%hook SMSApplication
-(void)applicationDidBecomeActive:(id) appl {
    CFNotificationCenterRef nc = CFNotificationCenterGetDarwinNotifyCenter();
    
    CFNotificationCenterAddObserver(nc, appl, launch_cb,  
            CFSTR("iphonedelivery.refresh"), NULL,
            CFNotificationSuspensionBehaviorCoalesce);

    // get some defaults
    readDefaults();

    %orig;
}
%end

#if 0
%hook CKSMSService
-(NSString *)displayName {
    return @"iPhoneDelivery";
}
%end
#endif

%hook CKTranscriptBubbleData

/*
   just translate smiley codes to emojis
*/
-(NSString *)textAtIndex:(NSInteger)index {
    NSString *s = %orig;
    if (showSmileys) {
        s = [s replaceSmileys];
    }
    return s;
}

/*
   needed becuse the size with smileys is different than without
   and we need to get the right size when switching small/normal font
*/
- (struct CGSize)sizeAtIndex:(int)index {
    CGSize size = %orig;

    if ([self balloonClassAtIndex:index] == objc_getClass("CKSimpleBalloonView")) {
        NSString *s = [self textAtIndex:index];

        CGFloat width = size.width;
        NSLog(@"width = %.1f", width);

        if (showSmileys && width < 170)
            width += 40;

        size = [objc_getClass("CKSimpleBalloonView") 
                    balloonSizeConstrainedToWidth:width 
                                             text:s 
                                          subject:nil
                                  textBalloonSize:nil 
                               subjectBalloonSize:nil];
    }
    return size;
}
%end


%hook CKTranscriptController
/* 
  when a balloon is tapped store its rowid and ask for a redisplay
  it will cause a ball;oon withe sending/delivered date to be displayed
  also get the time at which the balloon must be hidden if it is still displayed
*/
-(void)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath*)path {
    //%log;

    [inpectionTime release];
    inpectionTime = nil;

    // only if not editing...
    if (!tv.editing) {
        CKTranscriptBubbleData *data = [self bubbleData];
        tapped_rowid = [[data messageAtIndex:path.row] rowID];

        inpectionTime = [[NSDate dateWithTimeIntervalSinceNow:15.0] retain];

        CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("iphonedelivery.refresh"), NULL, NULL, YES);
    }
    %orig;
}

-(float)tableView:(id)view heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float h = %orig;
    CKTranscriptBubbleData *data = [self bubbleData];

    if ([data balloonClassAtIndex:indexPath.row] == objc_getClass("CKSimpleBalloonView")) {
        NSString *s = [data textAtIndex:indexPath.row];

        if (showSmileys && [s containsEmoji]) {
            CGSize size = [data sizeAtIndex:indexPath.row];
            h = size.height + 8.0;
        }
    }
    return h;
}

/*
   Draw the mark/date view
   Basically we check the database for thhe message and add an according view
*/
-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)path {
    //%log;
    UITableViewCell *cell = %orig;

    currentTranscript = self;

    if ([cell class] == objc_getClass("CKMessageCell")) {
        CKMessageCell *mcell = (CKMessageCell *)cell;
        UIView *ballonView = [mcell balloonView];
        CGRect balloon_frame = ballonView.frame;
        UIView *markView = [ballonView viewWithTag:TAG];

        // don't do anything in edit mode
        if (!tv.editing) {
            CKTranscriptBubbleData *data = [self bubbleData];

            int rowid = [[data messageAtIndex:path.row] rowID];
            if (rowid > 0) {
                dispatch_async(dispatch_get_current_queue(), ^{
                        int ref = 0, status = 0, delay = 0;
                        time_t date = 0;
                        int rc = get_delivery_info_for_rowid(rowid, &ref, &date, &delay, &status);

                        NSLog(@"rc=%d ref=%d status = %d date = %d delay = %d", rc, ref, status, date, delay);

                        if (rc == 0) {
                            int code = 3;

                            if (date != 0 && delay >= 0 && status == 0)
                                code = 1;
                            else if (date != 0 && ref >= 0)
                                code = 0;
                            else if (status == 70)
                                code = 2;

                            if (tapped_rowid == rowid && date != 0 && delay != -1 && status == 0) {
                                NSDate *d1 = [NSDate dateWithTimeIntervalSince1970:date];
                                NSDate *d2 = [NSDate dateWithTimeIntervalSince1970:date + delay];

                                DeliveryDateView *iv = [[DeliveryDateView alloc] initWithDate:d1 date:d2 view:ballonView];

                                NSLog(@"date view = %@", iv);
		                        mcell.clipsToBounds = NO;

                                // animate disappear of previous
                                [UIView animateWithDuration:0.2 delay:0.0 options:0
                                    animations:^{ markView.alpha = 0.0; }
                                    completion:^(BOOL){ [markView removeFromSuperview]; }
                                ];

                                // hide the dateview after some time (15 sec?)
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000000000LL * 15),
                                        dispatch_get_current_queue(), ^{
                                            if (tapped_rowid != -1 && inpectionTime != nil &&
                                                [inpectionTime timeIntervalSinceNow] < 0) {

                                            [inpectionTime release];
                                            inpectionTime = nil;
                                            tapped_rowid = -1;
                                            CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("iphonedelivery.refresh"), NULL, NULL, YES);
                                        }
                                });

                                [lastDateView removeFromSuperview];
                                [lastDateView release];
                                lastDateView = iv;
                            }
                            else {
                                MarkView *newMarkView = [[MarkView alloc] init:code cell:mcell status:status];

		                        mcell.clipsToBounds = NO;
                                if (status == 0 && delay == -1 && ref == 0) 
                                    newMarkView.hidden = YES;    // during send....

                                NSLog(@"mark view = %@", newMarkView);
                                [ballonView addSubview:newMarkView];
                                [newMarkView release];
                            }
                            [markView removeFromSuperview];
                        }
                });
                markView = nil;
            }
        }
	        // remove any present stamp
        [markView removeFromSuperview];
    }
    return cell;
}
%end

%hook CKUIBehavior
-(BOOL)shouldShowContactPhotos {
    if (showPictures)
        return YES;
    else
        return %orig;
}

-(float)contactPhotoSize {
    if (!smallFontSize && showPictures)
        return 48.0;
    else
        return %orig;
}
//
//-(float) contactPhotoBorderThickness {
//    if (showPictures)
//        return 2.0; 
//    else
//        return %orig;
//}
//
//-(float) contactPhotoOutsideMargin { 
//    if (showPictures)
//        return 3.0; 
//    else
//        return %orig;
//}
//
//-(float) contactPhotoInsideMargin { 
//    if (showPictures)
//        return 0.0; 
//    else
//        return %orig;
//}

//- (id)balloonTextFont { 
//    return %orig;
//}

- (float)balloonTextFontSize {
    if (smallFontSize)
        return 13.0;
    else
        return %orig;
}

- (float)balloonTextLineHeight {
    if (smallFontSize)
        return 13.0;
    else
        return %orig;
}
%end

// vim: ft=objc ts=4 expandtab
