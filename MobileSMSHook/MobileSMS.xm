extern "C" {
#import "database.h"
#import "localizer.h"
#import "smiley.h"
}

#import "MarkView.h"
#import <dispatch/dispatch.h>

@interface CKSMSMessage
-(int)rowID;
@end

@interface CKBubbleData
-(id)messageAtIndex:(int)index;
@end

@interface CKTranscriptController 
-(id)bubbleData;
-(void)updateTranscript;
@end

static id currentTranscript = nil;
static bool showSmileys = YES;

bool showMark = YES;

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
    [currentTranscript updateTranscript];
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

#if 0
    [[NSNotificationCenter defaultCenter] 
            addObserverForName:@"com.guilleme.refresh"
            object:nil 
            queue:nil
            usingBlock:^(NSNotification *){ readDefaults(); }];
#endif

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
    %log;
    NSString *s = %orig;
    if (showSmileys) s = replaceSmileys(s);
    return s;
}
%end

#if 0
static NSString *get_localized_deliver(NSDate *d) {
    Localizer *localizer = [[Localizer alloc] init];
	NSString *s = [localizer getString:@"DELIVERED"];

	s = [s stringByReplacingOccurrencesOfString:@"%DATESPEC%" withString:[localizer formatDate:d
								style:NSDateFormatterMediumStyle]];
	s = [s stringByReplacingOccurrencesOfString:@"%TIMESPEC%" withString:[localizer formatTime:d
								style:NSDateFormatterNoStyle]];
    [localizer release];
	return s;
}
#endif

%hook CKTranscriptController
-(void)messageCellTappedBalloon:(id)cell {
    %log;
    %orig;
#if 0
            UILabel *label = [[[UILabel alloc] initWithFrame:v.frame] autorelease];
            //label.text = get_localized_deliver([NSDate dateWithTimeIntervalSince1970:date+delay]);
            label.text = [[NSDate dateWithTimeIntervalSince1970:date+delay] description];
            label.opaque = NO;
            label.font =[UIFont systemFontOfSize:9];
            label.textColor = [UIColor grayColor];
            label.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:label];
#endif
}

-(UITableViewCell *)tableView:(id)tv cellForRowAtIndexPath:(NSIndexPath *)path {
    %log;
    UITableViewCell *cell = %orig;

    currentTranscript = self;

    if ([cell class] == objc_getClass("CKMessageCell")) {
        CKMessageCell *mcell = (CKMessageCell *)cell;
        CGRect balloon_frame = [mcell balloonView].frame;

        CKTranscriptBubbleData *data = [self bubbleData];
        int rowid = [[data messageAtIndex:path.row] rowID]; NSLog(@"rowID = %d", rowid);
        if (rowid > 0) {
            dispatch_async(dispatch_get_current_queue(), ^{
            int ref = 0, status = 0, delay = 0;
            time_t date = 0;
            int rc = get_delivery_info_for_rowid(rowid, &ref, &date, &delay, &status);

            NSLog(@"rc=%d ref=%d status = %d date = %d delay = %d", rc, ref, status, date, delay);

            int code = 3;
            if (date != 0 && delay >= 0 && status == 0)
                code = 1;
            else if (date != 0 && ref >= 0)
                code = 0;
            else if (status == 70)
                code = 2;

            MarkView *iv = [[MarkView alloc] init:code cell:mcell status:status];
            iv.alpha = 0.0;
            [[mcell balloonView] addSubview:iv];
            [UIView animateWithDuration:0.2 animations:^{ iv.alpha = 1.0; }];
            [iv release];
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
