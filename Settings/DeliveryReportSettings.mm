#import <Preferences/PSListController.h>

@interface DeliveryReportSettingsListController: PSListController {
}
@end

@implementation DeliveryReportSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"DeliveryReportSettings" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
