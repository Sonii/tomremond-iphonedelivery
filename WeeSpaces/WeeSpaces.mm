#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBWeeAppController-Protocol.h"
#include <objc/runtime.h>
#import <dispatch/dispatch.h>

#import "WeeSpacesView.h"
#import "WeeAppView.h"

#import "UIImage+scale.h"
#import "Snapshot.h"

#import "needed-stuff.h"

#define SCALE 3.0
#define kReportHeight (320.0 / SCALE)
#define kPageWidth (320.0 / SCALE)

dispatch_queue_t ws_q = NULL;
	
@interface WeeSpacesController : NSObject <BBWeeAppController, UIScrollViewDelegate> {
	UIScrollView *scrollView;
    UIView *_view;
}

+ (void)initialize;
- (UIView *)view;
@end

@implementation WeeSpacesController
+ (void)initialize {
}

- (void)dealloc {
    [_view release];
	[super dealloc];
}

-(BOOL)loadPage:(unsigned)n atIndex:(int)index {
	WeeSpacesView *v = [[WeeSpacesView alloc] initWithPage:n withLocation:index * kPageWidth];
	if (v == nil) return NO;

	dispatch_async(dispatch_get_main_queue(), ^{
			[scrollView addSubview:v];
	});	
	[v release];
	return YES;
}

-(BOOL)loadApplication:(SBApplication *)app atIndex:(int)index {
	WeeAppView *v = [[WeeAppView alloc] initWithApplication:app withLocation:index*kPageWidth];
	if (v == nil) return NO;

	[scrollView addSubview:v];
	[v release];
	return YES;	
}

/*
	get a list of the running and 4 most recents pplications
	ordered by last use time. (The last used being the first)
   */
-(NSMutableArray *)runningApplications {
	const int MAX_INACTIVE = 1;
	SBAppSwitcherModel *model = [objc_getClass("SBAppSwitcherModel") sharedInstance];

	// get a list of all apps
	NSArray *runnings = [[objc_getClass("SBApplicationController") sharedInstance] allApplications];
	NSMutableArray *recent = [NSMutableArray arrayWithArray:[model _recentsFromPrefs]];

	// build a list for running apps
	// and a list for inactives app  (up to four)
	NSMutableArray *res = [NSMutableArray arrayWithCapacity:[runnings count]];
	NSMutableArray *inactive = [NSMutableArray arrayWithCapacity:[runnings count]];
	int ninac = 0;

	// build a list of all recent starting by the running ones
	for (NSString *s in recent) {
		// do not display iAds app
		if ([s compare:@"com.apple.AdSheetPhone"] == 0) continue;

		// find the app with the given id
		NSUInteger idx = [runnings indexOfObjectPassingTest:^BOOL (SBApplication *a, NSUInteger idx, BOOL *stop) {
			return *stop = ([a.bundleIdentifier compare:s] == 0);
		}];

		if (idx == NSNotFound) continue;

		SBApplication *app = [runnings objectAtIndex:idx];

		// if it has a process atached it it it is active
		// otherwise we add it to the inactive list up to MAX_INACTIVE items
		if (app.process != nil)
			[res addObject:app];
		else if (ninac++ < MAX_INACTIVE)
			[inactive addObject:app];
	}

	//  move the first app to the end if it is on the front
	if ([[objc_getClass("SBUserAgent") sharedUserAgent] springBoardIsActive] == NO) {
		id obj = [res objectAtIndex:0];
		[res addObject:obj];
		[res removeObjectAtIndex:0];
	}
	// merge both lists
	[res addObjectsFromArray:inactive];
	return res;
}

-(void)viewWillAppear {

	if (ws_q == NULL) 
		//ws_q = dispatch_queue_create("WeeSpace queue", NULL);
		ws_q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	
	dispatch_async(dispatch_get_main_queue(), ^{
		// get a list of running app
		NSMutableArray *runningApplications =  [self runningApplications];
		int n = [runningApplications count];
		int i = n;

		[scrollView setContentSize:CGSizeMake(n * kPageWidth, kReportHeight)];

		[self loadApplication:[runningApplications objectAtIndex:0] atIndex:--i];
		[runningApplications removeObjectAtIndex:0];

		// first the snapshots of the first app
		// display the last snapshot
		[scrollView setContentOffset:CGPointMake((n - 1) * kPageWidth, 0) animated:YES];

		// async populate the scrollview with snapshots
		dispatch_async(ws_q, ^{
			int j = n;
			int page = 0;

			while ([self loadPage:page++ atIndex:j++]) ;

			[scrollView setContentSize:CGSizeMake((j -1) * kPageWidth, kReportHeight)];
		});
		for (SBApplication *app in runningApplications) {
			[self loadApplication:app atIndex:--i];
		}
		// perform a gc to remove images for processes not active or sleeping anymore
		[Snapshot gc];


	});
}

- (void)viewDidDisappear {
	for (UIView *v in scrollView.subviews)  
		[v removeFromSuperview];
	[_view release];
	_view = nil;
}

- (UIView *)view {
    if (_view == nil)
    {
		int orientation = [[UIApplication sharedApplication] activeInterfaceOrientation];
		CGSize size = [UIScreen mainScreen].bounds.size;
		CGFloat w = size.width;
		if (orientation == 3 || orientation == 4)
			w = 480.0; // w = size.height;

		NSLog(@"active orientation = %d", orientation);
	
        _view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, w - 4, kReportHeight)];
        
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w - 4, kReportHeight)];

		scrollView.scrollEnabled = YES;
		scrollView.pagingEnabled = NO;
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.opaque = NO;
		scrollView.delegate = self;

		[_view addSubview:scrollView];
	}
    
    return _view;
}

- (float)viewHeight {
    return kReportHeight;
}
@end
