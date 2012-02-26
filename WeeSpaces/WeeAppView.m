#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import "BBWeeAppController-Protocol.h"
#include <objc/runtime.h>
#import <dispatch/dispatch.h>

#import "WeeAppView.h"

#import "UIImage+scale.h"
#import "Snapshot.h"

#import "needed-stuff.h"

#define SCALE 3.0
#define kReportHeight (320.0 / SCALE)
#define kPageWidth (320.0 / SCALE)

@implementation WeeAppView 
@synthesize snap;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"%s", __FUNCTION__);
	SBUserAgent *agent = [objc_getClass("SBUserAgent") sharedUserAgent] ;

	[[objc_getClass("SBBulletinListController") sharedInstance] hideListViewAnimated:YES];

	const int64_t UNIT_OF_TIME = 1000000000LL / 3;
	dispatch_queue_t q = dispatch_get_current_queue();
	dispatch_time_t (^one_sec_delay)(int n) = ^(int n) { return dispatch_time(DISPATCH_TIME_NOW, n * UNIT_OF_TIME); };

	void (^switch_n_go)() =  ^{
		dispatch_after(one_sec_delay(1), q,
			^{ 
				[[objc_getClass("SBUIController") sharedInstance] activateApplicationFromSwitcher:app];
			});
	};

	if ([agent deviceIsLocked]) {
		// if the device is locked (intelliscreenx) we need to unlock first
		[[objc_getClass("SBAwayController") sharedAwayController] unlockWithSound:YES];

		// switch a bit later
		dispatch_after(one_sec_delay(1), q,  switch_n_go);
	}
	else {
		// not locked 
		switch_n_go();
	}
}

-(id)initWithApplication:(SBApplication *)_app withLocation:(CGFloat)x {
	CGFloat width, height;

	width = 320 / SCALE;
	height = 480 / SCALE;

	app = _app;
	snap = nil;

	self = [super initWithFrame:CGRectMake(x, 0.0, width, height)];
	snap = [Snapshot snapshotWithApplication:app view:self];
	return self;
}


-(void)drawRect:(CGRect)r0 {
	// draw the snapshot
	CGRect r = CGRectInset(self.bounds, 8, 8);

	[snap drawAtPoint:CGPointMake(r.origin.x, r.origin.y)];

	// display the name of the app on top
	NSString *label = [app displayName];

	if (app.process != nil)
		[[UIColor whiteColor] set];
	else
		[[UIColor grayColor] set];

	UIFont *f  = [UIFont systemFontOfSize:10];
	CGSize size = [label sizeWithFont:f];
	CGFloat x = (CGRectGetWidth(self.frame) - size.width) / 2.0;

	[label drawInRect:CGRectMake(x, 0, self.frame.size.width, 10) withFont:f];
}
@end

