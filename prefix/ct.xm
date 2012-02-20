#import <UIKit/UIKit.h>
#import "CT.h"

%hook CTMessage
- (void)setCountryCode:(id)arg1 { %log; %orig; }
- (id)description { %log; return %orig; }
- (id)allContentTypeParameterNames { %log; return %orig; }
- (void)addContentTypeParameterWithName:(id)arg1 value:(id)arg2 { %log; %orig; }
- (id)contentTypeParameterWithName:(id)arg1 { %log; return %orig; }
- (void)removePartAtIndex:(unsigned int)arg1 { %log; %orig; }
- (id)addPart:(id)arg1 { %log; return %orig; }
//- (id)addData:(id)arg1 withContentType:(id)arg2 { %log; return %orig; }
- (id)addText:(id)arg1 { %log; return %orig; }
- (void)addEmailRecipient:(id)arg1 { %log; %orig; }
- (void)addPhoneRecipient:(id)arg1 { %log; %orig; }
- (void)setRecipients:(id)arg1 { %log; %orig; }
- (void)setRecipient:(id)arg1 { %log; %orig; }
- (void)removeRecipientsInArray:(id)arg1 { %log; %orig; }
- (void)removeRecipient:(id)arg1 { %log; %orig; }
- (void)addRecipient:(id)arg1 { %log; %orig; }
- (void)setReplaceMessage:(unsigned int)arg1 { %log; %orig; }
- (void)setRawHeaders:(id)arg1 { %log; %orig; }
- (void)dealloc { %log; %orig; }
- (id)initWithDate:(id)arg1 { %log; return %orig; }
- (id)init { %log; return %orig; }
%end
%hook CTPhoneNumber
+ (id)phoneNumberWithDigits:(id)arg1 countryCode:(id)arg2 { %log; return %orig; }
- (id)encodedString { %log; return %orig; }
- (id)canonicalFormat { %log; return %orig; }
- (id)formatForCallingCountry:(id)arg1 { %log; return %orig; }
- (id)copyWithZone:(struct _NSZone *)arg1 { %log; return %orig; }
- (void)dealloc { %log; %orig; }
- (id)initWithDigits:(id)arg1 countryCode:(id)arg2 { %log; return %orig; }
- (int)numberOfDigitsForShortCodeNumber { %log; return %orig; }
%end
%hook CTMessageCenter
+ (id)sharedMessageCenter { %log; return %orig; }
- (BOOL)getCharacterCount:(int *)arg1 andMessageSplitThreshold:(int *)arg2 forSmsText:(id)arg3 { %log; return %orig; }
- (BOOL)sendSMSWithText:(id)arg1 serviceCenter:(id)arg2 toAddress:(id)arg3 withMoreToFollow:(BOOL)arg4 { %log; return %orig; }
- (BOOL)sendSMSWithText:(id)arg1 serviceCenter:(id)arg2 toAddress:(id)arg3 { %log; return %orig; }
- (BOOL)isMmsConfigured { %log; return %orig; }
- (BOOL)isMmsEnabled { %log; return %orig; }
- (void)setDeliveryReportsEnabled:(BOOL)arg1 { %log; %orig; }
- (CDStruct_1ef3fb1f)isDeliveryReportsEnabled:(char *)arg1 { %log; return %orig; }
- (id)decodeMessage:(id)arg1 { %log; return %orig; }
- (id)encodeMessage:(id)arg1 { %log; return %orig; }
- (id)statusOfOutgoingMessages { %log; return %orig; }
- (id)deferredMessageWithId:(unsigned int)arg1 { %log; return %orig; }
- (id)incomingMessageWithId:(unsigned int)arg1 { %log; return %orig; }
- (void)acknowledgeOutgoingMessageWithId:(unsigned int)arg1 { %log; %orig; }
- (void)acknowledgeIncomingMessageWithId:(unsigned int)arg1 { %log; %orig; }
- (id)allIncomingMessages { %log; return %orig; }
- (int)incomingMessageCount { %log; return %orig; }
- (id)incomingMessageWithId:(unsigned int)arg1 telephonyCenter:(struct __CTTelephonyCenter *)arg2 isDeferred:(BOOL)arg3 { %log; return %orig; }
- (CDStruct_1ef3fb1f)send:(id)arg1 withMoreToFollow:(BOOL)arg2 { %log; return %orig; }
- (CDStruct_1ef3fb1f)send:(id)arg1 { %log; return %orig; }
- (CDStruct_1ef3fb1f)sendMMS:(id)arg1 { %log; return %orig; }
- (void)sendMessageAsSmsToShortCodeRecipients:(id)arg1 andReplaceData:(id *)arg2 { %log; %orig; }
//- (CDStruct_1ef3fb1f)sendMMSFromData:(id)arg1 messageId:(unsigned int)arg2 { %log; return %orig; }
- (CDStruct_1ef3fb1f)sendSMS:(id)arg1 withMoreToFollow:(BOOL)arg2 { %log; return %orig; }
- (id)init { %log; return %orig; }
%end
%hook CTMmsEncoder
+ (id)decodeMessageFromData:(id)arg1 { %log; return %orig; }
+ (id)encodeMessage:(id)arg1 { %log; return %orig; }
+ (id)decodeSmsFromData:(id)arg1 { %log; return %orig; }
%end
%hook CTMessagePart
- (void)dealloc { %log; %orig; }
- (id)allContentTypeParameterNames { %log; return %orig; }
- (void)addContentTypeParameterWithName:(id)arg1 value:(id)arg2 { %log; %orig; }
- (id)contentTypeParameterWithName:(id)arg1 { %log; return %orig; }
//- (id)initWithData:(id)arg1 contentType:(id)arg2 { %log; return %orig; }
%end
%hook CTMessageStatus
- (id)initWithMessageId:(unsigned int)arg1 messageType:(int)arg2 result:(int)arg3 { %log; return %orig; }
%end
%hook CTEmailAddress
+ (id)emailAddress:(id)arg1 { %log; return %orig; }
- (id)canonicalFormat { %log; return %orig; }
- (id)encodedString { %log; return %orig; }
- (id)copyWithZone:(struct _NSZone *)arg1 { %log; return %orig; }
- (void)dealloc { %log; %orig; }
- (id)initWithAddress:(id)arg1 { %log; return %orig; }
%end
%hook CTCarrier
- (BOOL)isEqual:(id)arg1 { %log; return %orig; }
- (void)dealloc { %log; %orig; }
- (id)init { %log; return %orig; }
- (id)description { %log; return %orig; }
%end
%hook CTTelephonyNetworkInfo
- (void)postUpdatesIfNecessary { %log; %orig; }
- (void)handleNotificationFromConnection:(void *)arg1 ofType:(id)arg2 withInfo:(id)arg3 { %log; %orig; }
- (BOOL)updateNetworkInfoAndShouldNotifyClient:(char *)arg1 { %log; return %orig; }
- (BOOL)getAllowsVOIP:(char *)arg1 withCTError:(CDStruct_1ef3fb1f *)arg2 { %log; return %orig; }
- (BOOL)getMobileNetworkCode:(id)arg1 withCTError:(CDStruct_1ef3fb1f *)arg2 { %log; return %orig; }
- (BOOL)getMobileCountryCode:(id)arg1 andIsoCountryCode:(id)arg2 withCTError:(CDStruct_1ef3fb1f *)arg3 { %log; return %orig; }
- (BOOL)getCarrierName:(id)arg1 withCTError:(CDStruct_1ef3fb1f *)arg2 { %log; return %orig; }
- (void)dealloc { %log; %orig; }
- (id)init { %log; return %orig; }
- (void)cleanUpServerConnection { %log; %orig; }
- (void)cleanUpServerConnectionNoLock { %log; %orig; }
- (void)reestablishServerConnectionIfNeeded { %log; %orig; }
- (BOOL)setUpServerConnection { %log; return %orig; }
%end
%hook CTCallCenter
- (id)description { %log; return %orig; }
- (void)broadcastCallStateChangesIfNeededWithFailureLogMessage:(id)arg1 { %log; %orig; }

- (void)handleNotificationFromConnection:(void *)arg1 ofType:(id)arg2 withInfo:(id)arg3 { %log; %orig; }
- (BOOL)calculateCallStateChanges:(id)arg1 { %log; return %orig; }
- (BOOL)getCurrentCallSetFromServer:(id)arg1 { %log; return %orig; }
- (void)dealloc { %log; %orig; }
- (id)init { %log; return %orig; }
- (void)cleanUpServerConnection { %log; %orig; }
- (void)cleanUpServerConnectionNoLock { %log; %orig; }
- (void)reestablishServerConnectionIfNeeded { %log; %orig; }
- (BOOL)setUpServerConnection { %log; return %orig; }
%end
%hook CTCall
+ (id)callForCTCallRef:(struct __CTCall *)arg1 { %log; return %orig; }
- (unsigned int)hash { %log; return %orig; }
- (BOOL)isEqual:(id)arg1 { %log; return %orig; }
- (id)description { %log; return %orig; }
- (void)dealloc { %log; %orig; }
%end
