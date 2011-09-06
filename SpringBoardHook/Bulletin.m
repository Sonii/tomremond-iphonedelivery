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
#import <AudioToolbox/AudioToolbox.h>
#include <objc/runtime.h>

@interface SpringBoard {
}
-(BOOL)isLocked;
@end

@interface SBBulletinBannerController {
}
+(id)sharedInstance;
-(void) observer:(id)o addBulletin:(id)b forFeed:(id)f;
@end

@interface SBAwayController {
}
+(id)sharedAwayController;
-(id)awayView;
-(id)bulletinController;        // pretend it belongs here to get rid of a warning
@end

@interface BBContent : NSObject <NSCopying, NSCoding> {
    NSString *_title;
    NSString *_subtitle;
    NSString *_message;
}
@property(copy, nonatomic) NSString *message; // @synthesize message=_message;
@property(copy, nonatomic) NSString *subtitle; // @synthesize subtitle=_subtitle;
@property(copy, nonatomic) NSString *title; // @synthesize title=_title;

+ (id)contentWithTitle:(id)arg1 subtitle:(id)arg2 message:(id)arg3;
- (id)description;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (BOOL)isEqualToContent:(id)arg1;
- (void)dealloc;
@end

@interface BBAction : NSObject <NSCopying, NSCoding> {
    id _internalBlock;
    BOOL _hasCallblock;
    BOOL _canBypassPinLock;
    NSURL *_launchURL;
    NSString *_launchBundleID;
    int replyType;
}
@property(nonatomic) BOOL canBypassPinLock; // @synthesize canBypassPinLock=_canBypassPinLock;
@property(nonatomic) int replyType; // @synthesize replyType;
@property(copy, nonatomic) NSString *launchBundleID; // @synthesize launchBundleID=_launchBundleID;
@property(retain, nonatomic) NSURL *launchURL; // @synthesize launchURL=_launchURL;
@property(nonatomic) BOOL hasCallblock; // @synthesize hasCallblock=_hasCallblock;
@property(copy, nonatomic) id internalBlock; // @synthesize internalBlock=_internalBlock;

+ (id)actionWithTextReplyCallblock:(id)arg1;
+ (id)actionWithLaunchBundleID:(id)arg1 callblock:(id)arg2;
+ (id)actionWithLaunchURL:(id)arg1 callblock:(id)arg2;
+ (id)actionWithCallblock:(id)arg1;
- (id)description;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)partialDescription;
- (void)deliverResponse:(id)arg1;
- (id)bundleID;
- (id)url;
- (BOOL)isAppLaunchAction;
- (BOOL)isURLLaunchAction;
- (BOOL)wantsTextReply;
- (BOOL)hasLaunchInfo;
- (void)dealloc;
- (id)_initWithInternalCallblock:(id)arg1 replyType:(void)arg2;
- (id)initWithTextReplyCallblock:(id)arg1;
- (id)initWithCallblock:(id)arg1;
@end

@interface BBLaunchAction : BBAction {
}

+ (id)launchActionWithBundleID:(id)arg1 callblock:(id)arg2;
+ (id)launchActionWithURL:(id)arg1 callblock:(id)arg2;
@end

@interface BBButton : NSObject <NSCopying, NSCoding> {
    NSString *_title;
    BBAction *_action;
}
@property(retain, nonatomic) BBAction *action; // @synthesize action=_action;
@property(copy, nonatomic) NSString *title; // @synthesize title=_title;

+ (id)buttonWithTitle:(id)arg1 action:(id)arg2;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)dealloc;
@end

@interface BBSound : NSObject <NSCopying, NSCoding> {
    int _soundType;
    unsigned long _systemSoundID;
    unsigned int _soundBehavior;
    NSString *_ringtoneName;
    BOOL _repeats;
    NSDictionary *_vibrationPattern;
}
@property(nonatomic) unsigned int soundBehavior; // @synthesize soundBehavior=_soundBehavior;
@property(nonatomic, getter=isRepeating) BOOL repeats; // @synthesize repeats=_repeats;
@property(retain, nonatomic) NSString *ringtoneName; // @synthesize ringtoneName=_ringtoneName;
@property(retain, nonatomic) NSDictionary *vibrationPattern; // @synthesize vibrationPattern=_vibrationPattern;
@property(nonatomic) unsigned long systemSoundID; // @synthesize systemSoundID=_systemSoundID;
@property(nonatomic) int soundType; // @synthesize soundType=_soundType;

+ (id)alertSoundWithSystemSoundID:(unsigned long)arg1;
- (id)description;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)dealloc;
- (id)initWithRingtone:(id)arg1 vibrationPattern:(id)arg2 repeats:(BOOL)arg3;
- (id)initWithSystemSoundID:(unsigned long)arg1 behavior:(unsigned int)arg2;
@end

@interface BBAttachments : NSObject <NSCopying, NSCoding> {
    int primaryType;
    NSCountedSet *_additionalAttachments;
    NSMutableDictionary *_clientSideComposedImageInfos;
}

@property(retain, nonatomic) NSMutableDictionary *clientSideComposedImageInfos; // @synthesize clientSideComposedImageInfos=_clientSideComposedImageInfos;
@property(retain, nonatomic) NSCountedSet *additionalAttachments; // @synthesize additionalAttachments=_additionalAttachments;
@property(nonatomic) int primaryType; // @synthesize primaryType;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (BOOL)isEqualToAttachments:(id)arg1;
- (unsigned int)numberOfAdditionalAttachmentsOfType:(int)arg1;
- (unsigned int)numberOfAdditionalAttachments;
- (void)addAttachmentOfType:(int)arg1;
- (void)dealloc;
@end

@interface BBBulletin : NSObject <NSCopying, NSCoding> {
    NSString *_sectionID;
    NSString *_publisherRecordID;
    NSString *_publisherBulletinID;
    int _addressBookRecordID;
    int _sectionSubtype;
    BBContent *_content;
    BBContent *_modalAlertContent;
    NSDate *_date;
    NSDate *_endDate;
    NSDate *_recencyDate;
    int _dateFormatStyle;
    BOOL _dateIsAllDay;
    int _accessoryStyle;
    BOOL _clearable;
    BBSound *_sound;
    BBAttachments *_attachments;
    NSString *_unlockActionLabelOverride;
    NSMutableDictionary *_actions;
    NSArray *_buttons;
    BOOL _expiresOnPublisherDeath;
    NSDictionary *_context;
    NSDate *_expirationDate;
    NSString *_bulletinID;
    NSDate *_lastInterruptDate;
    id _lifeAssertion;
    id _observer;
    unsigned int realertCount_deprecated;
    NSSet *alertSuppressionAppIDs_deprecated;
}
@property(copy, nonatomic) NSSet *alertSuppressionAppIDs_deprecated; // @synthesize alertSuppressionAppIDs_deprecated;
@property(nonatomic) unsigned int realertCount_deprecated; // @synthesize realertCount_deprecated;
@property(retain, nonatomic) id observer; // @synthesize observer=_observer;
@property(retain, nonatomic) id lifeAssertion; // @synthesize lifeAssertion=_lifeAssertion;
@property(retain, nonatomic) NSDate *lastInterruptDate; // @synthesize lastInterruptDate=_lastInterruptDate;
@property(copy, nonatomic) NSString *bulletinID; // @synthesize bulletinID=_bulletinID;
@property(retain, nonatomic) NSDate *expirationDate; // @synthesize expirationDate=_expirationDate;
@property(retain, nonatomic) NSDictionary *context; // @synthesize context=_context;
@property(nonatomic) BOOL expiresOnPublisherDeath; // @synthesize expiresOnPublisherDeath=_expiresOnPublisherDeath;
@property(copy, nonatomic) NSArray *buttons; // @synthesize buttons=_buttons;
@property(retain, nonatomic) NSMutableDictionary *actions; // @synthesize actions=_actions;
@property(copy, nonatomic) NSString *unlockActionLabelOverride; // @synthesize unlockActionLabelOverride=_unlockActionLabelOverride;
@property(retain, nonatomic) BBAttachments *attachments; // @synthesize attachments=_attachments;
@property(retain, nonatomic) BBSound *sound; // @synthesize sound=_sound;
@property(nonatomic) BOOL clearable; // @synthesize clearable=_clearable;
@property(nonatomic) int accessoryStyle; // @synthesize accessoryStyle=_accessoryStyle;
@property(nonatomic) BOOL dateIsAllDay; // @synthesize dateIsAllDay=_dateIsAllDay;
@property(nonatomic) int dateFormatStyle; // @synthesize dateFormatStyle=_dateFormatStyle;
@property(retain, nonatomic) NSDate *recencyDate; // @synthesize recencyDate=_recencyDate;
@property(retain, nonatomic) NSDate *endDate; // @synthesize endDate=_endDate;
@property(retain, nonatomic) NSDate *date; // @synthesize date=_date;
@property(retain, nonatomic) BBContent *modalAlertContent; // @synthesize modalAlertContent=_modalAlertContent;
@property(retain, nonatomic) BBContent *content; // @synthesize content=_content;
@property(nonatomic) int sectionSubtype; // @synthesize sectionSubtype=_sectionSubtype;
@property(nonatomic) int addressBookRecordID; // @synthesize addressBookRecordID=_addressBookRecordID;
@property(copy, nonatomic) NSString *publisherBulletinID; // @synthesize publisherBulletinID=_publisherBulletinID;
@property(copy, nonatomic) NSString *recordID; // @synthesize recordID=_publisherRecordID;
@property(copy, nonatomic) NSString *sectionID; // @synthesize sectionID=_sectionID;
@property(copy, nonatomic) BBAction *expireAction;
@property(copy, nonatomic) BBAction *replyAction;
@property(copy, nonatomic) BBAction *acknowledgeAction;
@property(copy, nonatomic) BBAction *defaultAction;
@property(readonly, nonatomic) int primaryAttachmentType;
@property(copy, nonatomic) NSString *section;
@property(copy, nonatomic) NSString *message;
@property(copy, nonatomic) NSString *subtitle;
@property(copy, nonatomic) NSString *title;

+ (id)bulletinWithBulletin:(id)arg1;
- (id)description;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)_fillOutCopy:(id)arg1 withZone:(struct _NSZone *)arg2;
- (void)deliverResponse:(id)arg1;
- (id)responseSendBlock;
- (id)responseForExpireAction;
- (id)responseForButtonActionAtIndex:(unsigned int)arg1;
- (id)responseForAcknowledgeAction;
- (id)responseForReplyAction;
- (id)responseForDefaultAction;
- (id)_responseForActionKey:(id)arg1;
- (id)_actionKeyForButtonIndex:(unsigned int)arg1;
- (unsigned int)numberOfAdditionalAttachmentsOfType:(int)arg1;
- (unsigned int)numberOfAdditionalAttachments;
- (id)init;
- (void)dealloc;
@end

@interface SBSMSClass0Alert : NSObject
-(void)initWithString:(NSString *)string;
-(void)activate;
-(void)deactivate;
-(void)setDelegate;
@end

// Global
static SpringBoard *springboard;
static bool vibrate;
static NSString *sound;

void setDeliveryVibrate(bool v) { vibrate = v; }
bool getDeliveryVibrate() { return vibrate; }
void setDeliverySound(NSString *s) { [sound release]; sound = [s retain]; }
NSString *getDeliverySound() { return sound; }
void setSpringBoard(id o) { springboard = o; }

void showBulletin(NSString *title, NSString *subtitle, NSString *message, NSString *sectionID, bool noisy) {
    if (noisy && vibrate) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
//    NSDictionary *vibe = [NSDictionary  dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0],
//                                                                     @"Intensity",
//                                                                     [NSNumber numberWithFloat:0.1],
//                                                                     @"OffDuration",
//                                                                     [NSNumber numberWithFloat:0.1],
//                                                                     @"OnDuration",
//                                                                     [NSNumber numberWithFloat:0.4],
//                                                                     @"TotalDuration",
//                                                                     nil];

    BBSound *snd = [[objc_getClass("BBSound") alloc] initWithRingtone:sound 
                                                     vibrationPattern:nil
                                                              repeats:NO];
    NSLog(@"Sound %@", snd);

    if ([springboard isLocked]) {
        // build a bulletin
        BBBulletin *b = [[objc_getClass("BBBulletin") alloc] init];
        [b setTitle:title];
        [b setSubtitle:message];
        [b setMessage:subtitle];
        [b setSectionID:sectionID];
        if (noisy) [b setSound:snd];

        NSLog(@"%@", b);

        // and as a popup on the away screen
        [[[[objc_getClass("SBAwayController") sharedAwayController] awayView] bulletinController] observer:0 addBulletin:b forFeed:0];
        [b release];
    }
    else {
        // build a bulletin
        BBBulletin *b = [[objc_getClass("BBBulletin") alloc] init];
        [b setTitle:title];
        [b setMessage:[NSString stringWithFormat:@"%@ %@", subtitle, message]];
        [b setSectionID:sectionID];
        if (noisy) [b setSound:snd];

        // publish it as a banner
        [[objc_getClass("SBBulletinBannerController")  sharedInstance] observer:0 addBulletin:b forFeed:0];
        [b release];
    }
    [snd release];
}
// vim: ft=objc ts=4 expandtab
