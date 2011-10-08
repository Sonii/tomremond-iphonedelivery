/** 
 * @file SpringBoard.h
 * @brief some objc interface declarations extracte from SpringBoard executable
 * @author F. Guillemé
 * @date 2011-08-28
 */

@interface UIAlertViewController : NSObject<UIAlertViewDelegate>
@end

#if 1
@interface SBSMSClass0Alert : NSObject
- (id)initWithString:(id)arg1;
- (void)deactivate;
- (void)activate;
- (id)display;
@end

@interface TLToneManager : NSObject {
}

+ (id)sharedRingtoneManager;
- (id)nullTextToneName;
- (id)defaultTextToneName;
- (id)defaultTextToneIdentifier;
- (id)systemNewSoundDirectory;
- (id)systemSoundDirectory;
- (id)systemRingtoneDirectory;
- (id)iTunesRingtoneDirectory;
- (id)ITunesRingtoneInformationPlist;
- (id)deviceITunesRingtoneInformationPlist;
- (id)deviceITunesRingtoneDirectory;
- (id)rootDirectory;
- (id)localizedRingtoneNameWithIdentifier:(id)arg1;
- (id)localizedNameWithIdentifier:(id)arg1;
- (id)defaultRingtonePath;
- (id)defaultRingtoneName;
- (id)defaultRingtoneIdentifier;
- (void)loadITunesRingtoneInfoPlistAtPath:(id)arg1;
- (unsigned long)soundIDForToneIdentifier:(id)arg1;
@end

#else
/* we don't need what follow but I leave it in case.... */
@class SBAlertDisplay;
@class SBAlert;

@interface SBAlertWindow : UIWindow {
    UIView *_contentLayer;
    unsigned int _isAnimating:1;
    unsigned int _isInvalid:1;
    unsigned int _handlerActive:1;
    float _finalAlpha;
    int _currentOrientation;
    SBAlertDisplay *_currentDisplay;
    NSMutableArray *_stackedAlertDisplays;
    NSMutableDictionary *_alertToDisplayMap;
}
+ (struct CGRect)constrainFrameToScreen:(struct CGRect)arg1;
- (id)initWithContentRect:(struct CGRect)arg1;
- (void)dealloc;
- (BOOL)isOpaque;
- (id)stackedDisplayForAlert:(id)arg1;
- (id)contentLayer;
- (void)displayAlert:(id)arg1;
- (BOOL)deactivateAlert:(id)arg1;
- (int)displayCount;
- (void)dismissWindow:(id)arg1;
- (void)alertDisplayWillDismiss;
- (void)popInCurrentDisplay;
- (id)currentDisplay;
- (void)setHandlerAlreadyActive:(BOOL)arg1;
- (BOOL)handlerAlreadyActive;
- (void)_setupContentLayerForCurrentOrientation;
- (BOOL)_isSupportedInterfaceOrientation:(int)arg1;
- (BOOL)shouldWindowUseOnePartInterfaceRotationAnimation:(id)arg1;
- (BOOL)window:(id)arg1 shouldAutorotateToInterfaceOrientation:(int)arg2;
- (id)rotatingContentViewForWindow:(id)arg1;
- (void)window:(id)arg1 willRotateToInterfaceOrientation:(int)arg2 duration:(double)arg3;
- (void)window:(id)arg1 willAnimateRotationToInterfaceOrientation:(int)arg2 duration:(double)arg3;
- (void)window:(id)arg1 didRotateFromInterfaceOrientation:(int)arg2;
- (void)window:(id)arg1 willAnimateFromContentFrame:(struct CGRect)arg2 toContentFrame:(struct CGRect)arg3;
- (void)noteInterfaceOrientationChangingTo:(int)arg1 animated:(BOOL)arg2;
@end

@interface SBAlertDisplay : UIView {
    SBAlert *_alert;
    unsigned int _displaysAboveStatusBar:1;
    unsigned int _shouldAnimateIn:1;
}

- (id)initWithFrame:(struct CGRect)arg1;
- (void)setAlert:(id)arg1;
- (id)alert;
- (void)launchURL:(id)arg1;
- (void)dismiss;
- (void)setHandlerAlreadyActive:(BOOL)arg1;
- (void)alertDisplayWillBecomeVisible;
- (void)alertDisplayBecameVisible;
- (BOOL)displaysAboveStatusBar;
- (void)setDisplaysAboveStatusBar:(BOOL)arg1;
- (BOOL)isReadyToBeRemovedFromView;
- (void)setShouldAnimateIn:(BOOL)arg1;
- (BOOL)shouldAnimateIn;
- (void)alertWindowResizedFromContentFrame:(struct CGRect)arg1 toContentFrame:(struct CGRect)arg2;
- (void)layoutForInterfaceOrientation:(int)arg1;
- (BOOL)isSupportedInterfaceOrientation:(int)arg1;
- (void)willRotateToInterfaceOrientation:(int)arg1 duration:(double)arg2;
- (void)willAnimateRotationToInterfaceOrientation:(int)arg1 duration:(double)arg2;
- (void)didRotateFromInterfaceOrientation:(int)arg1;
- (BOOL)shouldAddClippingViewDuringRotation;
@end

@interface SBDisplay : NSObject {
    //NSMapTable *_displayValues;
    //NSMapTable *_activationValues;
    //NSMapTable *_deactivationValues;
    //NSHashTable *_displayFlags;
    //NSHashTable *_activationFlags;
    //NSHashTable *_deactivationFlags;
    NSMutableSet *_suppressVolumeHudCategories;
    float _accelerometerSampleInterval;
    unsigned int _disableIdleTimer;
    unsigned int _expectsFaceContact:1;
    unsigned int _accelerometerDeviceOrientationChangedEventsEnabled:1;
    unsigned int _proximityEventsEnabled:1;
    unsigned int _showsProgress;
}

+ (id)_defaultDisplayState;
+ (void)setDefaultValue:(id)arg1 forKey:(id)arg2 displayIdentifier:(id)arg3;
+ (id)defaultValueForKey:(id)arg1 displayIdentifier:(id)arg2 urlScheme:(id)arg3;
- (void)dealloc;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)displayIdentifier;
- (id)urlScheme;
- (id)_newValueTable;
- (id)_newFlagTable;
- (void)clearDisplaySettings;
- (void)setDisplaySetting:(unsigned int)arg1 flag:(BOOL)arg2;
- (void)setDisplaySetting:(unsigned int)arg1 value:(id)arg2;
- (id)displayValue:(unsigned int)arg1;
- (BOOL)displayFlag:(unsigned int)arg1;
- (void)clearActivationSettings;
- (void)setActivationSetting:(unsigned int)arg1 flag:(BOOL)arg2;
- (void)setActivationSetting:(unsigned int)arg1 value:(id)arg2;
- (id)activationValue:(unsigned int)arg1;
- (BOOL)activationFlag:(unsigned int)arg1;
- (void)clearDeactivationSettings;
- (void)setDeactivationSetting:(unsigned int)arg1 flag:(BOOL)arg2;
- (void)setDeactivationSetting:(unsigned int)arg1 value:(id)arg2;
- (id)deactivationValue:(unsigned int)arg1;
- (BOOL)deactivationFlag:(unsigned int)arg1;
- (void)activate;
- (void)launchSucceeded:(BOOL)arg1;
- (void)deactivate;
- (void)deactivated;
- (void)deactivateAfterLocking;
- (void)kill;
- (void)_exitedCommon;
- (void)exitedAbnormally;
- (void)exitedNormally;
- (BOOL)allowsEventOnlySuspension;
- (int)defaultStatusBarStyle;
- (int)statusBarStyle;
- (int)statusBarStyleOverridesToCancel;
- (BOOL)defaultStatusBarHidden;
- (BOOL)statusBarHidden;
- (int)statusBarOrientation;
- (int)launchingInterfaceOrientationForCurrentOrientation;
- (int)launchingInterfaceOrientationForCurrentOrientation:(int)arg1;
- (BOOL)isNowRecordingApplication;
- (int)effectiveStatusBarStyle;
- (void)setDisableIdleTimer:(BOOL)arg1;
- (BOOL)disableIdleTimer;
- (double)autoDimTime;
- (double)autoLockTime;
- (void)setExpectsFaceContact:(BOOL)arg1;
- (BOOL)expectsFaceContact;
- (void)setAccelerometerSampleInterval:(double)arg1;
- (double)accelerometerSampleInterval;
- (void)setAccelerometerDeviceOrientationChangedEventsEnabled:(BOOL)arg1;
- (BOOL)accelerometerDeviceOrientationChangedEventsEnabled;
- (void)setProximityEventsEnabled:(BOOL)arg1;
- (BOOL)proximityEventsEnabled;
- (void)setShowsProgress:(BOOL)arg1;
- (BOOL)showsProgress;
- (void)setSystemVolumeHUDEnabled:(BOOL)arg1 forCategory:(id)arg2;
- (BOOL)showSystemVolumeHUDForCategory:(id)arg1;
- (void)handleLock:(BOOL)arg1;
- (void)prepareForActivationOfDisplay:(id)arg1 toHandleURL:(id)arg2;
- (BOOL)suppressesNotifications;
- (id)description;
- (id)descriptionForDisplaySetting:(unsigned int)arg1;
- (id)displaySettingsDescription;
- (id)descriptionForActivationSetting:(unsigned int)arg1;
- (id)activationSettingsDescription;
- (id)descriptionForDeactivationSetting:(unsigned int)arg1;
- (id)deactivationSettingsDescription;
@end

@interface SBAlert : SBDisplay {
    SBAlertDisplay *_display;
    NSMutableDictionary *_dictionary;
    SBAlertWindow *_deferredAlertWindow;
}
+ (void)registerForAlerts;
+ (id)alertWindow;
+ (void)test;
+ (void)activateAlertForController:(id)arg1 animated:(BOOL)arg2 animateCurrentDisplayOut:(BOOL)arg3 withDelay:(BOOL)arg4 isSlidingDisplay:(BOOL)arg5;
+ (void)deactivateAlertForController:(id)arg1 animated:(BOOL)arg2 animateOldDisplayInWithStyle:(int)arg3 isSlidingDisplay:(BOOL)arg4;
+ (void)alertAdapterDisplayDidDisappear:(id)arg1;
+ (id)_adapterForController:(id)arg1;
- (void)dealloc;
- (id)display;
- (void)setDisplay:(id)arg1;
- (id)alertDisplayViewWithSize:(struct CGSize)arg1;
- (void)setObject:(id)arg1 forKey:(id)arg2;
- (id)objectForKey:(id)arg1;
- (void)removeObjectForKey:(id)arg1;
- (BOOL)allowsStackingOfAlert:(id)arg1;
- (BOOL)undimsDisplay;
- (BOOL)showsSpringBoardStatusBar;
- (float)finalAlpha;
- (struct CGRect)alertWindowRect;
- (Class)alertWindowClass;
- (void)_updateStatusBarLockAndTime;
- (int)statusBarStyleOverridesToCancel;
- (void)activate;
- (void)tearDownAlertWindow:(id)arg1;
- (int)interfaceOrientationForActivation;
- (void)removeFromView;
- (void)deactivate;
- (int)effectiveStatusBarStyle;
- (double)autoDimTime;
- (int)statusBarStyle;
- (void)didAnimateLockKeypadIn;
- (void)didAnimateLockKeypadOut;
- (void)didFinishAnimatingIn;
- (void)didFinishAnimatingOut;
- (BOOL)handleMenuButtonTap;
- (BOOL)shouldDeactivateAlertItemsOnActivation;
- (BOOL)hasTranslucentBackground;
- (BOOL)handleLockButtonPressed;
- (BOOL)handleVolumeUpButtonPressed;
- (BOOL)handleVolumeDownButtonPressed;
- (BOOL)handleHeadsetButtonPressed:(BOOL)arg1;
- (BOOL)suppressesNotifications;
@end


@interface SBUSSDAlert : SBAlert {
    unsigned int _receivedString:1;
    unsigned int _dismissOnActivate:1;
    NSTimer *_delayedDismissTimer;
}
+ (void)registerForSettingsAlerts;
+ (void)registerForAlerts;
+ (void)test;
+ (id)errorStringForCode:(id)arg1;
+ (void)_daemonRestart:(id)arg1;
+ (void)_newSIM:(id)arg1;
- (void)dealloc;
- (id)alertDisplayViewWithSize:(struct CGSize)arg1;
- (void)USSDStringAvailable:(id)arg1 allowsResponse:(BOOL)arg2;
- (BOOL)allowsResponse;
- (BOOL)receivedString;
- (void)setDismissOnActivate:(BOOL)arg1;
- (void)_delayedDismiss;
- (void)activate;
- (void)deactivate;
@end

@interface SBSMSClass0Alert : SBUSSDAlert {
}
+ (void)registerForAlerts;
+ (BOOL)shouldPlayMessageReceived;
+ (void)playMessageReceived;
+ (void)defaultAlertTonePrefChanged;
- (void)_unregisterForNotifications;
- (void)_registerForNotifications;
- (id)initWithString:(id)arg1;
- (void)deactivate;
@end

@interface SBUSSDAlertDisplay : SBAlertDisplay <UITextFieldDelegate>
{
    //TPBottomSingleButtonBar *_responseBar;
    //UIView *_notifyView;
    //UIView *_replyView;
    //UITransitionView *_transitionView;
    //UIScrollView *_scroller;
    //SBTextDisplayView *_contentView;
    //SBTextDisplayView *_charsRemainingView;
    //UIActivityIndicatorView *_progressIndicator;
    //UITextField *_responseField;
    //BOOL _allowsResponse;
}

- (id)initWithFrame:(struct CGRect)arg1;
- (id)_notifyView;
- (id)_replyView;
- (void)dealloc;
- (void)displayString:(id)arg1 centerVertically:(BOOL)arg2;
- (void)alertDisplayWillBecomeVisible;
- (void)alertDisplayBecameVisible;
- (void)_setupResponseBar;
- (void)alertStringAvailable:(id)arg1;
- (BOOL)allowsResponse;
- (void)setAllowsResponse:(BOOL)arg1;
- (BOOL)textField:(id)arg1 shouldInsertText:(id)arg2 replacingRange:(struct _NSRange)arg3;
- (void)_updateCharsRemaining;
- (void)_textChanged:(id)arg1;
- (void)_replyClicked;
- (void)_okayClicked;
- (void)_cancelClicked;
@end

@interface TLToneManager : NSObject {
    NSMutableDictionary *_iTunesTonesByIdentifier;
    NSMutableDictionary *_textTonesByIdentifier;
    NSMutableDictionary *_iTunesIdentifiersByPID;
    NSDictionary *_previewBehaviorForDefaultIdentifier;
    NSDictionary *_identifierAliasMap;
    id _delegate;
    BOOL _observingChangeNotifications;
}

+ (BOOL)identifierIsTextTone:(id)arg1;
+ (id)sharedRingtoneManager;
- (id)installedTones;
- (void)deleteAllSyncedData;
- (BOOL)_removeToneFromManifest:(id)arg1 fileName:(id)arg2;
- (BOOL)_addToneToManifest:(id)arg1 metadata:(id)arg2 fileName:(id)arg3;
- (id)iTunesToneForPID:(id)arg1;
- (void)importTone:(id)arg1 metadata:(id)arg2 completionBlock:(id)arg3;
- (BOOL)deleteSyncedToneByPID:(id)arg1;
- (BOOL)insertPurchasedToneMetadata:(id)arg1 filename:(id)arg2;
- (BOOL)insertSyncedToneMetadata:(id)arg1 filename:(id)arg2;
- (int)_lockManifest:(id)arg1;
- (BOOL)ensureDirectoryExists:(id)arg1;
- (unsigned long)_currentToneSoundID:(id)arg1 defaultIdentifier:(id)arg2;
- (id)_defaultToneName:(int)arg1;
- (id)_defaultToneIdentifier:(int)arg1;
- (BOOL)hasAdditionalTextTones;
- (unsigned long)createPreviewSoundIDForToneIdentifier:(id)arg1;
- (unsigned long)soundIDForToneIdentifier:(id)arg1 isValid:(char *)arg2;
- (unsigned long)soundIDForToneIdentifier:(id)arg1;
- (unsigned long)soundIDForTextToneIdentifier:(id)arg1 isValid:(char *)arg2;
- (unsigned long)soundIDForTextToneIdentifier:(id)arg1;
- (unsigned long)_soundIDForSystemTone:(id)arg1 isValid:(char *)arg2;
- (id)aliasForIdentifier:(id)arg1;
- (int)previewBehaviorForDefaultIdentifier:(id)arg1;
- (unsigned long)previewSoundIDForTextToneIdentifier:(id)arg1;
- (id)copyNameOfTextToneWithIdentifier:(id)arg1 isValid:(char *)arg2;
- (unsigned long)currentTextToneSoundID;
- (id)nullTextToneName;
- (id)defaultTextToneName;
- (id)defaultTextToneIdentifier;
- (void)setCurrentRingtoneIdentifier:(id)arg1;
- (void)setCurrentTextToneIdentifier:(id)arg1;
- (id)copyCurrentTextToneName;
- (id)copyCurrentTextToneIdentifier;
- (BOOL)isValidToneIdentifier:(id)arg1;
- (void)loadTextToneInfo;
- (id)systemNewSoundDirectory;
- (id)systemSoundDirectory;
- (id)systemRingtoneDirectory;
- (id)iTunesRingtoneDirectory;
- (id)ITunesRingtoneInformationPlist;
- (id)deviceITunesRingtoneInformationPlist;
- (id)deviceITunesRingtoneDirectory;
- (id)rootDirectory;
- (void)_reloadITunesRingtonesAfterExternalChange;
- (id)_copyITunesRingtonesFromManifestPath:(id)arg1 mediaDirectoryPath:(id)arg2;
- (unsigned int)durationOfToneWithIdentifier:(id)arg1;
- (BOOL)isAlertTone:(id)arg1;
- (BOOL)isRingtonePurchased:(id)arg1;
- (id)newAVItemWithRingtoneIdentifier:(id)arg1;
- (BOOL)toneWithIdentifierIsValid:(id)arg1;
- (id)copyNameOfIdentifier:(id)arg1 isValid:(char *)arg2;
- (id)copyIdentifierForRingtoneAtPath:(id)arg1 isValid:(char *)arg2;
- (id)copyPathOfRingtoneWithIdentifier:(id)arg1 isValid:(char *)arg2;
- (id)copyPathOfRingtoneWithIdentifier:(id)arg1;
- (id)copyNameOfRingtoneWithIdentifier:(id)arg1 isValid:(char *)arg2;
- (id)copyNameOfRingtoneWithIdentifier:(id)arg1;
- (id)pathFromIdentifier:(id)arg1 withPrefix:(id)arg2;
- (id)localizedRingtoneNameWithIdentifier:(id)arg1;
- (id)localizedNameWithIdentifier:(id)arg1;
- (id)defaultRingtonePath;
- (id)defaultRingtoneName;
- (id)defaultRingtoneIdentifier;
- (id)currentRingtoneName;
- (id)currentRingtoneIdentifier;
- (id)copyCurrentRingtoneIdentifier;
- (id)copyCurrentRingtoneName;
- (void)_deviceRingtonesChangedNotification;
- (void)loadITunesRingtoneInfoPlistAtPath:(id)arg1;
- (void)clearOldToneSettings;
- (void)fixupMissingToneSettings;
- (void)setDelegate:(id)arg1;
- (BOOL)shouldShowAlarmSounds;
- (BOOL)shouldShowRingtones;
- (void)dealloc;
- (id)initWithITunesRingtonePlistAtPath:(id)arg1 registerForChangeNotifications:(BOOL)arg2;
- (id)initWithChangeNotifications:(BOOL)arg1;
- (id)init;
@end
#endif



