//#import <Preferences/PSListController.h>
#import <UIKit/UIKit.h>
#import "SpringBoard.h"
#import "Preferences.h"

static CFStringRef app = CFSTR("com.guilleme.deliveryreports");

#define MAGIC_YES 1234567

@interface DeliveryReportSettingsListController: PSListController {
    int reloading;
}
- (NSArray *)localizedSpecifiersForSpecifiers:(NSArray *)s;
-(void)setTitle:(id)title;
-(void)setDeliveryEnabled:(id)value specifier:(id)specifier;
-(id)isDeliveryEnabled:(id)specifier;
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
-(void)restartWithkey:(NSString *)key value:(NSNumber*)value;
-(void)reloadSpecifiers;
@end

@implementation DeliveryReportSettingsListController
-(void)reloadSpecifiers {
    reloading = MAGIC_YES;
    [super reload];
    reloading = NO;
}

-(void)restartWithkey:(NSString *)key value:(NSNumber*)value {
    CFPreferencesSetAppValue((CFStringRef)key, (CFPropertyListRef)value, app);
    CFPreferencesSynchronize(app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);

    // notify the CommCenter to reload
    CFStringRef s= CFSTR("iphonedelivery.restartcc");
    CFNotificationCenterRef nc = CFNotificationCenterGetDarwinNotifyCenter();
    if (nc != nil) CFNotificationCenterPostNotification(nc, s, NULL, NULL, NO);

    UIAlertView *alert;
 
    alert = [[[UIAlertView alloc] initWithTitle:@"Restart CommCenter\nPlease Wait..." 
                                        message:nil 
                                       delegate:self 
                              cancelButtonTitle:nil 
                              otherButtonTitles: nil] autorelease];
    [alert show];
     
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
     
    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
    [indicator startAnimating];
    [alert addSubview:indicator];
    [indicator release];

    // remove the alert after a couple of seconds
    // acyually we should do it when the CommCenter is restarted
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 7*1000LL*1000LL*1000LL), dispatch_get_current_queue(), ^{
                [alert dismissWithClickedButtonIndex:0 animated:YES];
            });

}
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"DeliveryReportSettings" target:self] retain];
        _specifiers = [self localizedSpecifiersForSpecifiers:_specifiers];

        CFPreferencesSynchronize(app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
        NSNumber *value = (NSNumber *)CFPreferencesCopyAppValue(CFSTR("dr-enabled"), app);
        if (reloading != MAGIC_YES && ![value boolValue] && [self indexOfSpecifierID:@"DELIVERY_NOTIFICATION_STYLE"] != NSNotFound) {
            [self removeSpecifierID:@"DELIVERY_NOTIFICATION_STYLE"];
            [self removeSpecifierID:@"DELIVERY_VIBRATE"];
            [self removeSpecifierID:@"DELIVERY_SOUND"];
            [self removeSpecifierID:@"EXPERT_MODE"];
            [self removeSpecifierID:@"DEBUG_MODE"];
            [self removeSpecifierID:@"MS_MODE"];
        }
    }
    return _specifiers;
}

- (NSArray *)localizedSpecifiersForSpecifiers:(NSArray *)s
{
    NSBundle *b = [self bundle];
    //NSLog(@"Bundle \npath = %@\nloc = %@\nbundle = %@", [b bundlePath], [b localizations], b);

    for(PSSpecifier *specifier in s) {
        NSString *ss = [specifier name];

        if (ss != nil) [specifier setName:[b localizedStringForKey:ss value:ss table:nil]];

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
    [super setTitle:[[self bundle] localizedStringForKey:title value:title table:nil]];
}

-(void)setDebugEnabled:(id)value specifier:(id)specifier {
    [self restartWithkey:@"debug" value:value];
}

-(id)isDebugEnabled:(id)specifier {
    CFPreferencesSynchronize(app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
    NSNumber *val = (NSNumber *)CFPreferencesCopyAppValue(CFSTR("debug"), app);
    return val == nil ? [NSNumber numberWithBool:NO] : val;
}

-(void)setMobileSubstrateEnabled:(id)value specifier:(id)specifier {
    [self restartWithkey:@"ms-mode" value:value];
}

-(id)isMobileSubstrateEnabled:(id)specifier {
    CFPreferencesSynchronize(app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
    NSNumber *val = (NSNumber *)CFPreferencesCopyAppValue(CFSTR("ms-mode"), app);
    return val == nil ? [NSNumber numberWithBool:YES] : val;
}

-(void)setDeliveryEnabled:(id)value specifier:(id)specifier {
    [self restartWithkey:@"dr-enabled" value:value];

#if 0
    // gray the settings insyead of hiding them
    [[self specifierForID:@"DELIVERY_NOTIFICATION_STYLE"] setProperty:value forKey:@"enabled"];
    [[self specifierForID:@"DELIVERY_VIBRATE"] setProperty:value forKey:@"enabled"];
    [[self specifierForID:@"DELIVERY_SOUND"] setProperty:value forKey:@"enabled"];
    [[self specifierForID:@"DELIVERY_MARK"] setProperty:value forKey:@"enabled"];
    [[self specifierForID:@"DELIVERY_SMILEY"] setProperty:value forKey:@"enabled"];
#else
    if ([(NSNumber *)value boolValue]) {
        NSArray *s = [self loadSpecifiersFromPlistName:@"DeliveryReportSettings" target:self];
        s = [self localizedSpecifiersForSpecifiers:s];
        [self setSpecifiers:s];
    }
    else {
        [self removeSpecifierID:@"DELIVERY_NOTIFICATION_STYLE"];
        [self removeSpecifierID:@"DELIVERY_VIBRATE"];
        [self removeSpecifierID:@"DELIVERY_SOUND"];
        [self removeSpecifierID:@"EXPERT_MODE"];
        [self removeSpecifierID:@"DEBUG_MODE"];
        [self removeSpecifierID:@"MS_MODE"];
    }
#endif
    [self reload];
}

-(id)isDeliveryEnabled:(id)specifier {
    CFPreferencesSynchronize(app, kCFPreferencesAnyUser, kCFPreferencesAnyHost);
    NSNumber *val = (NSNumber *)CFPreferencesCopyAppValue(CFSTR("dr-enabled"), app);
    return val == nil ? [NSNumber numberWithBool:YES] : val;
}

/*
 - definitely not the right way to do sound localization but it works and I don't want to spend
   more time to dig in Prefences framework
   */
-(id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath {
    UITableViewCell *cell = [super tableView:view cellForRowAtIndexPath:indexPath];

    if ([cell class] == [PSTableCell class]) {
       PSTableCell *tc = (PSTableCell *)cell;
       NSString *str = [tc value];
       if ( [str hasPrefix:@"texttone"] || 
            [str hasPrefix:@"system"] || 
            [str hasPrefix:@"<none>"]) {
            [tc setValue:[[TLToneManager sharedRingtoneManager] localizedNameWithIdentifier:str]];
       }
       else if ([str hasPrefix:@"<default>"]) {
           [tc setValue:[[TLToneManager sharedRingtoneManager] defaultTextToneName]];
       }
       else if ([str hasPrefix:@"itunes"]) { 
       }
    }
    return cell;
}
-(void)viewWillAppear:(BOOL)f {
    [self reload];
    [super viewWillAppear:f];
}

-(void)translate:(PSSpecifier *)spe {
    [[UIApplication sharedApplication] 
        openURL:[NSURL URLWithString:
        @"http://code.google.com/p/iphone-delivery-report/wiki/TRANS?ts=1316632107&updated=TRANS"]];
}
@end

// vim:ft=objc ts=4 expandtab smarttab
