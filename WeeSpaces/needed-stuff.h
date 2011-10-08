@interface SBUIController
+(id)sharedInstance;
-(void)clickedMenuButton;
-(void)activateApplicationAnimated:(id)app;
-(void)activateApplicationFromSwitcher:(id)app;
@end

@interface SBUserAgent
+(id)sharedUserAgent;
-(BOOL)springBoardIsActive;
-(void)setBadgeNumberOrString:(id)string forApplicationWithID:(id)anId;
-(void)setIdleText:(id)text;
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

@interface SBApplication : NSObject
@property(retain, nonatomic) id process;
-(id)appSnapshotPath;
-(id)displayName;
-(void)kill;
-(id)defaultImage:(BOOL*)image preferredScale:(float)scale originalOrientation:(int*)orientation currentOrientation:(int*)orientation4 canUseIOSurface:(BOOL)surface;
@end;
