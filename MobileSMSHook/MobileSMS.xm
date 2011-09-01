extern "C" {
#import "database.h"
#import "localizer.h"
#import "smiley.h"
}

#import "MarkView.h"
#import "DeliveryDateView.h"
#import <dispatch/dispatch.h>

@interface CKSMSMessage
-(int)rowID;
@end

@interface CKBubbleData
-(id)messageAtIndex:(int)index;
@end

@interface CKTranscriptController 
-(id)bubbleData;
-(void)_reloadTranscriptLayer;
-(UITableViewCell *)tableView:(id)tv cellForRowAtIndexPath:(NSIndexPath *)path;
@end

static id currentTranscript = nil;
static bool showSmileys = YES;

bool showMark = YES;

static NSIndexPath *inspectedPath = nil;
static UIView *lastDateView = nil;

;
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

static void readDefaults() {
    Boolean exists;
    CFStringRef app = CFSTR("com.guilleme.deliveryreports");

    NSLog(@"%s", __FUNCTION__);

    CFPreferencesSynchronize(app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
    showSmileys = CFPreferencesGetAppBooleanValue(CFSTR("dr-smileys"), app, &exists);
    if (!exists) showSmileys = true;
    
    showMark = CFPreferencesGetAppBooleanValue(CFSTR("dr-tick"), app, &exists);
    if (!exists) showMark = true;
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

%hook CKSMSService
-(NSString *)displayName {
    return @"iPhoneDelivery";
}
%end

%hook CKTranscriptBubbleData
-(NSString *)textAtIndex:(NSInteger)index {
    NSString *s = %orig;
    if (showSmileys) s = replaceSmileys(s);
    return s;
}
%end

%hook CKTranscriptController
-(void)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath*)path {
    %log;
    %orig;
    [inspectedPath release];
    inspectedPath = [path retain];

    CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("iphonedelivery.refresh"), NULL, NULL, YES);
}

-(UITableViewCell *)tableView:(id)tv cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = %orig;

    currentTranscript = self;

    if ([cell class] == objc_getClass("CKMessageCell")) {
        CKMessageCell *mcell = (CKMessageCell *)cell;
        UIView *bv = [mcell balloonView];
        CGRect balloon_frame = bv.frame;

        CKTranscriptBubbleData *data = [self bubbleData];
        int rowid = [[data messageAtIndex:path.row] rowID];
        if (rowid > 0) {
            dispatch_async(dispatch_get_current_queue(), ^{
            int ref = 0, status = 0, delay = 0;
            time_t date = 0;
            int rc = get_delivery_info_for_rowid(rowid, &ref, &date, &delay, &status);

//            NSLog(@"rc=%d ref=%d status = %d date = %d delay = %d", rc, ref, status, date, delay);


            if (rc == 0) {
                int code = 3;
                if (date != 0 && delay >= 0 && status == 0)
                code = 1;
                else if (date != 0 && ref >= 0)
                code = 0;
                else if (status == 70)
                code = 2;

#define TAG 5329

	            // remove any present stamp
                UIView *vv = [bv viewWithTag:TAG];
                if (vv != nil) [vv removeFromSuperview];

                if (inspectedPath.row == path.row && date != 0 && delay != -1 && status == 0) {
                    NSDate *d1 = [NSDate dateWithTimeIntervalSince1970:date];
                    NSDate *d2 = [NSDate dateWithTimeIntervalSince1970:date + delay];

                    DeliveryDateView *iv = [[DeliveryDateView alloc] initWithDate:d1 date:d2 view:bv];
                    iv.alpha = 0.0;
                    iv.tag = TAG;

                    NSLog(@"date view = %@", iv);
		            mcell.clipsToBounds = NO;
                    [bv addSubview:iv];
                    [UIView animateWithDuration:0.2 animations:^{ iv.alpha = 1.0; }];
                    [lastDateView removeFromSuperview];
                    [lastDateView release];
                    lastDateView = iv;
                }
                else {
                    MarkView *iv = [[MarkView alloc] init:code cell:mcell status:status];
                    iv.alpha = 0.0;
                    iv.tag = TAG;

		            mcell.clipsToBounds = NO;
                    [bv addSubview:iv];
                    if (status == 0 && delay == -1 && ref == 0) 
                        bv.hidden = YES;    // during send....
                    else
                        [UIView animateWithDuration:0.2 animations:^{ iv.alpha = 1.0; }];
                    [iv release];
                }
            }
            });
        }
    }
    return cell;
}
%end

%hook CKTranscriptTableView
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    %log;
    %orig;
}
%end
// vim: ft=objc ts=4 expandtab
