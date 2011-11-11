#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import "BBWeeAppController-Protocol.h"
#include <objc/runtime.h>
#import <dispatch/dispatch.h>

#import "WeeSpacesView.h"

#import "UIImage+scale.h"
#import "Snapshot.h"

#import "needed-stuff.h"

#define SCALE 3.0
#define kReportHeight (320.0 / SCALE)
#define kPageWidth (320.0 / SCALE)

@implementation WeeSpacesView

-(id)initWithPage:(unsigned)page {
	CGFloat x, y, width, height, margin;

	width = 320 / SCALE;
	height = 320 / SCALE;
	margin = 4;

	NSArray *icons = [[[objc_getClass("SBIconController") sharedInstance] rootIconListAtIndex:page] icons];

	if ([icons count] == 0) {
		[self release];
		return nil;
	}

	self = [super initWithFrame:CGRectMake(width * page, 0.0, width, height)];

	x = y = 0;
	UIImageView *back = [[UIImageView alloc] initWithFrame:CGRectMake(x + 2 , y, width - 4 , height)];
	NSBundle *b = [NSBundle bundleWithIdentifier:@"com.guilleme.WeeSpaces"];
	NSLog(@"%@", [b bundlePath]);
	back.image = [[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/WeeAppBackground.png", [b bundlePath]]]
				  stretchableImageWithLeftCapWidth:5 
									  topCapHeight:5]; 
	[self addSubview:back];
	[back release];

	x = y = margin / 2;
	for (SBApplicationIcon *icon in icons) {
		UIImageView *v = [[UIImageView alloc] 
								initWithFrame:CGRectMake(x, y, width / 4 - margin * 2, height / 4 - margin * 2)];
		if ([icon class] == [objc_getClass("SBFolderIcon")  class] ||
			[icon class] == [objc_getClass("SBNewsstandIcon") class])
			v.backgroundColor = [UIColor blackColor];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			v.image = [icon generateIconImage:2];
			[self addSubview:v];
		});
		[v release];

		x += width / 4;
		if (x >= width) {
			x = margin;
			y += height / 4;
		}
	}

	self.tag = page;

	return self;
}

-(void)dealloc {
	NSLog(@"%s page %d", __FUNCTION__, self.tag);
	[super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"%s", __FUNCTION__);

	unsigned page = self.tag;
	UIScrollView *sv = [[objc_getClass("SBIconController") sharedInstance] scrollView];
	SBUserAgent *agent = [objc_getClass("SBUserAgent") sharedUserAgent] ;
	CGPoint offset = sv.contentOffset;

	offset.x = 320.0 * (1 + page);

	[[objc_getClass("SBBulletinListController") sharedInstance] hideListViewAnimated:YES];

	const int64_t UNIT_OF_TIME = 1000000000LL / 3;
	dispatch_queue_t q = dispatch_get_current_queue();
	void (^go2page)() = ^{ [sv setContentOffset:offset animated:YES]; };
	void (^press_home)() = ^{ [[objc_getClass("SBUIController") sharedInstance] clickedMenuButton]; };
	dispatch_time_t (^one_sec_delay)(int n) = ^(int n) { return dispatch_time(DISPATCH_TIME_NOW, n * UNIT_OF_TIME); };

	void (^switch_n_go)() =  ^{
		if ([agent springBoardIsActive]) {
			// we are on the springboard go to the page
			dispatch_after(one_sec_delay(1), q,  go2page);
		}
		else {
			// inside an app, we need to exit it first
			dispatch_after(one_sec_delay(1), q,  ^{
				press_home();
				dispatch_after(one_sec_delay(1), q,  go2page);
			});
		}
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
@end

