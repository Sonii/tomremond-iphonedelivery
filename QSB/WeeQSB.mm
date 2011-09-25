#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import "BBWeeAppController-Protocol.h"
#include <objc/runtime.h>
#import <dispatch/dispatch.h>


@interface SBIconController
+(id)sharedInstance;
-(id)rootIconListAtIndex:(unsigned)page;
@end

@interface SBIconListView : UIView
-(id)icons;
@end

@interface SBFolderIcon : NSObject
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

@interface WeeQSBView : UIView {
}
-(void)gotoPage:(unsigned)n;
-(id)initWithPage:(unsigned)page;
@end

@interface WeeQSBController : NSObject <BBWeeAppController, UIScrollViewDelegate> {
	UIScrollView *scrollView;
    UIView *_view;
}

+ (void)initialize;
- (UIView *)view;
@end

@implementation WeeQSBController
+ (void)initialize {
}

- (void)dealloc {
    [_view release];
	[super dealloc];
}

#define SCALE 3.0
#define kReportHeight (320.0 / SCALE)
#define kPageWidth (320.0 / SCALE)

-(void)loadPage:(unsigned)n {
	WeeQSBView *v = [[WeeQSBView alloc] initWithPage:n];
	if (v == nil) return;

	[scrollView addSubview:v];
	[v release];
	[scrollView setContentSize:CGSizeMake((n + 1) * kPageWidth, kReportHeight)];
}

-(void)viewWillAppear {
	[self loadPage:0];	
	[self loadPage:1];	
	[self loadPage:2];	
	[self loadPage:3];	
	[self loadPage:4];	
	[self loadPage:5];	
}

- (void)viewDidDisappear {
	for (UIView *v in scrollView.subviews)  
		[v removeFromSuperview];
}


- (UIView *)view {
    if (_view == nil)
    {
        _view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, 316, kReportHeight)];
        
#if 0
        UIImage *bg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/WeeQSB.bundle/WeeAppBackground.png"] 
					   stretchableImageWithLeftCapWidth:5 
										   topCapHeight:kReportHeight]; 
		
		UIImageView *bgView = [[UIImageView alloc] initWithImage:bg];
        bgView.frame = CGRectMake(0, 0, 316, kReportHeight);
        [_view addSubview:bgView];
        [bgView release];
#endif

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

@implementation WeeQSBView

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

	UIImageView *back = [[UIImageView alloc] initWithFrame:CGRectMake(x + 2 , y + 2 , width - 4 , height - 4)];
	back.image = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/WeeQSB.bundle/WeeAppBackground.png"]
						stretchableImageWithLeftCapWidth:5 
									 topCapHeight:5]; 
	[self addSubview:back];
	[back release];

	x = y = margin / 2;
	for (SBApplicationIcon *icon in icons) {
		UIImageView *v = [[UIImageView alloc] 
								initWithFrame:CGRectMake(x, y, width / 4 - margin * 2, height / 4 - margin * 2)];
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
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10000000), dispatch_get_current_queue(), 
					^{ 
						[sv setContentOffset:offset animated:YES];
					});

}
@end

