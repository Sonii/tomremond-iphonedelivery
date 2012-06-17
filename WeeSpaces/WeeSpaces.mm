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

#include <execinfo.h>

#define SCALE 3.0
#define kReportHeight (320.0 / SCALE)
#define kPageWidth (320.0 / SCALE)

dispatch_queue_t ws_q = NULL;
	
@interface WeeSpacesController : NSObject <BBWeeAppController, UIScrollViewDelegate> {
	UIScrollView *scrollView;
    UIView *_view;
	NSMutableArray *running;
	int orientation;
}

+ (void)initialize;
- (UIView *)view;
@end

@implementation WeeSpacesController
+ (void)initialize {
}

-(BOOL)loadPage:(unsigned)n atIndex:(int)index {
	WeeSpacesView *v = [[WeeSpacesView alloc] initWithPage:n withLocation:index * kPageWidth];
	if (v == nil) return NO;

	//NSLog(@"%s %d -> %@", __FUNCTION__, index, v);
	dispatch_async(dispatch_get_main_queue(), ^{
		[scrollView addSubview:v];
	});	
	return YES;
}

-(BOOL)loadApplication:(SBApplication *)app atIndex:(int)index {
	WeeAppView *v = (WeeAppView *)[scrollView viewWithTag:1000+index];

	//NSLog(@"%s %d -> %@", __FUNCTION__, index, v);
	if (v == nil) {
		v = [[WeeAppView alloc] initWithApplication:app withLocation:index*kPageWidth];
		if (v == nil) return NO;

		v.tag = 1000 + index;
		[scrollView addSubview:v];
	}
	return YES;	
}


/*
	get a list of the running and 4 most recents pplications
	ordered by last use time. (The last used being the first)
   */
-(NSMutableArray *)runningApplications {
	const int MAX_INACTIVE = 4;
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
	if ([res count] > 0 && [[objc_getClass("SBUserAgent") sharedUserAgent] springBoardIsActive] == NO) {
		id obj = [res objectAtIndex:0];
		[res addObject:obj];
		[res removeObjectAtIndex:0];
	}
	// merge both lists
	[res addObjectsFromArray:inactive];

	return res;
}

-(void)createView {
    if (_view == nil)
    {
		//NSLog(@"%s", __FUNCTION__);

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
}

-(void)viewWillAppear {
	NSLog(@"%s", __FUNCTION__);
}


- (void)viewDidAppear {
	NSLog(@"%s", __FUNCTION__);

	if (ws_q == NULL) 
		ws_q = dispatch_queue_create("WeeSpace queue", NULL);
	//ws_q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	// get a list of running app
	int n, i;
	running =  [self runningApplications];
	i = n = [running count];

	[scrollView setContentSize:CGSizeMake(n * kPageWidth, kReportHeight)];

	if ([running count] > 0) {
		[self loadApplication:[running objectAtIndex:0] atIndex:--i];
		[running removeObjectAtIndex:0];

		// first the snapshots of the first app
		// display the last snapshot
		[scrollView setContentOffset:CGPointMake((n - 1) * kPageWidth, 0) animated:NO];
	}

	// async populate the scrollview with snapshots
	dispatch_async(ws_q, ^{
			int j = n;
			int page = 0;

			NSLog(@"%@ create pages", self);
			while ([self loadPage:page++ atIndex:j++]) ;

			[scrollView setContentSize:CGSizeMake((j -1) * kPageWidth, kReportHeight)];
	});

#if 0
	// postpone loading to when the snap is shown
	for (SBApplication *app in running) {
		[self loadApplication:app atIndex:--i];
	}
#endif
}

- (void)viewWillDisappear {
	NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidDisappear {
	NSLog(@"%s", __FUNCTION__);

	for (UIView *v in scrollView.subviews)  
		[v removeFromSuperview];
}

- (UIView *)view {
	[self createView];
    return _view;
}

- (float)viewHeight {
    return kReportHeight;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollview {
	int n = scrollview.contentOffset.x /  kPageWidth;

	if ([running count] > n) {
		[self loadApplication:[running objectAtIndex:[running count] - n - 1] atIndex:n];
	}
	n++;
	if ([running count] > n) {
		[self loadApplication:[running objectAtIndex:[running count] - n - 1] atIndex:n];
	}
}

- (void)willRotateToInterfaceOrientation:(int)arg1 {
	NSLog(@"%s %d", __FUNCTION__, arg1);
	if (arg1 != orientation) {
		orientation = arg1;
		CGSize size = [UIScreen mainScreen].bounds.size;
		CGFloat w = size.width;
		if (orientation == 3 || orientation == 4)
			w = 480.0; // w = size.height;

		scrollView.frame = CGRectMake(0, 0, w - 4, kReportHeight);
	}
}

@end

#if 0
extern "C" {
	
void zzhandler(int sig) {
  void *array[10];
  size_t size;

  // get void*'s for all entries on the stack
  size = backtrace(array, 10);

  // print out all the frames to stderr
  fprintf(stderr, "Error: signal %d:\n", sig);
  backtrace_symbols_fd(array, size, 2);
  exit(1);
}
}

extern "C" void hookinit() {
  signal(SIGSEGV, zzhandler);   // install our handler
  signal(SIGBUS, zzhandler);   // install our handler
}
#endif

