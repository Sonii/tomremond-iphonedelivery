//#import <Preferences/PSListController.h>
#import <UIKit/UIKit.h>

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

#define TABLE nil

@interface DeliveryReportSettingsListController: PSListController {
}
- (NSArray *)localizedSpecifiersForSpecifiers:(NSArray *)s;
-(void)setTitle:(id)title;
@end

@implementation DeliveryReportSettingsListController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"DeliveryReportSettings" target:self] retain];
        _specifiers = [self localizedSpecifiersForSpecifiers:_specifiers];
    }
    return _specifiers;
}

- (NSArray *)localizedSpecifiersForSpecifiers:(NSArray *)s
{
    NSBundle *b = [self bundle];
    //NSLog(@"Bundle \npath = %@\nloc = %@\nbundle = %@", [b bundlePath], [b localizations], b);

    for(PSSpecifier *specifier in s) {
        NSLog(@"specifier %@", specifier);

        NSString *ss = [specifier name];

        if (ss != nil) [specifier setName:[b localizedStringForKey:ss value:ss table:TABLE]];

        if ([specifier titleDictionary]) {

            NSMutableDictionary *newTitles = [[NSMutableDictionary alloc] init];
            
            NSDictionary *d = [specifier titleDictionary];
            for (NSString *key in d) {
                NSString *os = [d objectForKey:key];
                NSString *ns = [b localizedStringForKey:os value:[os uppercaseString] table:nil] ;

                [newTitles setObject:ns forKey:key];
            }
            [specifier setTitleDictionary: [newTitles autorelease]];
        }
    }

    return s;
}

-(void)setTitle:(NSString *)title {
    [super setTitle:[[self bundle] localizedStringForKey:title value:title table:TABLE]];
}
@end

// vim:ft=objc ts=4 expandtab smarttab
