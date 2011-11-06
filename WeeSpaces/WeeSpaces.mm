#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import "BBWeeAppController-Protocol.h"
#include <objc/runtime.h>
#import <dispatch/dispatch.h>

#import "needed-stuff.h"

#define SCALE 3.0
#define kReportHeight (320.0 / SCALE)
#define kPageWidth (320.0 / SCALE)

@interface UIImage (scale)
+ (UIImage*)imageFromView:(UIView*)view;
+ (UIImage*)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end

@interface WeeSpacesView : UIView {
}
-(id)initWithPage:(unsigned)page;
@end

@interface WeeAppView : UIView {
	SBApplication *appl;
	UIImage *snapshot;
}
-(id)initWithApplication:(SBApplication *)app;
@end

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
	WeeSpacesView *v = [[WeeSpacesView alloc] initWithPage:n];
	if (v == nil) return NO;

	dispatch_async(dispatch_get_main_queue(), ^{
			CGRect r = v.frame;
			r.origin.x = index * kPageWidth;
			v.frame = r;
			[scrollView addSubview:v];
			[scrollView setContentSize:CGSizeMake((index + 1) * kPageWidth, kReportHeight)];
			[scrollView setNeedsDisplay];
	});	
	[v release];
	return YES;
}

-(BOOL)loadApplication:(SBApplication *)app atIndex:(int)index {
	WeeAppView *v = [[WeeAppView alloc] initWithApplication:app];
	if (v == nil) return NO;

	dispatch_async(dispatch_get_main_queue(), ^{
			CGRect r = v.frame;
			r.origin.x = index * kPageWidth;
			v.frame = r;
			[v setNeedsDisplay];
			[scrollView addSubview:v];
			[scrollView setContentSize:CGSizeMake((index + 1) * kPageWidth, kReportHeight)];
			[scrollView setNeedsDisplay];
	});
	[v release];
	return YES;	
}

-(void)viewWillAppear {
	// get a list of running app
	NSArray *runningApplications = 
		[[[objc_getClass("SBApplicationController") sharedInstance] allApplications]
					filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SBApplication *a, NSDictionary *d) {
							return a.process != nil;
					}
				]
		];

	// populate the scrollview with snapshots
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			int i = 0;
			int n = [runningApplications count];

			// first the snapshots of the first app
			for (SBApplication *a in runningApplications) {
	 			if ([self loadApplication:a atIndex:(n - i - 1)])  {
					i++;
				}
			}
			// display the last snapshot
			dispatch_async(dispatch_get_main_queue(), ^{
				[scrollView setContentOffset:CGPointMake((i - 1) * kPageWidth, 0) animated:YES];
				[scrollView setNeedsDisplay];
			});

			// then the springboard pages
			int page = 0;
			while ([self loadPage:page++ atIndex:i++]) ;
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
			w = size.height;

		NSLog(@"active orientation = %d", orientation);
	
        _view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, w - 4, kReportHeight)];
        
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w - 4, kReportHeight)];

		scrollView.scrollEnabled = YES;
		scrollView.pagingEnabled = NO;
		[scrollView setCanCancelContentTouches:NO];
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.opaque = NO;
		scrollView.delegate = self;
		scrollView.delaysContentTouches = NO;

		_view.userInteractionEnabled = YES;
		_view.opaque = NO;
		[_view addSubview:scrollView];
	}
    
    return _view;
}

- (float)viewHeight {
    return kReportHeight;
}

@end

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

@implementation WeeAppView 
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
				[[objc_getClass("SBUIController") sharedInstance] activateApplicationFromSwitcher:appl];
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

-(id)initWithApplication:(SBApplication *)app{
	CGFloat width, height;

	width = 320 / SCALE;
	height = 480 / SCALE;

	dispatch_async(dispatch_get_current_queue(), ^{
		// get the latest live snapshot of the app
		UIView *zoom = [[objc_getClass("SBUIController") sharedInstance] _zoomViewForAppDosado:app includeStatusBar:NO includeBanner:NO];
		// build a snapshot of the image
		snapshot = [UIImage imageFromView:zoom scaledToSize:CGSizeMake(320.0 / 3.0, 470.0 / 3.0)];

		appl = [app retain];
		[snapshot retain];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self setNeedsDisplay];
			});
	});

	self = [super initWithFrame:CGRectMake(0.0, 0.0, width, height)];

	return self;
}

-(void)dealloc {
	NSLog(@"%s %@", __FUNCTION__, [appl displayName]);
	[snapshot release];
	[appl release];
	[super dealloc];
}

-(void)drawRect:(CGRect)rect {
	// draw the snapshot
	CGRect r = CGRectInset(self.bounds, 8, 8);
	[snapshot drawInRect:CGRectOffset(r, 0, -2)];

	// display the name of the app on top
	[[UIColor whiteColor] set];
	UIFont *f  = [UIFont systemFontOfSize:10];
	CGSize size = [[appl displayName] sizeWithFont:f];
	CGFloat x = (CGRectGetWidth(self.frame) - size.width) / 2.0;

	[[appl displayName] drawInRect:CGRectMake(x, 0, self.frame.size.width, 10) 
						  withFont:f];
}
@end

@implementation UIImage (scale)

+ (void)beginImageContextWithSize:(CGSize)size
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
    } else {
        UIGraphicsBeginImageContext(size);
    }
}

+ (void)endImageContext
{
    UIGraphicsEndImageContext();
}

+ (UIImage*)imageFromView:(UIView*)view
{
    [self beginImageContextWithSize:[view bounds].size];
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    return image;
}

+ (UIImage*)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize
{
    UIImage *image = [self imageFromView:view];
    if ([view bounds].size.width != newSize.width ||
            [view bounds].size.height != newSize.height) {
        image = [self imageWithImage:image scaledToSize:newSize];
    }
    return image;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    [self beginImageContextWithSize:newSize];
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    return newImage;
}
@end

