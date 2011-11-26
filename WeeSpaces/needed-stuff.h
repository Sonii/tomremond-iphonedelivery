@interface SBUIController
+(id)sharedInstance;
-(void)clickedMenuButton;
-(void)activateApplicationAnimated:(id)app;
-(void)activateApplicationFromSwitcher:(id)app;
- (id)_zoomViewForApplication:(id)app includeStatusBar:(char)s includeBanner:(char)b snapshotFrame:(struct CGRect *)r canUseIOSurface:(char)s;
-(id)_zoomViewForAppDosado:(id)appDosado includeStatusBar:(BOOL)bar includeBanner:(BOOL)banner;
@end

@interface UIApplication(xxx)
-(int)activeInterfaceOrientation;
@end

@interface SBUserAgent
+(id)sharedUserAgent;
-(BOOL)springBoardIsActive;
-(void)setBadgeNumberOrString:(id)string forApplicationWithID:(id)anId;
-(void)setIdleText:(id)text;
-(BOOL)deviceIsLocked;
@end

@interface SBAwayController
+(id)sharedAwayController;
-(BOOL)isPasswordProtected;
-(BOOL)isLocked;
-(void)unlockWithSound:(BOOL)sound;
@end


@interface SBIconController
+(id)sharedInstance;
-(id)rootIconListAtIndex:(unsigned)page;
@end

@interface SBIconListView : UIView
-(id)icons;
@end

@interface SBNewsstandIcon : NSObject
@end

@interface SBFolderIcon : NSObject
-(id)iconOverlayImageForLocation:(unsigned)n;
@end

@interface SBApplicationIcon  : NSObject
-(id)getGenericIconImage:(int)image;
-(UIImage *)generateIconImage:(int)image;
-(id)displayName;
-(void)launch;
@end

@interface SBBulletinListController
+(id)sharedInstance;
-(void)showTabViewAnimated:(BOOL)animated;
-(void)hideTabViewAnimated:(BOOL)animated;
-(void)hideListViewAnimated:(BOOL)animated;
@end

@interface SBApplicationController
+(id)sharedInstance;
-(id)allApplications;
@end

@interface SBProcess 
//@property(readonly, assign) int pid;
//@property(readonly, assign) double execTime;
@property(readonly, assign) double elapsedCPUTime;
//@property(readonly, assign) int priority;
//@property(readonly, assign) int suspendCount;
//@property(assign, getter=isFrontmost) BOOL frontmost;
//@property(assign, getter=isRunning) BOOL running;
//+(id)_allProcesses;
@end

@interface SBApplication : NSObject
@property(retain, nonatomic) SBProcess *process;
//-(id)appSnapshotPath;
-(NSString *)displayName;
-(NSString *)bundleIdentifier;
//-(void)kill;
//-(void)flushSnapshots;
//-(id)defaultImage:(BOOL*)image preferredScale:(float)scale originalOrientation:(int*)orientation currentOrientation:(int*)orientation4 canUseIOSurface:(BOOL)surface;
@end;

@interface SBAppSwitcherController 
@property(retain) NSString* topAppDisplayID;
+(id)sharedInstance;
@end

@interface SBAppSwitcherModel
+(id)sharedInstance;
-(id)_recentsFromPrefs;
@end
