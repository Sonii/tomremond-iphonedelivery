#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import "BBWeeAppController-Protocol.h"
#include <objc/runtime.h>
#import <dispatch/dispatch.h>

@interface SBUIController
+(id)sharedInstance;
-(void)clickedMenuButton;
@end

@interface SBUserAgent
+(id)sharedUserAgent;
-(BOOL)springBoardIsActive;
-(void)setBadgeNumberOrString:(id)string forApplicationWithID:(id)anId;
-(void)setIdleText:(id)text;
@end


@interface SBIconController
+(id)sharedInstance;
-(id)rootIconListAtIndex:(unsigned)page;
@end

@interface SBIconListView : UIView
-(id)icons;
@end


@interface SBNewsstandIcon : NSObject
@end

@interface SBFolderIcon : NSObject
-(id)iconOverlayImageForLocation:(unsigned)n;
@end

@interface SBApplicationIcon  : NSObject
-(id)getGenericIconImage:(int)image;
-(UIImage *)generateIconImage:(int)image;
-(id)displayName;
-(void)launch;
@end

@interface SBBulletinListController
+(id)sharedInstance;
-(void)showTabViewAnimated:(BOOL)animated;
-(void)hideTabViewAnimated:(BOOL)animated;
-(void)hideListViewAnimated:(BOOL)animated;
@end

@interface WeeSpacesView : UIView {
}
-(void)gotoPage:(unsigned)n;
-(id)initWithPage:(unsigned)page;
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

#define SCALE 3.0
#define kReportHeight (320.0 / SCALE)
#define kPageWidth (320.0 / SCALE)

-(BOOL)loadPage:(unsigned)n {
	WeeSpacesView *v = [[WeeSpacesView alloc] initWithPage:n];
	if (v == nil) return NO;

	dispatch_async(dispatch_get_main_queue(), ^{
			[scrollView addSubview:v];
			[v release];
			[scrollView setContentSize:CGSizeMake((n + 1) * kPageWidth, kReportHeight)];
			[scrollView setNeedsDisplay];
	});	
	return YES;
}

-(void)viewWillAppear {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			for (int i = 0;[self loadPage:i++];);
	});
}

- (void)viewDidDisappear {
	for (UIView *v in scrollView.subviews)  
		[v removeFromSuperview];
}


- (UIView *)view {
    if (_view == nil)
    {
        _view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, 316, kReportHeight)];
        
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 316, kReportHeight)];

		scrollView.scrollEnabled = YES;
		scrollView.pagingEnabled = NO;
		[scrollView setCanCancelContentTouches:NO];
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.opaque = NO;
		scrollView.delegate = self;

		scrollView.userInteractionEnabled = YES;
		_view.userInteractionEnabled = YES;
		_view.opaque = NO;
		[_view addSubview:scrollView];
		
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

-(void)onTouch:(UIControl*)view {
	[view setSelected:YES];
	[view setBackgroundColor:[UIColor blackColor]];
	NSLog(@"select page %d", self.tag);
	[self gotoPage:self.tag];
}

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
		v.image = [icon generateIconImage:2];
		[self addSubview:v];
		[v release];

		x += width / 4;
		if (x >= width) {
			x = margin;
			y += height / 4;
		}
	}

	self.tag = page;

	UIControl *cntrl = [[UIControl alloc] initWithFrame:CGRectMake(0 , 0, width, height)];
	//cntrl.opaque = NO;
	cntrl.userInteractionEnabled = YES;

	[cntrl addTarget:self action:@selector(onTouch:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:cntrl];
	return self;
}

-(void)gotoPage:(unsigned)page {
	UIScrollView *sv = [[objc_getClass("SBIconController") sharedInstance] scrollView];
	CGPoint offset = sv.contentOffset;

	offset.x = 320.0 * (1 + page);

	[[objc_getClass("SBBulletinListController") sharedInstance] hideListViewAnimated:YES];

	// first simulate a click menu
	if (![[objc_getClass("SBUserAgent") sharedUserAgent] springBoardIsActive])
		[[objc_getClass("SBUIController") sharedInstance] clickedMenuButton];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10000000), dispatch_get_current_queue(), 
					^{ 
						[sv setContentOffset:offset animated:YES];
					});

}
@end

