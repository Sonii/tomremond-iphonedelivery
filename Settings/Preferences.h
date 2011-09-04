@protocol PSController <NSObject>
-(void)setParentController:(id)controller;
-(id)parentController;
-(void)setRootController:(id)controller;
-(id)rootController;
-(void)setSpecifier:(id)specifier;
-(id)specifier;
-(void)suspend;
-(void)didLock;
-(void)willUnlock;
-(void)didUnlock;
-(void)didWake;
-(void)pushController:(id)controller;
-(void)handleURL:(id)url;
-(void)setPreferenceValue:(id)value specifier:(id)specifier;
-(id)readPreferenceValue:(id)value;
-(void)willResignActive;
-(void)willBecomeActive;
-(BOOL)canBeShownFromSuspendedState;
-(void)statusBarWillAnimateByHeight:(float)statusBar;
@end

@interface PSViewController : NSObject <PSController> {
}
-(void)setParentController:(id)controller;
-(id)parentController;
-(void)setRootController:(id)controller;
-(id)rootController;
-(void)dealloc;
-(void)setSpecifier:(id)specifier;
-(id)specifier;
-(void)setPreferenceValue:(id)value specifier:(id)specifier;
-(id)readPreferenceValue:(id)value;
-(void)willResignActive;
-(void)willBecomeActive;
-(void)suspend;
-(void)didLock;
-(void)willUnlock;
-(void)didUnlock;
-(void)didWake;
-(void)pushController:(id)controller;
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation;
-(void)handleURL:(id)url;
-(id)methodSignatureForSelector:(SEL)selector;
-(void)forwardInvocation:(id)invocation;
-(void)popupViewWillDisappear;
-(void)popupViewDidDisappear;
-(void)formSheetViewWillDisappear;
-(void)formSheetViewDidDisappear;
-(BOOL)canBeShownFromSuspendedState;
-(void)statusBarWillAnimateByHeight:(float)statusBar;
@end

@interface PSSpecifier : NSObject {
    id target;
    SEL getter;
    SEL setter;
    SEL action;
    SEL cancel;
    Class detailControllerClass;
    int cellType;
    Class editPaneClass;
    int keyboardType;
    int autoCapsType;
    int autoCorrectionType;
    int textFieldType;
    NSString* _name;
    NSArray* _values;
    NSDictionary* _titleDict;
    NSDictionary* _shortTitleDict;
    id _userInfo;
    NSMutableDictionary* _properties;
}
@property(assign, nonatomic) id target;
@property(assign, nonatomic) Class detailControllerClass;
@property(assign, nonatomic) int cellType;
@property(assign, nonatomic) Class editPaneClass;
@property(retain, nonatomic) id userInfo;
@property(retain, nonatomic) NSDictionary* titleDictionary;
@property(retain, nonatomic) NSDictionary* shortTitleDictionary;
@property(retain, nonatomic) NSArray* values;
@property(retain, nonatomic) NSString* name;
@property(retain, nonatomic) NSString* identifier;
+(id)preferenceSpecifierNamed:(id)named target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(int)cell edit:(Class)edit;
+(id)groupSpecifierWithName:(id)name;
+(id)emptyGroupSpecifier;
+(int)autoCorrectionTypeForNumber:(id)number;
+(int)autoCapsTypeForString:(id)string;
+(int)keyboardTypeForString:(id)string;
-(id)init;
-(id)propertyForKey:(id)key;
-(void)setProperty:(id)property forKey:(id)key;
-(void)removePropertyForKey:(id)key;
-(void)setProperties:(id)properties;
-(id)properties;
-(void)loadValuesAndTitlesFromDataSource;
-(void)setValues:(id)values titles:(id)titles;
-(void)setValues:(id)values titles:(id)titles shortTitles:(id)titles3;
-(void)setupIconImageWithBundle:(id)bundle;
-(void)setupIconImageWithPath:(id)path;
-(void)dealloc;
-(id)description;
-(void)setKeyboardType:(int)type autoCaps:(int)caps autoCorrection:(int)correction;
-(int)titleCompare:(id)compare;
@end

@interface PSListController : PSViewController{
    NSMutableDictionary* _cells;
    BOOL _cachesCells;
    BOOL _forceSynchronousIconLoadForCreatedCells;
    UITableView* _table;
    NSArray* _specifiers;
    NSMutableDictionary* _specifiersByID;
    NSMutableArray* _groups;
    NSString* _specifierID;
    NSMutableArray* _bundleControllers;
    BOOL _bundlesLoaded;
    BOOL _showingSetupController;
    id _actionSheet;
    id _alertView;
    BOOL _swapAlertButtons;
    BOOL _keyboardWasVisible;
    id _keyboard;
    id _popupStylePopoverController;
    BOOL _popupStylePopoverShouldRePresent;
    BOOL _popupIsModal;
    BOOL _popupIsDismissing;
    BOOL _hasAppeared;
    float _verticalContentOffset;
    NSString* _offsetItemName;
    CGPoint _contentOffsetWithKeyboard;
}
+(BOOL)displaysButtonBar;
-(void)clearCache;
-(void)setCachesCells:(BOOL)cells;
-(id)description;
-(id)table;
-(id)bundle;
-(id)specifier;
-(id)loadSpecifiersFromPlistName:(id)plistName target:(id)target;
-(id)specifiers;
-(void)_addIdentifierForSpecifier:(id)specifier;
-(void)_removeIdentifierForSpecifier:(id)specifier;
-(void)setSpecifiers:(id)specifiers;
-(id)indexPathForIndex:(int)index;
-(int)indexForIndexPath:(id)indexPath;
-(void)beginUpdates;
-(void)endUpdates;
-(void)reloadSpecifierAtIndex:(int)index animated:(BOOL)animated;
-(void)reloadSpecifierAtIndex:(int)index;
-(void)reloadSpecifier:(id)specifier animated:(BOOL)animated;
-(void)reloadSpecifier:(id)specifier;
-(void)reloadSpecifierID:(id)anId animated:(BOOL)animated;
-(void)reloadSpecifierID:(id)anId;
-(int)indexOfSpecifierID:(id)specifierID;
-(int)indexOfSpecifier:(id)specifier;
-(BOOL)containsSpecifier:(id)specifier;
-(int)indexOfGroup:(int)group;
-(int)numberOfGroups;
-(id)specifierAtIndex:(int)index;
-(BOOL)getGroup:(int*)group row:(int*)row ofSpecifierID:(id)specifierID;
-(BOOL)getGroup:(int*)group row:(int*)row ofSpecifier:(id)specifier;
-(BOOL)_getGroup:(int*)group row:(int*)row ofSpecifierAtIndex:(int)index groups:(id)groups;
-(BOOL)getGroup:(int*)group row:(int*)row ofSpecifierAtIndex:(int)index;
-(int)indexForRow:(int)row inGroup:(int)group;
-(int)rowsForGroup:(int)group;
-(id)specifiersInGroup:(int)group;
-(void)insertSpecifier:(id)specifier atIndex:(int)index animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier afterSpecifier:(id)specifier2 animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier afterSpecifierID:(id)anId animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier atEndOfGroup:(int)group animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier atIndex:(int)index;
-(void)insertSpecifier:(id)specifier afterSpecifier:(id)specifier2;
-(void)insertSpecifier:(id)specifier afterSpecifierID:(id)anId;
-(void)insertSpecifier:(id)specifier atEndOfGroup:(int)group;
-(void)_insertContiguousSpecifiers:(id)specifiers atIndex:(int)index animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers atIndex:(int)index animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifier:(id)specifier animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifierID:(id)anId animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers atEndOfGroup:(int)group animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers atIndex:(int)index;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifier:(id)specifier;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifierID:(id)anId;
-(void)insertContiguousSpecifiers:(id)specifiers atEndOfGroup:(int)group;
-(void)addSpecifier:(id)specifier;
-(void)addSpecifier:(id)specifier animated:(BOOL)animated;
-(void)addSpecifiersFromArray:(id)array;
-(void)addSpecifiersFromArray:(id)array animated:(BOOL)animated;
-(void)removeSpecifier:(id)specifier animated:(BOOL)animated;
-(void)removeSpecifierID:(id)anId animated:(BOOL)animated;
-(void)removeSpecifierAtIndex:(int)index animated:(BOOL)animated;
-(void)removeSpecifier:(id)specifier;
-(void)removeSpecifierID:(id)anId;
-(void)removeSpecifierAtIndex:(int)index;
-(void)removeLastSpecifier;
-(void)removeLastSpecifierAnimated:(BOOL)animated;
-(void)_removeContiguousSpecifiers:(id)specifiers animated:(BOOL)animated;
-(void)removeContiguousSpecifiers:(id)specifiers animated:(BOOL)animated;
-(void)removeContiguousSpecifiers:(id)specifiers;
-(void)replaceContiguousSpecifiers:(id)specifiers withSpecifiers:(id)specifiers2;
-(void)replaceContiguousSpecifiers:(id)specifiers withSpecifiers:(id)specifiers2 animated:(BOOL)animated;
-(int)_nextGroupInSpecifiersAfterIndex:(int)specifiersAfterIndex inArray:(id)array;
-(void)updateSpecifiers:(id)specifiers withSpecifiers:(id)specifiers2;
-(void)updateSpecifiersInRange:(NSRange)range withSpecifiers:(id)specifiers;
-(void)_loadBundleControllers;
-(void)_unloadBundleControllers;
-(void)dealloc;
-(id)init;
-(id)initForContentSize:(CGSize)contentSize;
-(Class)tableViewClass;
-(int)tableStyle;
-(Class)backgroundViewClass;
-(id)contentScrollView;
-(id)tableBackgroundColor;
-(void)loadView;
-(void)viewDidUnload;
-(id)_createGroupIndices:(id)indices;
-(void)createGroupIndices;
-(void)loseFocus;
-(void)reload;
-(void)reloadSpecifiers;
-(void)setSpecifierID:(id)anId;
-(id)specifierID;
-(void)setTitle:(id)title;
-(int)numberOfSectionsInTableView:(id)tableView;
-(int)tableView:(id)view numberOfRowsInSection:(int)section;
-(id)cachedCellForSpecifier:(id)specifier;
-(id)cachedCellForSpecifierID:(id)specifierID;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
-(float)tableView:(id)view heightForRowAtIndexPath:(id)indexPath;
-(id)tableView:(id)view titleForHeaderInSection:(int)section;
-(id)tableView:(id)view detailTextForHeaderInSection:(int)section;
-(id)tableView:(id)view titleForFooterInSection:(int)section;
-(int)tableView:(id)view titleAlignmentForHeaderInSection:(int)section;
-(int)tableView:(id)view titleAlignmentForFooterInSection:(int)section;
-(id)_customViewForSpecifier:(id)specifier class:(Class)aClass isHeader:(BOOL)header;
-(float)_tableView:(id)view heightForCustomInSection:(int)section isHeader:(BOOL)header;
-(id)_tableView:(id)view viewForCustomInSection:(int)section isHeader:(BOOL)header;
-(float)tableView:(id)view heightForHeaderInSection:(int)section;
-(id)tableView:(id)view viewForHeaderInSection:(int)section;
-(float)tableView:(id)view heightForFooterInSection:(int)section;
-(id)tableView:(id)view viewForFooterInSection:(int)section;
-(void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
-(void)didRotateFromInterfaceOrientation:(int)interfaceOrientation;
-(void)viewWillAppear:(BOOL)view;
-(BOOL)shouldSelectResponderOnAppearance;
-(id)findFirstVisibleResponder;
-(void)viewDidLoad;
-(void)prepareSpecifiersMetadata;
-(void)viewDidAppear:(BOOL)view;
-(void)formSheetViewWillDisappear;
-(void)popupViewWillDisappear;
-(void)returnPressedAtEnd;
-(void)_returnKeyPressed:(id)pressed;
-(BOOL)performActionForSpecifier:(id)specifier;
-(BOOL)performCancelForSpecifier:(id)specifier;
-(void)showConfirmationViewForSpecifier:(id)specifier useAlert:(BOOL)alert swapAlertButtons:(BOOL)buttons;
-(void)showConfirmationViewForSpecifier:(id)specifier;
-(void)showConfirmationSheetForSpecifier:(id)specifier;
-(void)confirmationViewAcceptedForSpecifier:(id)specifier;
-(void)confirmationViewCancelledForSpecifier:(id)specifier;
-(void)alertView:(id)view clickedButtonAtIndex:(int)index;
-(void)actionSheet:(id)sheet clickedButtonAtIndex:(int)index;
-(id)controllerForRowAtIndexPath:(id)indexPath;
-(void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath;
-(PSSpecifier *)specifierForID:(id)anId;
-(void)pushController:(id)controller animate:(BOOL)animate;
-(BOOL)popoverControllerShouldDismissPopover:(id)popoverController;
-(void)popoverController:(id)controller animationCompleted:(int)completed;
-(void)dismissPopover;
-(void)dismissPopoverAnimated:(BOOL)animated;
-(void)pushController:(id)controller;
-(void)handleURL:(id)url;
-(void)reloadIconForSpecifierForBundle:(id)bundle;
-(float)_getKeyboardIntersectionHeight;
-(void)_setContentInset:(float)inset;
-(void)_keyboardWillShow:(id)_keyboard;
-(void)_keyboardWillHide:(id)_keyboard;
-(void)_keyboardDidHide:(id)_keyboard;
-(void)selectRowForSpecifier:(id)specifier;
-(float)verticalContentOffset;
-(void)setDesiredVerticalContentOffset:(float)offset;
-(void)setDesiredVerticalContentOffsetItemNamed:(id)named;
-(BOOL)shouldReloadSpecifiersOnResume;
-(void)_setNotShowingSetupController;
@end

@interface PreferencesTableCell : NSObject {
	id _value;
	UIImageView* _checkedImageView;
	BOOL _checked;
	BOOL _shouldHideTitle;
	NSString* _hiddenTitle;
	int _alignment;
	SEL _pAction;
	id _pTarget;
	BOOL _cellEnabled;
	PSSpecifier* _specifier;
	int _type;
	BOOL _lazyIcon;
	BOOL _lazyIconDontUnload;
	BOOL _lazyIconForceSynchronous;
	NSString* _lazyIconAppID;
}
@property(retain, nonatomic) PSSpecifier* specifier;
@property(assign, nonatomic) int type;
-(id)initWithStyle:(int)style reuseIdentifier:(id)identifier;
-(void)dealloc;
-(id)getLazyIcon;
-(id)blankIcon;
-(void)forceSynchronousIconLoadOnNextIconLoad;
-(void)willMoveToSuperview:(id)superview;
-(void)didMoveToSuperview;
-(id)getIcon;
-(id)title;
-(void)setTitle:(id)title;
-(void)setShouldHideTitle:(BOOL)hideTitle;
-(void)setChecked:(BOOL)checked;
-(BOOL)isChecked;
-(void)setIcon:(id)icon;
-(void)setValue:(id)value;
-(id)value;
-(id)titleLabel;
-(id)valueLabel;
-(id)iconImageView;
-(void)setAlignment:(int)alignment;
-(void)layoutSubviews;
-(void)setTarget:(id)target;
-(id)target;
-(void)setAction:(SEL)action;
-(SEL)action;
-(void)setCellEnabled:(BOOL)enabled;
-(BOOL)cellEnabled;
-(BOOL)canReload;
-(void)reloadWithSpecifier:(id)specifier;
-(void)refreshCellContentsWithSpecifier:(id)specifier;
@end

@interface PSTableCell : PreferencesTableCell {
	UIView* _topEtchLine;
	UIView* _bottomEtchLine;
	BOOL _etch;
}
+(int)cellTypeFromString:(id)string;
+(id)_cellForSpecifier:(id)specifier defaultClass:(Class)aClass type:(int)type;
+(void)refreshSwitchCellContentsWithSpecifier:(id)specifier andCell:(id)cell;
+(id)switchCellWithSpecifier:(id)specifier;
+(id)segmentCellWithSpecifier:(id)specifier;
+(void)refreshSliderCellContentsWithSpecifier:(id)specifier andCell:(id)cell;
+(id)sliderCellWithSpecifier:(id)specifier;
+(void)refreshTextFieldCellContentsWithSpecifier:(id)specifier andCell:(id)cell;
+(id)textFieldCellWithSpecifier:(id)specifier;
+(id)textViewCellWithSpecifier:(id)specifier;
+(id)spinnerCellWithSpecifier:(id)specifier;
+(id)groupHeaderCellWithSpecifier:(id)specifier;
+(void)refreshCellContentsWithSpecifier:(id)specifier andCell:(id)cell;
+(id)cellWithSpecifier:(id)specifier;
+(id)topEtchLineView;
+(id)bottomEtchLineView;
-(void)layoutSubviews;
-(void)setValueChangedTarget:(id)target action:(SEL)action specifier:(id)specifier;
-(id)titleTextLabel;
-(id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier;
-(void)_updateEtchState:(BOOL)state;
-(void)setSelected:(BOOL)selected animated:(BOOL)animated;
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
-(void)setIcon:(id)icon;
-(void)dealloc;
-(BOOL)canReload;
-(void)refreshCellContentsWithSpecifier:(id)specifier;
@end

#if 0
/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/Preferences.framework/Preferences
 */

@protocol PSViewControllerOffsetProtocol
-(void)setDesiredVerticalContentOffset:(float)offset;
-(void)setDesiredVerticalContentOffsetItemNamed:(id)named;
-(float)verticalContentOffset;
@end

@protocol PSController <NSObject>
-(void)setParentController:(id)controller;
-(id)parentController;
-(void)setRootController:(id)controller;
-(id)rootController;
-(void)setSpecifier:(id)specifier;
-(id)specifier;
-(void)suspend;
-(void)didLock;
-(void)willUnlock;
-(void)didUnlock;
-(void)didWake;
-(void)pushController:(id)controller;
-(void)handleURL:(id)url;
-(void)setPreferenceValue:(id)value specifier:(id)specifier;
-(id)readPreferenceValue:(id)value;
-(void)willResignActive;
-(void)willBecomeActive;
-(BOOL)canBeShownFromSuspendedState;
-(void)statusBarWillAnimateByHeight:(float)statusBar;
@end

@protocol PreferencesTableCustomView
-(id)initWithSpecifier:(id)specifier;
@optional
-(float)preferredHeightForWidth:(float)width;
-(float)preferredHeightForWidth:(float)width inTableView:(id)tableView;
@end

@interface PSSpecifier : NSObject {
	id target;
	SEL getter;
	SEL setter;
	SEL action;
	SEL cancel;
	Class detailControllerClass;
	int cellType;
	Class editPaneClass;
	int keyboardType;
	int autoCapsType;
	int autoCorrectionType;
	int textFieldType;
	NSString* _name;
	NSArray* _values;
	NSDictionary* _titleDict;
	NSDictionary* _shortTitleDict;
	id _userInfo;
	NSMutableDictionary* _properties;
}
@property(assign, nonatomic) id target;
@property(assign, nonatomic) Class detailControllerClass;
@property(assign, nonatomic) int cellType;
@property(assign, nonatomic) Class editPaneClass;
@property(retain, nonatomic) id userInfo;
@property(retain, nonatomic) NSDictionary* titleDictionary;
@property(retain, nonatomic) NSDictionary* shortTitleDictionary;
@property(retain, nonatomic) NSArray* values;
@property(retain, nonatomic) NSString* name;
@property(retain, nonatomic) NSString* identifier;
+(id)preferenceSpecifierNamed:(id)named target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(int)cell edit:(Class)edit;
+(id)groupSpecifierWithName:(id)name;
+(id)emptyGroupSpecifier;
+(int)autoCorrectionTypeForNumber:(id)number;
+(int)autoCapsTypeForString:(id)string;
+(int)keyboardTypeForString:(id)string;
-(id)init;
-(id)propertyForKey:(id)key;
-(void)setProperty:(id)property forKey:(id)key;
-(void)removePropertyForKey:(id)key;
-(void)setProperties:(id)properties;
-(id)properties;
-(void)loadValuesAndTitlesFromDataSource;
-(void)setValues:(id)values titles:(id)titles;
-(void)setValues:(id)values titles:(id)titles shortTitles:(id)titles3;
-(void)setupIconImageWithBundle:(id)bundle;
-(void)setupIconImageWithPath:(id)path;
-(void)dealloc;
-(id)description;
-(void)setKeyboardType:(int)type autoCaps:(int)caps autoCorrection:(int)correction;
-(int)titleCompare:(id)compare;
@end

@interface PSRootController : NSObject <PSController, UINavigationControllerDelegate> {
	PSSpecifier* _specifier;
	NSMutableSet* _tasks;
	BOOL _deallocating;
	unsigned char _hasTelephony;
}
+(void)writePreference:(id)preference;
+(void)setPreferenceValue:(id)value specifier:(id)specifier;
+(id)readPreferenceValue:(id)value;
+(BOOL)processedBundle:(id)bundle parentController:(id)controller parentSpecifier:(id)specifier bundleControllers:(id*)controllers settings:(id)settings;
-(void)setPreferenceValue:(id)value specifier:(id)specifier;
-(id)readPreferenceValue:(id)value;
-(id)initWithTitle:(id)title identifier:(id)identifier;
-(id)tasksDescription;
-(BOOL)taskIsRunning:(id)running;
-(void)addTask:(id)task;
-(void)taskFinished:(id)finished;
-(BOOL)busy;
-(id)contentViewForTopController;
-(id)specifiers;
-(void)statusBarWillAnimateByHeight:(float)statusBar;
-(void)setParentController:(id)controller;
-(void)setSpecifier:(id)specifier;
-(id)specifier;
-(void)pushController:(id)controller;
-(void)handleURL:(id)url;
-(void)showLeftButton:(id)button withStyle:(int)style rightButton:(id)button3 withStyle:(int)style4;
-(void)statusBarWillChangeHeight:(id)statusBar;
-(void)willResignActive;
-(void)willBecomeActive;
-(void)sendWillResignActive;
-(void)sendWillBecomeActive;
-(void)suspend;
-(void)didLock;
-(void)willUnlock;
-(void)didUnlock;
-(void)didWake;
-(BOOL)deallocating;
-(void)dealloc;
-(id)parentController;
-(void)lazyLoadBundle:(id)bundle;
-(void)setRootController:(id)controller;
-(id)rootController;
-(void)willDismissPopupView;
-(void)didDismissPopupView;
-(void)willDismissFormSheetView;
-(void)didDismissFormSheetView;
-(BOOL)canBeShownFromSuspendedState;
-(void)_delayedControllerReleaseAfterPop:(id)pop;
-(id)popViewControllerAnimated:(BOOL)animated;
-(id)popToViewController:(id)viewController animated:(BOOL)animated;
-(id)popToRootViewControllerAnimated:(BOOL)rootViewControllerAnimated;
-(void)setViewControllers:(id)controllers animated:(BOOL)animated;
-(void)navigationController:(id)controller willShowViewController:(id)controller2 animated:(BOOL)animated;
@end

@interface PSViewController : NSObject <PSController> {
	UIViewController<PSController>* _parentController;
	PSRootController* _rootController;
	PSSpecifier* _specifier;
}
-(void)setParentController:(id)controller;
-(id)parentController;
-(void)setRootController:(id)controller;
-(id)rootController;
-(void)dealloc;
-(void)setSpecifier:(id)specifier;
-(id)specifier;
-(void)setPreferenceValue:(id)value specifier:(id)specifier;
-(id)readPreferenceValue:(id)value;
-(void)willResignActive;
-(void)willBecomeActive;
-(void)suspend;
-(void)didLock;
-(void)willUnlock;
-(void)didUnlock;
-(void)didWake;
-(void)pushController:(id)controller;
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation;
-(void)handleURL:(id)url;
-(id)methodSignatureForSelector:(SEL)selector;
-(void)forwardInvocation:(id)invocation;
-(void)popupViewWillDisappear;
-(void)popupViewDidDisappear;
-(void)formSheetViewWillDisappear;
-(void)formSheetViewDidDisappear;
-(BOOL)canBeShownFromSuspendedState;
-(void)statusBarWillAnimateByHeight:(float)statusBar;
@end

@interface PSListController : PSViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate, PSViewControllerOffsetProtocol> {
	NSMutableDictionary* _cells;
	BOOL _cachesCells;
	BOOL _forceSynchronousIconLoadForCreatedCells;
	UITableView* _table;
	NSArray* _specifiers;
	NSMutableDictionary* _specifiersByID;
	NSMutableArray* _groups;
	NSString* _specifierID;
	NSMutableArray* _bundleControllers;
	BOOL _bundlesLoaded;
	BOOL _showingSetupController;
	UIActionSheet* _actionSheet;
	UIAlertView* _alertView;
	BOOL _swapAlertButtons;
	BOOL _keyboardWasVisible;
	//UIKeyboard* _keyboard;
	UIPopoverController* _popupStylePopoverController;
	BOOL _popupStylePopoverShouldRePresent;
	BOOL _popupIsModal;
	BOOL _popupIsDismissing;
	BOOL _hasAppeared;
	float _verticalContentOffset;
	NSString* _offsetItemName;
	CGPoint _contentOffsetWithKeyboard;
}
@property(assign, nonatomic) BOOL forceSynchronousIconLoadForCreatedCells;
+(BOOL)displaysButtonBar;
-(void)clearCache;
-(void)setCachesCells:(BOOL)cells;
-(id)description;
-(id)table;
-(id)bundle;
-(id)specifier;
-(id)loadSpecifiersFromPlistName:(id)plistName target:(id)target;
-(id)specifiers;
-(void)_addIdentifierForSpecifier:(id)specifier;
-(void)_removeIdentifierForSpecifier:(id)specifier;
-(void)setSpecifiers:(id)specifiers;
-(id)indexPathForIndex:(int)index;
-(int)indexForIndexPath:(id)indexPath;
-(void)beginUpdates;
-(void)endUpdates;
-(void)reloadSpecifierAtIndex:(int)index animated:(BOOL)animated;
-(void)reloadSpecifierAtIndex:(int)index;
-(void)reloadSpecifier:(id)specifier animated:(BOOL)animated;
-(void)reloadSpecifier:(id)specifier;
-(void)reloadSpecifierID:(id)anId animated:(BOOL)animated;
-(void)reloadSpecifierID:(id)anId;
-(int)indexOfSpecifierID:(id)specifierID;
-(int)indexOfSpecifier:(id)specifier;
-(BOOL)containsSpecifier:(id)specifier;
-(int)indexOfGroup:(int)group;
-(int)numberOfGroups;
-(id)specifierAtIndex:(int)index;
-(BOOL)getGroup:(int*)group row:(int*)row ofSpecifierID:(id)specifierID;
-(BOOL)getGroup:(int*)group row:(int*)row ofSpecifier:(id)specifier;
-(BOOL)_getGroup:(int*)group row:(int*)row ofSpecifierAtIndex:(int)index groups:(id)groups;
-(BOOL)getGroup:(int*)group row:(int*)row ofSpecifierAtIndex:(int)index;
-(int)indexForRow:(int)row inGroup:(int)group;
-(int)rowsForGroup:(int)group;
-(id)specifiersInGroup:(int)group;
-(void)insertSpecifier:(id)specifier atIndex:(int)index animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier afterSpecifier:(id)specifier2 animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier afterSpecifierID:(id)anId animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier atEndOfGroup:(int)group animated:(BOOL)animated;
-(void)insertSpecifier:(id)specifier atIndex:(int)index;
-(void)insertSpecifier:(id)specifier afterSpecifier:(id)specifier2;
-(void)insertSpecifier:(id)specifier afterSpecifierID:(id)anId;
-(void)insertSpecifier:(id)specifier atEndOfGroup:(int)group;
-(void)_insertContiguousSpecifiers:(id)specifiers atIndex:(int)index animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers atIndex:(int)index animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifier:(id)specifier animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifierID:(id)anId animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers atEndOfGroup:(int)group animated:(BOOL)animated;
-(void)insertContiguousSpecifiers:(id)specifiers atIndex:(int)index;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifier:(id)specifier;
-(void)insertContiguousSpecifiers:(id)specifiers afterSpecifierID:(id)anId;
-(void)insertContiguousSpecifiers:(id)specifiers atEndOfGroup:(int)group;
-(void)addSpecifier:(id)specifier;
-(void)addSpecifier:(id)specifier animated:(BOOL)animated;
-(void)addSpecifiersFromArray:(id)array;
-(void)addSpecifiersFromArray:(id)array animated:(BOOL)animated;
-(void)removeSpecifier:(id)specifier animated:(BOOL)animated;
-(void)removeSpecifierID:(id)anId animated:(BOOL)animated;
-(void)removeSpecifierAtIndex:(int)index animated:(BOOL)animated;
-(void)removeSpecifier:(id)specifier;
-(void)removeSpecifierID:(id)anId;
-(void)removeSpecifierAtIndex:(int)index;
-(void)removeLastSpecifier;
-(void)removeLastSpecifierAnimated:(BOOL)animated;
-(void)_removeContiguousSpecifiers:(id)specifiers animated:(BOOL)animated;
-(void)removeContiguousSpecifiers:(id)specifiers animated:(BOOL)animated;
-(void)removeContiguousSpecifiers:(id)specifiers;
-(void)replaceContiguousSpecifiers:(id)specifiers withSpecifiers:(id)specifiers2;
-(void)replaceContiguousSpecifiers:(id)specifiers withSpecifiers:(id)specifiers2 animated:(BOOL)animated;
-(int)_nextGroupInSpecifiersAfterIndex:(int)specifiersAfterIndex inArray:(id)array;
-(void)updateSpecifiers:(id)specifiers withSpecifiers:(id)specifiers2;
-(void)updateSpecifiersInRange:(NSRange)range withSpecifiers:(id)specifiers;
-(void)_loadBundleControllers;
-(void)_unloadBundleControllers;
-(void)dealloc;
-(id)init;
-(id)initForContentSize:(CGSize)contentSize;
-(Class)tableViewClass;
-(int)tableStyle;
-(Class)backgroundViewClass;
-(id)contentScrollView;
-(id)tableBackgroundColor;
-(void)loadView;
-(void)viewDidUnload;
-(id)_createGroupIndices:(id)indices;
-(void)createGroupIndices;
-(void)loseFocus;
-(void)reload;
-(void)reloadSpecifiers;
-(void)setSpecifierID:(id)anId;
-(id)specifierID;
-(void)setTitle:(id)title;
-(int)numberOfSectionsInTableView:(id)tableView;
-(int)tableView:(id)view numberOfRowsInSection:(int)section;
-(id)cachedCellForSpecifier:(id)specifier;
-(id)cachedCellForSpecifierID:(id)specifierID;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
-(float)tableView:(id)view heightForRowAtIndexPath:(id)indexPath;
-(id)tableView:(id)view titleForHeaderInSection:(int)section;
-(id)tableView:(id)view detailTextForHeaderInSection:(int)section;
-(id)tableView:(id)view titleForFooterInSection:(int)section;
-(int)tableView:(id)view titleAlignmentForHeaderInSection:(int)section;
-(int)tableView:(id)view titleAlignmentForFooterInSection:(int)section;
-(id)_customViewForSpecifier:(id)specifier class:(Class)aClass isHeader:(BOOL)header;
-(float)_tableView:(id)view heightForCustomInSection:(int)section isHeader:(BOOL)header;
-(id)_tableView:(id)view viewForCustomInSection:(int)section isHeader:(BOOL)header;
-(float)tableView:(id)view heightForHeaderInSection:(int)section;
-(id)tableView:(id)view viewForHeaderInSection:(int)section;
-(float)tableView:(id)view heightForFooterInSection:(int)section;
-(id)tableView:(id)view viewForFooterInSection:(int)section;
-(void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
-(void)didRotateFromInterfaceOrientation:(int)interfaceOrientation;
-(void)viewWillAppear:(BOOL)view;
-(BOOL)shouldSelectResponderOnAppearance;
-(id)findFirstVisibleResponder;
-(void)viewDidLoad;
-(void)prepareSpecifiersMetadata;
-(void)viewDidAppear:(BOOL)view;
-(void)formSheetViewWillDisappear;
-(void)popupViewWillDisappear;
-(void)returnPressedAtEnd;
-(void)_returnKeyPressed:(id)pressed;
-(BOOL)performActionForSpecifier:(id)specifier;
-(BOOL)performCancelForSpecifier:(id)specifier;
-(void)showConfirmationViewForSpecifier:(id)specifier useAlert:(BOOL)alert swapAlertButtons:(BOOL)buttons;
-(void)showConfirmationViewForSpecifier:(id)specifier;
-(void)showConfirmationSheetForSpecifier:(id)specifier;
-(void)confirmationViewAcceptedForSpecifier:(id)specifier;
-(void)confirmationViewCancelledForSpecifier:(id)specifier;
-(void)alertView:(id)view clickedButtonAtIndex:(int)index;
-(void)actionSheet:(id)sheet clickedButtonAtIndex:(int)index;
-(id)controllerForRowAtIndexPath:(id)indexPath;
-(void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath;
-(id)specifierForID:(id)anId;
-(void)pushController:(id)controller animate:(BOOL)animate;
-(BOOL)popoverControllerShouldDismissPopover:(id)popoverController;
-(void)popoverController:(id)controller animationCompleted:(int)completed;
-(void)dismissPopover;
-(void)dismissPopoverAnimated:(BOOL)animated;
-(void)pushController:(id)controller;
-(void)handleURL:(id)url;
-(void)reloadIconForSpecifierForBundle:(id)bundle;
-(float)_getKeyboardIntersectionHeight;
-(void)_setContentInset:(float)inset;
-(void)_keyboardWillShow:(id)_keyboard;
-(void)_keyboardWillHide:(id)_keyboard;
-(void)_keyboardDidHide:(id)_keyboard;
-(void)selectRowForSpecifier:(id)specifier;
-(float)verticalContentOffset;
-(void)setDesiredVerticalContentOffset:(float)offset;
-(void)setDesiredVerticalContentOffsetItemNamed:(id)named;
-(BOOL)shouldReloadSpecifiersOnResume;
-(void)_setNotShowingSetupController;
@end

@interface PSConfirmationSpecifier : PSSpecifier {
	NSString* _title;
	NSString* _prompt;
	NSString* _okButton;
	NSString* _cancelButton;
}
@property(retain, nonatomic) NSString* title;
@property(retain, nonatomic) NSString* prompt;
@property(retain, nonatomic) NSString* okButton;
@property(retain, nonatomic) NSString* cancelButton;
+(id)preferenceSpecifierNamed:(id)named target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(int)cell edit:(Class)edit;
-(void)setupWithDictionary:(id)dictionary;
-(BOOL)isDestructive;
-(void)dealloc;
@end

@interface PSTextFieldSpecifier : PSSpecifier {
	SEL bestGuess;
@private
	NSString* _placeholder;
}
+(id)preferenceSpecifierNamed:(id)named target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(int)cell edit:(Class)edit;
-(void)dealloc;
-(void)setPlaceholder:(id)placeholder;
-(id)placeholder;
@end

@interface PSListItemsController : PSListController {
	int _rowToSelect;
	BOOL _deferItemSelection;
	BOOL _restrictionList;
	PSSpecifier* _lastSelectedSpecifier;
}
-(void)viewWillAppear:(BOOL)view;
-(void)scrollToSelectedCell;
-(void)setRowToSelect;
-(void)setValueForSpecifier:(id)specifier defaultValue:(id)value;
-(void)dealloc;
-(void)viewWillDisappear:(BOOL)view;
-(void)suspend;
-(void)didLock;
-(void)prepareSpecifiersMetadata;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
-(void)listItemSelected:(id)selected;
-(void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath;
-(void)_addStaticText:(id)text;
-(id)itemsFromParent;
-(id)itemsFromDataSource;
-(id)specifiers;
-(BOOL)isRestrictionList;
-(void)setIsRestrictionList:(BOOL)list;
@end

@interface PSSpinnerTableCell : PSTableCell {
@private
	UIActivityIndicatorView* _spinner;
}
-(id)initWithStyle:(int)style reuseIdentifier:(id)identifier;
-(void)layoutSubviews;
-(void)dealloc;
@end

@interface PSTextViewTableCell : PSTableCell <UITextViewDelegate> {
	PSTextView* _textView;
}
-(void)setValue:(id)value;
-(void)textViewDidEndEditing:(id)textView;
-(BOOL)becomeFirstResponder;
-(BOOL)canBecomeFirstResponder;
-(BOOL)resignFirstResponder;
-(id)textView;
-(void)setTextView:(id)view;
-(void)drawTitleInRect:(CGRect)rect selected:(BOOL)selected;
@end

@interface PSTextView : NSObject {
	PSTextViewTableCell* _cell;
}
-(void)setCell:(id)cell;
@end

@interface PSImageCell : PSTableCell {
	UIImageView* _imageViewDeprecated;
}
-(void)setImageView:(id)view;
-(void)drawTitleInRect:(CGRect)rect selected:(BOOL)selected;
@end

@interface PSEditableTableCell : PreferencesTextTableCell {
	SEL _targetSetter;
	id _realTarget;
	BOOL _valueChanged;
}
-(void)refreshCellContentsWithSpecifier:(id)specifier;
-(BOOL)canReload;
-(void)controlChanged:(id)changed;
-(void)_setValueChanged;
-(void)_saveForExit;
-(void)textFieldDidBeginEditing:(id)textField;
-(void)textFieldDidEndEditing:(id)textField;
-(BOOL)textFieldShouldReturn:(id)textField;
-(void)setValueChangedTarget:(id)target action:(SEL)action specifier:(id)specifier;
-(void)dealloc;
@end

@interface PSControlTableCell : PSTableCell {
	UIControl* _control;
	UIActivityIndicatorView* _activityIndicator;
	NSArray* _values;
	NSDictionary* _titleDict;
	UIView* _disabledView;
}
-(void)refreshCellContentsWithSpecifier:(id)specifier;
-(BOOL)canReload;
-(void)setCellEnabled:(BOOL)enabled;
-(void)setValues:(id)values titleDictionary:(id)dictionary;
-(void)setBackgroundView:(id)view;
-(id)titleLabel;
-(id)valueLabel;
-(void)dealloc;
-(id)control;
-(BOOL)loading;
-(void)setLoading:(BOOL)loading;
-(void)setControl:(id)control;
-(void)controlChanged:(id)changed;
-(void)setValue:(id)value;
-(void)layoutSubviews;
@end

@interface PSTableCell : PreferencesTableCell {
	UIView* _topEtchLine;
	UIView* _bottomEtchLine;
	BOOL _etch;
}
+(int)cellTypeFromString:(id)string;
+(id)_cellForSpecifier:(id)specifier defaultClass:(Class)aClass type:(int)type;
+(void)refreshSwitchCellContentsWithSpecifier:(id)specifier andCell:(id)cell;
+(id)switchCellWithSpecifier:(id)specifier;
+(id)segmentCellWithSpecifier:(id)specifier;
+(void)refreshSliderCellContentsWithSpecifier:(id)specifier andCell:(id)cell;
+(id)sliderCellWithSpecifier:(id)specifier;
+(void)refreshTextFieldCellContentsWithSpecifier:(id)specifier andCell:(id)cell;
+(id)textFieldCellWithSpecifier:(id)specifier;
+(id)textViewCellWithSpecifier:(id)specifier;
+(id)spinnerCellWithSpecifier:(id)specifier;
+(id)groupHeaderCellWithSpecifier:(id)specifier;
+(void)refreshCellContentsWithSpecifier:(id)specifier andCell:(id)cell;
+(id)cellWithSpecifier:(id)specifier;
+(id)topEtchLineView;
+(id)bottomEtchLineView;
-(void)layoutSubviews;
-(void)setValueChangedTarget:(id)target action:(SEL)action specifier:(id)specifier;
-(id)titleTextLabel;
-(id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier;
-(void)_updateEtchState:(BOOL)state;
-(void)setSelected:(BOOL)selected animated:(BOOL)animated;
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
-(void)setIcon:(id)icon;
-(void)dealloc;
-(BOOL)canReload;
-(void)refreshCellContentsWithSpecifier:(id)specifier;
@end

@interface PSDetailController : PSViewController {
	PSEditingPane* _pane;
}
@property(assign, nonatomic) PSEditingPane* pane;
-(void)loadView;
-(void)viewDidUnload;
-(void)dealloc;
-(CGRect)paneFrame;
-(void)willRotateToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
-(void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
-(void)didRotateFromInterfaceOrientation:(int)interfaceOrientation;
-(void)viewWillAppear:(BOOL)view;
-(void)viewDidAppear:(BOOL)view;
-(void)saveChanges;
-(void)suspend;
-(void)viewWillDisappear:(BOOL)view;
-(void)statusBarWillAnimateByHeight:(float)statusBar;
@end

@interface PSTextEditingPane : PSEditingPane <UITableViewDelegate, UITableViewDataSource> {
	UITableView* _table;
	PreferencesTextTableCell* _cell;
	UITextField* _textField;
}
-(id)initWithFrame:(CGRect)frame;
-(void)dealloc;
-(void)layoutSubviews;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
-(int)tableView:(id)view numberOfRowsInSection:(int)section;
-(BOOL)becomeFirstResponder;
-(void)setPreferenceValue:(id)value;
-(id)preferenceValue;
-(void)setPreferenceSpecifier:(id)specifier;
@end

@interface PSEditingPane : NSObject {
	PSSpecifier* _specifier;
	id _delegate;
	unsigned _requiresKeyboard : 1;
	CGRect _pinstripeRect;
	UIView* _pinstripeView;
}
@property(assign, nonatomic) CGRect pinstripeRect;
+(id)defaultBackgroundColor;
+(float)preferredHeight;
-(id)initWithFrame:(CGRect)frame;
-(CGRect)contentRect;
-(void)dealloc;
-(void)setDelegate:(id)delegate;
-(void)setPreferenceSpecifier:(id)specifier;
-(id)preferenceSpecifier;
-(void)setPreferenceValue:(id)value;
-(id)preferenceValue;
-(BOOL)requiresKeyboard;
-(id)specifierLabel;
-(BOOL)wantsNewButton;
-(void)viewDidBecomeVisible;
-(void)addNewValue;
-(void)editMode;
-(void)doneEditing;
-(BOOL)handlesDoneButton;
-(BOOL)changed;
-(void)willRotateToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
-(void)willAnimateRotationToInterfaceOrientation:(int)interfaceOrientation duration:(double)duration;
-(void)didRotateFromInterfaceOrientation:(int)interfaceOrientation;
@end

@interface PSSetupController : PSRootController {
	NSDictionary* _rootInfo;
	UIViewController<PSController>* _parentController;
	PSRootController* _parentRootController;
}
-(id)init;
-(void)dealloc;
-(void)handleURL:(id)url;
-(id)parentController;
-(void)setupController;
-(void)viewWillDisappear:(BOOL)view;
-(void)viewDidDisappear:(BOOL)view;
-(void)pushController:(id)controller;
-(void)setParentController:(id)controller;
-(id)controller;
-(void)dismiss;
-(void)dismissAnimated:(BOOL)animated;
-(void)pushControllerOnParentWithSpecifier:(id)specifier;
-(void)popControllerOnParent;
-(id)methodSignatureForSelector:(SEL)selector;
-(void)forwardInvocation:(id)invocation;
-(BOOL)usePopupStyle;
-(BOOL)popupStyleIsModal;
-(void)statusBarWillChangeHeight:(id)statusBar;
@end

@interface PSEditableListController : PSListController {
	BOOL _editable;
}
-(id)init;
-(id)_editButtonBarItem;
-(void)_updateNavigationBar;
-(void)setEditingButtonHidden:(BOOL)hidden animated:(BOOL)animated;
-(BOOL)_showEditButtonUponAppearing;
-(void)viewWillAppear:(BOOL)view;
-(void)pushController:(id)controller;
-(void)editDoneTapped;
-(BOOL)editable;
-(void)_setEditable:(BOOL)editable animated:(BOOL)animated;
-(void)setEditable:(BOOL)editable;
-(id)tableView:(id)view willSelectRowAtIndexPath:(id)indexPath;
-(int)tableView:(id)view editingStyleForRowAtIndexPath:(id)indexPath;
-(BOOL)performDeletionActionForSpecifier:(id)specifier;
-(void)suspend;
-(void)didLock;
-(void)tableView:(id)view commitEditingStyle:(int)style forRowAtIndexPath:(id)indexPath;
@end

@interface PSBundleController : NSObject {
	PSListController* _parent;
}
-(void)load;
-(void)unload;
-(id)specifiersWithSpecifier:(id)specifier;
-(id)initWithParentListController:(id)parentListController;
@end

@interface PSSystemConfiguration : NSObject {
	SCPreferencesRef _prefs;
}
+(id)sharedInstance;
+(void)releaseSharedInstance;
-(id)init;
-(void)dealloc;
-(unsigned char)lockAndSynchronize;
-(CFStringRef)dataServiceID;
-(CFStringRef)voicemailServiceID;
-(CFStringRef)getServiceIDForPDPContext:(unsigned)pdpcontext;
-(id)interfaceConfigurationValueForKey:(CFStringRef)key serviceID:(CFStringRef)anId;
-(void)setInterfaceConfigurationValue:(id)value forKey:(CFStringRef)key serviceID:(CFStringRef)anId;
-(id)protocolConfiguration:(CFStringRef)configuration serviceID:(CFStringRef)anId;
-(void)setProtocolConfiguration:(id)configuration protocolType:(CFStringRef)type serviceID:(CFStringRef)anId;
-(id)protocolConfigurationValueForKey:(CFStringRef)key protocolType:(CFStringRef)type serviceID:(CFStringRef)anId;
-(void)setProtocolConfigurationValue:(id)value forKey:(CFStringRef)key protocolType:(CFStringRef)type serviceID:(CFStringRef)anId;
@end

@interface PreferencesTextTableCell : PreferencesTableCell <UITextViewDelegate, UITextFieldDelegate> {
	UIColor* _textColor;
	id _delegate;
	BOOL _forceFirstResponder;
}
-(id)initWithStyle:(int)style reuseIdentifier:(id)identifier;
-(void)dealloc;
-(void)setCellEnabled:(BOOL)enabled;
-(void)setTitle:(id)title;
-(void)setDelegate:(id)delegate;
-(void)layoutSubviews;
-(BOOL)canBecomeFirstResponder;
-(BOOL)canResignFirstResponder;
-(BOOL)isFirstResponder;
-(BOOL)becomeFirstResponder;
-(BOOL)resignFirstResponder;
-(BOOL)isEditing;
-(id)value;
-(void)setValue:(id)value;
-(void)setPlaceholderText:(id)text;
-(id)textField;
@end

@interface PreferencesTableCell : NSObject {
	id _value;
	UIImageView* _checkedImageView;
	BOOL _checked;
	BOOL _shouldHideTitle;
	NSString* _hiddenTitle;
	int _alignment;
	SEL _pAction;
	id _pTarget;
	BOOL _cellEnabled;
	PSSpecifier* _specifier;
	int _type;
	BOOL _lazyIcon;
	BOOL _lazyIconDontUnload;
	BOOL _lazyIconForceSynchronous;
	NSString* _lazyIconAppID;
}
@property(retain, nonatomic) PSSpecifier* specifier;
@property(assign, nonatomic) int type;
-(id)initWithStyle:(int)style reuseIdentifier:(id)identifier;
-(void)dealloc;
-(id)getLazyIcon;
-(id)blankIcon;
-(void)forceSynchronousIconLoadOnNextIconLoad;
-(void)willMoveToSuperview:(id)superview;
-(void)didMoveToSuperview;
-(id)getIcon;
-(id)title;
-(void)setTitle:(id)title;
-(void)setShouldHideTitle:(BOOL)hideTitle;
-(void)setChecked:(BOOL)checked;
-(BOOL)isChecked;
-(void)setIcon:(id)icon;
-(void)setValue:(id)value;
-(id)value;
-(id)titleLabel;
-(id)valueLabel;
-(id)iconImageView;
-(void)setAlignment:(int)alignment;
-(void)layoutSubviews;
-(void)setTarget:(id)target;
-(id)target;
-(void)setAction:(SEL)action;
-(SEL)action;
-(void)setCellEnabled:(BOOL)enabled;
-(BOOL)cellEnabled;
-(BOOL)canReload;
-(void)reloadWithSpecifier:(id)specifier;
-(void)refreshCellContentsWithSpecifier:(id)specifier;
@end

@interface PSSplitViewController : NSObject {
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation;
@end

@interface DevicePINSetupController : PSSetupController {
	BOOL _success;
}
-(BOOL)success;
-(BOOL)usePopupStyle;
-(BOOL)popupStyleIsModal;
-(BOOL)canBeShownFromSuspendedState;
@end

@interface DevicePINController : PSDetailController {
	int _mode;
	int _substate;
	NSString* _oldPassword;
	NSString* _lastEntry;
	BOOL _success;
	id _pinDelegate;
	UIBarButtonItem* _cancelButton;
	UIBarButtonItem* _nextButton;
	UIBarButtonItem* _doneButton;
	NSString* _error1;
	NSString* _error2;
}
+(BOOL)settingEnabled;
-(void)willUnlock;
-(id)init;
-(void)setSpecifier:(id)specifier;
-(CGSize)contentSizeForViewInPopover;
-(void)_dismiss;
-(id)stringsTable;
-(void)dealloc;
-(void)setOldPassword:(id)password;
-(void)setLastEntry:(id)entry;
-(BOOL)pinIsAcceptable:(id)acceptable outError:(id*)error;
-(void)setPIN:(id)pin;
-(BOOL)validatePIN:(id)pin;
-(BOOL)useProgressiveDelays;
-(int)pinLength;
-(CFStringRef)defaultsID;
-(CFStringRef)failedAttemptsKey;
-(CFStringRef)blockTimeIntervalKey;
-(CFStringRef)blockedStateKey;
-(int)_getScreenType;
-(BOOL)requiresKeyboard;
-(BOOL)simplePIN;
-(int)_numberOfFailedAttempts;
-(void)_setNumberOfFailedAttempts:(int)failedAttempts;
-(void)_clearBlockedState;
-(double)_unblockTime;
-(BOOL)_isBlocked;
-(void)_setUnblockTime:(double)time;
-(BOOL)_attemptValidationWithPIN:(id)pin;
-(void)performActionAfterPINEntry;
-(void)performActionAfterPINSet;
-(void)performActionAfterPINRemove;
-(void)suspend;
-(void)_showFailedAttempts;
-(void)_updateErrorTextAndFailureCount:(BOOL)count;
-(void)_updateUI;
-(void)_showUnacceptablePINError:(id)error password:(id)password;
-(void)_showPINConfirmationError;
-(void)_updatePINButtons;
-(BOOL)completedInputIsValid:(id)valid;
-(void)viewWillLayoutSubviews;
-(void)_slidePasscodeField;
-(void)pinEntered:(id)entered;
-(void)cancelButtonTapped;
-(id)pinInstructionsPrompt;
-(id)pinInstructionsPromptFont;
-(void)viewWillAppear:(BOOL)view;
-(void)viewDidAppear:(BOOL)view;
-(CGRect)paneFrame;
-(void)setPane:(id)pane;
-(BOOL)_success;
@end

@interface AlphanumericPINView : PINView <UITableViewDataSource> {
	UITextField* _passcodeField;
	PreferencesTextTableCell* _cell;
	UITableView* _table;
}
-(id)initWithFrame:(CGRect)frame;
-(void)layoutSubviews;
-(int)tableView:(id)view numberOfRowsInSection:(int)section;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
-(void)setBlocked:(BOOL)blocked;
-(BOOL)keyboardInputChanged:(id)changed;
-(void)showError:(id)error animate:(BOOL)animate;
-(void)dealloc;
-(id)stringValue;
-(void)okButtonPressed:(id)pressed;
-(void)hidePasscodeField:(BOOL)field;
-(BOOL)isFirstResponder;
-(BOOL)canBecomeFirstResponder;
-(BOOL)becomeFirstResponder;
-(BOOL)resignFirstResponder;
-(void)setStringValue:(id)value;
-(void)appendString:(id)string;
-(void)deleteLastCharacter;
-(BOOL)textFieldShouldReturn:(id)textField;
@end

@interface NumericPINView : PINView {
	UIPasscodeField* _passcodeField;
}
-(id)initWithFrame:(CGRect)frame;
-(void)layoutSubviews;
-(void)hidePasscodeField:(BOOL)field;
-(id)stringValue;
-(void)setStringValue:(id)value;
-(void)deleteLastCharacter;
-(void)appendString:(id)string;
-(void)showFailedAttempts:(int)attempts;
@end

@interface PINView : NSObject <PINEntryView> {
	UILabel* _titleLabel;
	UILabel* _errorTitleLabel;
	FailureBarView* _failureView;
	UILabel* _pinPolicyLabel;
	BOOL _error;
	id _delegate;
}
-(void)showError:(id)error animate:(BOOL)animate;
-(void)hideError;
-(void)hidePasscodeField:(BOOL)field;
-(void)setTitle:(id)title font:(id)font;
-(id)stringValue;
-(void)setStringValue:(id)value;
-(void)deleteLastCharacter;
-(void)appendString:(id)string;
-(BOOL)becomeFirstResponder;
-(void)setDelegate:(id)delegate;
-(void)setPINPolicyString:(id)string visible:(BOOL)visible;
-(void)showFailedAttempts:(int)attempts;
-(void)layoutSubviews;
-(void)hideFailedAttempts;
-(void)dealloc;
-(void)setBlocked:(BOOL)blocked;
@end

@interface FailureBarView : NSObject {
	UILabel* _titleLabel;
}
-(id)initWithFrame:(CGRect)frame;
-(void)setFailureCount:(int)count;
@end

@interface DevicePINPane : PSEditingPane <UIKeyInput> {
	UITransitionView* _transitionView;
	BOOL _transitioning;
	UIView<PINEntryView>* _pinView;
	CGRect _pinViewFrame;
	UIKeyboard* _keypad;
	CGRect _keypadFrame;
	BOOL _keypadActive;
	int _autocapitalizationType;
	int _autocorrectionType;
	int _keyboardType;
	int _keyboardAppearance;
	BOOL _playSound;
	BOOL _isBlocked;
	BOOL _simplePIN;
}
@property(assign, nonatomic) int autocapitalizationType;
@property(assign, nonatomic) int autocorrectionType;
@property(assign, nonatomic) int keyboardType;
@property(assign, nonatomic) int keyboardAppearance;
@property(assign, nonatomic) int spellCheckingType;
@property(assign, nonatomic) int returnKeyType;
@property(assign, nonatomic) BOOL enablesReturnKeyAutomatically;
@property(assign, nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;
-(id)specifierLabel;
-(void)_setPlaysKeyboardClicks:(BOOL)clicks;
-(id)initWithFrame:(CGRect)frame;
-(void)dealloc;
-(void)activateKeypadView;
-(void)deactivateKeypadView;
-(void)showFailedAttempts:(int)attempts;
-(void)hideFailedAttempts;
-(void)setSimplePIN:(BOOL)pin requiresKeyboard:(BOOL)keyboard;
-(BOOL)simplePIN;
-(BOOL)requiresKeyboard;
-(void)_setKeypadState:(BOOL)state animated:(BOOL)animated;
-(void)dismissKeypad;
-(BOOL)canBecomeFirstResponder;
-(BOOL)becomeFirstResponder;
-(BOOL)resignFirstResponder;
-(void)showError:(id)error error:(id)error2 isBlocked:(BOOL)blocked animate:(BOOL)animate;
-(void)setPINPolicyString:(id)string visible:(BOOL)visible;
-(void)okButtonPressed;
-(void)hideError;
-(void)setTitle:(id)title;
-(void)slideToNewPasscodeField:(BOOL)newPasscodeField withKeyboard:(BOOL)keyboard;
-(void)transitionViewDidComplete:(id)transitionView;
-(id)password;
-(void)clearPassword;
-(id)text;
-(void)setText:(id)text;
-(BOOL)hasText;
-(void)insertText:(id)text;
-(void)deleteBackward;
-(void)pinView:(id)view pinEntered:(id)entered;
-(void)layoutSubviews;
@end

@interface DevicePINKeypad : NSObject {
}
-(BOOL)isMinimized;
-(void)setMinimized:(BOOL)minimized;
@end

@interface PSAppListController : PSListController {
}
-(id)_uiValueFromValue:(id)value specifier:(id)specifier;
-(id)_valueFromUIValue:(id)uivalue specifier:(id)specifier;
-(id)_readToggleSwitchSpecifierValue:(id)value;
-(void)_setToggleSwitchSpecifierValue:(id)value specifier:(id)specifier;
-(id)_localizedTitlesFromUnlocalizedTitles:(id)unlocalizedTitles stringsTable:(id)table;
-(void)postThirdPartySettingDidChangeNotificationForSpecifier:(id)postThirdPartySetting;
-(void)setPreferenceValue:(id)value specifier:(id)specifier;
-(id)groupSpecifierFromDictionary:(id)dictionary stringsTable:(id)table;
-(id)radioGroupSpecifiersFromDictionary:(id)dictionary stringsTable:(id)table;
-(id)textFieldSpecifierFromDictionary:(id)dictionary stringsTable:(id)table;
-(id)toggleSwitchSpecifierFromDictionary:(id)dictionary stringsTable:(id)table;
-(id)sliderSpecifierFromDictionary:(id)dictionary stringsTable:(id)table;
-(id)titleValueSpecifierFromDictionary:(id)dictionary stringsTable:(id)table;
-(id)multiValueSpecifierFromDictionary:(id)dictionary stringsTable:(id)table;
-(id)childPaneSpecifierFromDictionary:(id)dictionary stringsTable:(id)table;
-(id)specifiersFromDictionary:(id)dictionary stringsTable:(id)table;
-(id)specifiers;
-(void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath;
-(id)bundle;
@end

@interface PSGradientView : NSObject {
}
+(Class)layerClass;
-(id)initWithFrame:(CGRect)frame;
@end

@interface PSInternationalLanguageSetupController : PSSetupController {
	NSString* _languageToSet;
}
-(void)dealloc;
-(void)showBlackViewWithLabel:(id)label;
-(void)rotateView:(id)view toOrientation:(int)orientation;
-(void)commit;
-(void)didFinishCommit;
-(void)setLanguage:(id)language specifier:(id)specifier;
-(id)language:(id)language;
-(void)setupController;
@end

@interface PSInternationalLanguageController : PSListItemsController {
}
-(id)init;
-(void)_removeBlackFrame;
-(void)cancelButtonTapped;
-(void)doneButtonTapped;
-(void)updateNavigationItem;
-(void)viewWillAppear:(BOOL)view;
-(id)specifiers;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
@end

@interface PSLanguageSelector : NSObject {
	NSString* _language;
	NSMutableArray* _supportedLanguages;
	NSArray* _supportedKeyboards;
}
+(id)sharedInstance;
-(void)dealloc;
-(void)_setLanguage:(id)language;
-(BOOL)_adjustLanguageIndices;
-(void)_loadSupportedLanguages;
-(id)currentLanguage;
-(void)setLanguage:(id)language;
-(id)supportedLanguages;
@end

@interface PSLocaleController : PSListController {
	PSSpecifier* _checkedSpecifier;
	BOOL _firstAppearance;
}
-(void)localeChangedAction;
-(id)init;
-(void)dealloc;
-(void)updateChecked:(id)checked;
-(void)subcategorySelected:(id)selected specifier:(id)specifier;
-(void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath;
-(void)viewWillAppear:(BOOL)view;
-(void)addLanguage:(id)language toSupportedLanguages:(id)supportedLanguages;
-(id)specifiers;
-(id)locale:(id)locale;
-(void)setLocale:(id)locale specifier:(id)specifier;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
@end

@interface PopBackListItemsController : PSListItemsController {
}
-(void)listItemSelected:(id)selected;
-(void)prepareSpecifiersMetadata;
@end

@interface PSMovableListController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView* _tableView;
	CFArrayRef _ordering;
	CFSetRef _disabledDomains;
	BOOL _isDirty;
}
-(CFStringRef)reorderingKey;
-(CFStringRef)disabledKey;
-(CFStringRef)defaultDomain;
-(id)allDomainKeys;
-(int)domainForKey:(const id)key;
-(int)domainCount;
-(id)keyForDomain:(int)domain;
-(void)defaultOrdering;
-(void)removeUnwantedDomains;
-(id)displayNameForExtendedDomain:(int)extendedDomain;
-(void)_loadOrdering;
-(void)_loadEnabledState;
-(id)init;
-(id)stringForDomain:(int)domain;
-(int)domainForIndexRow:(unsigned)indexRow;
-(void)_saveIfNecessary;
-(void)viewWillDisappear:(BOOL)view;
-(int)tableView:(id)view numberOfRowsInSection:(int)section;
-(void)_updateCell:(id)cell forDomain:(int)domain;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
-(void)tableView:(id)view moveRowAtIndexPath:(id)indexPath toIndexPath:(id)indexPath3;
-(int)tableView:(id)view editingStyleForRowAtIndexPath:(id)indexPath;
-(BOOL)tableView:(id)view shouldIndentWhileEditingRowAtIndexPath:(id)indexPath;
-(void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath;
-(void)dealloc;
@end

@interface RegionFormatSampleView : NSObject <PreferencesTableCustomView> {
	UILabel* _labels[4];
	float _sized;
}
-(id)generateRegionSampleLabel;
-(void)setTextForRegionExample:(id)regionExample;
-(id)initWithSpecifier:(id)specifier;
-(float)preferredHeightForWidth:(float)width;
-(void)dealloc;
-(void)layoutSubviews;
-(id)_accessibilityLabels;
@end

@interface PSInternationalController : PSListController {
	CFLocaleRef _locale;
	double _sampleTime;
	NSArray* _voiceControlTitles;
	NSDictionary* _voiceControlShortTitles;
	NSArray* _voiceControlValues;
}
+(void)setLanguage:(id)language;
+(void)setLocale:(id)locale;
+(id)capitalizeFirstPartOfCountry:(id)country;
+(id)voiceControlLanguageData;
-(void)localeChangedAction;
-(id)init;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
-(void)dealloc;
-(void)viewWillAppear:(BOOL)view;
-(id)localizedComponent:(id)component forDictionary:(id)dictionary;
-(void)reloadSpecifiers;
-(void)reloadLocale;
-(void)_loadLocaleIfNeeded;
-(id)specifiers;
-(void)showLanguageSheet:(id)sheet;
-(id)language:(id)language;
-(id)localizedLanguage:(id)language;
-(void)setVoiceControlLanguage:(id)language specifier:(id)specifier;
-(id)voiceControlLanguage:(id)language;
-(void)setLanguage:(id)language specifier:(id)specifier;
-(void)setLocale:(id)locale specifier:(id)specifier;
-(id)locale:(id)locale;
-(void)setCalendar:(id)calendar specifier:(id)specifier;
-(id)calendar:(id)calendar;
-(id)formattedDate:(id)date;
-(id)formattedTime:(id)time;
-(id)formattedPhoneNumber:(id)number;
-(id)defaultCalendarForLocale:(id)locale;
-(void)_initVoiceControlData;
-(id)voiceControlTitles:(id)titles;
-(id)voiceControlShortTitles;
-(id)voiceControlValues:(id)values;
@end

@interface PSDeleteButton : NSObject <PreferencesTableCustomView> {
@private
	UIButton* _deleteButton;
}
+(float)deleteButtonHeight;
-(id)initWithSpecifier:(id)specifier;
-(id)initWithFrame:(CGRect)frame;
-(void)layoutSubviews;
-(void)addButtonTarget:(id)target action:(SEL)action forControlEvents:(unsigned)controlEvents;
-(void)setButtonTitle:(id)title;
-(float)preferredHeightForWidth:(float)width;
@end

@interface ProblemReportingController : PSListController {
	PrefsUILinkLabel* _aboutDiagnosticsLinkLabel;
	PSSpecifier* _diagnosticDataGroupSpecifier;
}
+(BOOL)isProblemReportingEnabled;
-(Class)tableViewClass;
-(void)diagnosticsDonePressed:(id)pressed;
-(void)showAboutDiagnosticsSheet:(id)sheet;
-(void)viewDidLoad;
-(void)setProblemReportingEnabled:(BOOL)enabled;
-(id)specifiers;
-(BOOL)shouldEnableProblemReportingForCheckedSpecifier;
-(void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath;
-(void)dealloc;
@end

@interface ProblemReportingTableView : NSObject {
	PrefsUILinkLabel* _aboutDiagnosticsLinkLabel;
}
-(id)initWithFrame:(CGRect)frame style:(int)style;
-(void)setController:(id)controller;
-(void)layoutSubviews;
-(void)dealloc;
@end

@interface ProblemReportingAboutDiagnosticsController : NSObject {
}
-(id)init;
-(void)donePressed;
-(BOOL)shouldAutorotateToInterfaceOrientation:(int)interfaceOrientation;
@end

@interface DiagnosticDataController : PSListController {
}
-(id)init;
-(id)specifiers;
@end

@interface PrefsUILinkLabel : NSObject {
	NSURL* _url;
	BOOL _touchingURL;
	id _target;
	SEL _action;
	NSURL* _URL;
}
@property(retain, nonatomic) NSURL* URL;
@property(assign, nonatomic) id target;
@property(assign, nonatomic) SEL action;
-(id)initWithFrame:(CGRect)frame;
-(void)dealloc;
-(void)openURL:(id)url;
-(void)touchesBegan:(id)began withEvent:(id)event;
-(void)touchesMoved:(id)moved withEvent:(id)event;
-(void)touchesCancelled:(id)cancelled withEvent:(id)event;
-(void)tappedLink:(id)link;
-(void)drawTextInRect:(CGRect)rect;
@end

@interface TextFilePane : PSEditingPane {
	UITextView* _textView;
}
-(BOOL)handlesDoneButton;
-(void)dealloc;
-(id)initWithFrame:(CGRect)frame;
-(void)setPreferenceSpecifier:(id)specifier;
@end

@interface NSObject (PreferencesAdditions)
-(id)specifierForID:(id)anId;
@end

@interface PSListController (PasscodeAdditions)
-(void)showPINSheet:(id)sheet;
-(id)popupStylePopoverController;
@end

@interface PSTableCell (SyntheticEvents)
-(id)_automationID;
-(id)scriptingInfoWithChildren;
@end
#endif

