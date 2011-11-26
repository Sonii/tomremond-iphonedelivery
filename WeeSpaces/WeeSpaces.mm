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

-(NSArray *)runningApplications {
	return	[[[objc_getClass("SBApplicationController") sharedInstance] allApplications]
					filteredArrayUsingPredicate:[NSPredicate 
						predicateWithBlock:^BOOL(SBApplication *a, NSDictionary *d) {
							if ([a.bundleIdentifier compare:@"com.apple.AdSheetPhone"] == 0)
								return NO;

							return a.process != nil;
						}
				]
		];
}

-(void)viewWillAppear {
	dispatch_async(dispatch_get_main_queue(), ^{
	// get a list of running app
	NSArray *runningApplications =  [self runningApplications];
	int n = [runningApplications count];
	int i = 0;

	[scrollView setContentSize:CGSizeMake(n * kPageWidth, kReportHeight)];

	// first the snapshots of the first app
	for (SBApplication *app in runningApplications) {
		[self loadApplication:app atIndex:n - i - 1];
		i++;
	}
	// display the last snapshot
	[scrollView setContentOffset:CGPointMake((i - 1) * kPageWidth, 0) animated:YES];

	// async populate the scrollview with snapshots
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		int ii = i;
		int page = 0;

		while ([self loadPage:page++ atIndex:ii++]) ;

		[scrollView setContentSize:CGSizeMake((ii -1) * kPageWidth, kReportHeight)];

	});
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
