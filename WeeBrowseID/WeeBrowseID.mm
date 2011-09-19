#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBWeeAppController-Protocol.h"

#import "Date+extra.h"
#import "Localizer.h"

extern "C" {
#import "database.h"
}

static void CGContextAddRoundRect(CGContextRef context, CGRect rect, float radius) {
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, 
        radius, M_PI, M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, 
        rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, 
        rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, 
        radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, 
        -M_PI / 2, M_PI, 1);
}

@protocol WeeReportError
-(void)invalidReport:(uint32_t)rowid;
@end

@interface WeeBrowseIDView : UIView {
	int status;
	NSString *title;
	NSString *text1;
	NSString *text2;
	UIFont *titleFont, *labelFont;
	UIColor *titleColor, *labelColor, *borderColor;
	NSObject<WeeReportError> *delegate;
}
-(id)initWithROWID:(int)rowid;
-(void)setDelegate:(id)o;
-(void)loadReport;
@end

#define kReportWidth 200.0f
#define kReportHeight 56.0f
#define kMaxVisibleReports 200

static id sharedInstance;
static BOOL visible = NO;

@interface WeeBrowseIDController : NSObject <BBWeeAppController, UIScrollViewDelegate, WeeReportError> {
	UIScrollView *scrollView;
    UIView *_view;
	uint32_t reportsIndex[kMaxVisibleReports];
	int numberOfReports;
}

+ (void)initialize;
- (UIView *)view;
-(void) loadVisibleReports;
-(void)loadReport:(int)n;
-(void)reload;
@end

@implementation WeeBrowseIDController
/*
  Reload the index on a separate que and redisplay the scroll view on the main queue
  cond is used in case we just want to redisplay
   */
-(void)reloadIndex:(BOOL)cond {
	// load the index
	dispatch_async(
		dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
		^{
			if (cond) 
				numberOfReports = get_list_of_rowids(kMaxVisibleReports, reportsIndex);
			
			dispatch_async( dispatch_get_main_queue(), ^{
					if (cond) 
						for (UIView *v in scrollView.subviews)  
							[v removeFromSuperview];

					[scrollView setContentSize:CGSizeMake(numberOfReports * kReportWidth, [scrollView bounds].size.height)];
					[self loadVisibleReports];
				}
			);
		}
	);
}

-(void)viewWillAppear {
	visible = YES;

	[self reloadIndex:(numberOfReports == 0 || numberOfReports < kMaxVisibleReports)];
	scrollView.contentOffset = CGPointMake(0.0, 0.0);

}
- (void)viewDidDisappear {
	visible = NO;
	numberOfReports = 0;
	for (UIView *v in scrollView.subviews)  
		[v removeFromSuperview];
}

+ (void)initialize {
    [[NSNotificationCenter defaultCenter] 
            addObserverForName:@"iphonedelivery.refresh"
            object:nil 
            queue:nil
            usingBlock:^(NSNotification *n){ 
				NSDictionary *ud = (NSDictionary *)[n userInfo];
				NSNumber *status = [ud objectForKey:@"STATUS"];

				NSLog(@"Wee received a notification %@ status = %@", ud, status);

				if (sharedInstance != nil && visible) {
					if (status == nil)
						[sharedInstance reloadIndex:YES];
					else
						[sharedInstance reload];
				}
	}];
}

- (void)dealloc {
    [_view release];
	sharedInstance = nil;
	[super dealloc];
}

- (UIView *)view {
  	sharedInstance = self;
    if (_view == nil)
    {
		numberOfReports = 0;
        _view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, 316, kReportHeight)];
        
        UIImage *bg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/WeeBrowseID.bundle/WeeAppBackground.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:71];
        UIImageView *bgView = [[UIImageView alloc] initWithImage:bg];
        bgView.frame = CGRectMake(0, 0, 316, kReportHeight);
        [_view addSubview:bgView];
        [bgView release];

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
	}
    
    return _view;
}

- (float)viewHeight {
    return kReportHeight;
}

-(void)reload {
	for (UIView *v in scrollView.subviews)  {
		[(WeeBrowseIDView *)v loadReport];
		[v setNeedsDisplay];
	}
}

-(void)loadReport:(int)n {
	if (n < 0 || n >= numberOfReports) return;

	uint32_t rowid = reportsIndex[n];

	WeeBrowseIDView *v = (WeeBrowseIDView *)[scrollView viewWithTag:rowid];

	if (v == nil) {
		v = [[WeeBrowseIDView alloc] initWithROWID:rowid];
		[v setDelegate:self];

		CGRect frame = v.frame;
		frame.origin = CGPointMake(kReportWidth * n, 0);
		v.frame = frame;

		dispatch_async(dispatch_get_main_queue(), ^{
			[scrollView addSubview:v];
			[scrollView setNeedsDisplay];
		});

		[v release];
	}
}

-(void) loadVisibleReports {
	int n = scrollView.contentOffset.x / kReportWidth;

	[self loadReport:n - 2];
	[self loadReport:n - 1];
	[self loadReport:n];
	[self loadReport:n + 1];
	[self loadReport:n + 2];
}

- (void)scrollViewDidScroll:(UIScrollView *)sv {
	[self loadVisibleReports];
}

// quiter useless as we reload when the view get visible
-(void)invalidReport:(uint32_t)rowid {
	[self reloadIndex:YES];
}
@end

@implementation WeeBrowseIDView
-(void)_loadReport {
	int rowid = self.tag;
	char name[64], surname[64];
    Localizer *localizer = [Localizer sharedInstance];

	[title release]; title = nil;
	[text1 release]; text1 = nil;
	[text2 release]; text2 = nil;

	NSString *number = get_address_for_rowid(rowid);

	if (number == nil) {
		[delegate invalidReport:rowid];
		self.hidden = YES;
		return;
	}
    if (convert_num_to_name([number UTF8String], name, surname) && (name[0] || surname[0])) {
        title = [[localizer getTitle:[NSString stringWithUTF8String:name]
                           surname:[NSString stringWithUTF8String:surname]] retain];
    }

	int ref, delay;
	time_t date;
	if (0 == get_delivery_info_for_rowid(rowid, &ref, &date, &delay, &status)) {
		NSDate *sdate = [NSDate dateWithTimeIntervalSince1970:date];
    	NSString *s = [localizer getString:@"SUBMIT"];

    	s = [s stringByReplacingOccurrencesOfString:@"%DATESPEC%" 
								withString:[localizer formatDate:sdate style:NSDateFormatterMediumStyle]];
    	s = [s stringByReplacingOccurrencesOfString:@"%TIMESPEC%" 
								withString:[localizer formatTime:sdate style:NSDateFormatterMediumStyle]];
		text1 = [s retain];

		// we don' t store temporary statuse so we assume a non-zero smsc_ref is pending...
		if (ref != -1) status = 48;

		if (status == 0) {
			NSDate *rdate = [NSDate dateWithTimeIntervalSince1970:date+delay];
    		NSString *s = [localizer getString:@"DELIVERED"];
			bool sameday = [rdate isSameDayAs:sdate];

    		s = [s stringByReplacingOccurrencesOfString:@"%DATESPEC%" 
				withString:sameday?@"":[localizer formatDate:rdate style:NSDateFormatterMediumStyle]];

    		s = [s stringByReplacingOccurrencesOfString:@"%TIMESPEC%" 
				withString:[localizer formatTime:rdate style:NSDateFormatterMediumStyle]];

			text2 = [s retain];
			borderColor = [[UIColor greenColor] retain];
		}
		else {
			NSString *s = [NSString stringWithFormat:@"STATUS_%d",status];
			s = [localizer getString:s];
			if (s == nil) {
				s = [localizer getString:@"STATUS"];
				if (s != nil) {
    				s = [s stringByReplacingOccurrencesOfString:@"%STATUS%" 
						withString:[NSString stringWithFormat:@"%d",status]];
				}
			}
			
			text2 = [s retain];
			if (status > 63)
				borderColor = [[UIColor redColor] retain];
			else
				borderColor = [[UIColor grayColor] retain];
		}
	}
}

-(void)loadReport {
	// reload the index
	dispatch_async(
		dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
		^{
		[self _loadReport];
		dispatch_async( dispatch_get_main_queue(), ^{
			[self setNeedsDisplay];
		});
	});
}


#define ONE_SEC (1 * 1000LL * 1000LL * 1000LL)

-(void)scheduleUnload {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5*ONE_SEC), dispatch_get_main_queue(), ^{
			// check if view is visible
			CGRect r1 = self.frame;
			CGRect r2 = self.superview.bounds;

			if (!CGRectIntersectsRect(r1, r2)) {
				//NSLog(@"remove view with rowid %d", self.tag);
				[self removeFromSuperview];
			}
			else
				[self scheduleUnload];
		});
}

-(id) initWithROWID:(int)_rowid {
	self = [super initWithFrame:CGRectMake(0, 0, kReportWidth, kReportHeight)];
	
	self.tag = _rowid;
	[self loadReport];

	titleFont = [[UIFont systemFontOfSize:18.0] retain];
	labelFont = [[UIFont systemFontOfSize:11.0] retain];
	titleColor = [[UIColor whiteColor] retain];
	labelColor = [[UIColor yellowColor] retain];
	
	self.opaque = NO;
	self.hidden = NO;
	[self scheduleUnload];
	return self;
}

-(void) dealloc {
	[titleColor release];
	[titleFont release];
	[labelColor release];
	[labelFont release];
	[borderColor release];
	
	[title release];
	[text1 release];
	[text2 release];

	[super dealloc];
}

-(void)drawRect:(CGRect)r {

    CGRect rect = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRoundRect(context, CGRectInset(self.bounds, 2.0, 2.0), 6.0);
	CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);

	CGFloat width = self.bounds.size.width;
	CGFloat margin = 4.0;

    // Draw the text
	[titleColor set];
	CGSize titleSize = [title sizeWithFont:titleFont];
    [title drawInRect:CGRectMake(margin, margin, width, titleSize.height)  
		     withFont:titleFont 
	    lineBreakMode:UILineBreakModeWordWrap 
		    alignment:UITextAlignmentCenter];

	[labelColor set];
	CGSize label1Size = [text1 sizeWithFont:labelFont];
    [text1 drawInRect:CGRectMake(margin*2, self.bounds.size.height - margin - label1Size.height * 2, width, label1Size.height)  
		     withFont:labelFont 
	    lineBreakMode:UILineBreakModeWordWrap 
		    alignment:UITextAlignmentCenter];

	// if it's pending or an error set the label in color
	if (status >= 32)
		[borderColor set];

	CGSize label2Size = [text2 sizeWithFont:labelFont];
    [text2 drawInRect:CGRectMake(margin*2, self.bounds.size.height - margin - label1Size.height, width, label2Size.height)  
		     withFont:labelFont 
	    lineBreakMode:UILineBreakModeWordWrap 
		    alignment:UITextAlignmentCenter];
}

-(void)setDelegate:(id)o {
	delegate = o;
}
@end
