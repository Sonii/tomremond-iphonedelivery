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

@interface WeeBrowseIDView : UIView {
	NSString *title;
	NSString *text1;
	NSString *text2;
	UIFont *titleFont, *labelFont;
	UIColor *titleColor, *labelColor, *borderColor;
	int rowid;
	bool loaded;
}
-(id)initWithROWID:(int)rowid;
@end;

@interface WeeBrowseIDController : NSObject <BBWeeAppController> {
	UIScrollView *scrollView;
    UIView *_view;
}

+ (void)initialize;
- (UIView *)view;

@end

@implementation WeeBrowseIDController
- (void)layoutScrollImages {
	WeeBrowseIDView *view = nil;
	NSArray *subviews = [scrollView subviews];
	CGFloat totalWidth = 0.0;

	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews) {
		if ([view isKindOfClass:[WeeBrowseIDView class]]) {
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += frame.size.width;
			totalWidth += frame.size.width;
		}
	}
	
	// set the content size so it can be scrollable
	[scrollView setContentSize:CGSizeMake(totalWidth, [scrollView bounds].size.height)];
}

+ (void)initialize {
}

- (void)dealloc {
    [_view release];
    [super dealloc];
}

- (UIView *)view {
    if (_view == nil)
    {
        _view = [[UIView alloc] initWithFrame:CGRectMake(2, 0, 316, 71)];
        
        UIImage *bg = [[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/WeeBrowseID.bundle/WeeAppBackground.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:71];
        UIImageView *bgView = [[UIImageView alloc] initWithImage:bg];
        bgView.frame = CGRectMake(0, 0, 316, 71);
        [_view addSubview:bgView];
        [bgView release];

		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 316, 71)];

		uint32_t rowids[10];
		int n = get_list_of_rowids(10, rowids);

		for (int i = 0; i < n; i++) {
			WeeBrowseIDView *v1 = [[WeeBrowseIDView alloc] initWithROWID:rowids[i]];

			[scrollView addSubview:v1];
			[v1 release];
		}

		scrollView.scrollEnabled = YES;
		scrollView.pagingEnabled = NO;
		[scrollView setCanCancelContentTouches:NO];
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.opaque = NO;
		[self layoutScrollImages];	

		scrollView.userInteractionEnabled = YES;
		_view.userInteractionEnabled = YES;
		_view.opaque = NO;
		[_view addSubview:scrollView];
	}
    
    return _view;
}

- (float)viewHeight {
    return 71.0f;
}

@end

@implementation WeeBrowseIDView

-(void)setupSample {
	int status = rowid == 0 ? 0 :
                 rowid == 1 ? 32 :
    				          64;

	if (status == 0)
		borderColor = [[UIColor greenColor] retain];
	else if (status > 63)
		borderColor = [[UIColor redColor] retain];
	else
		borderColor = [[UIColor grayColor] retain];

	switch (rowid % 3) {
	case 0:
		title = @"micha Blanc"; 
		text1 = @" Emis le 9 Septembre 2011 à 17:45:22"; 
		text2 = @"Délivré à 17:45:22";
		break;
	case 1:
		title = @"Salomé"; 
		text1 = @" Emis le 8 Septembre 2011 à 17:45:22"; 
		text2 = @"En attente";
		break;
	case 2:
		title = @"Lola la vamp"; 
		text1 = @" Emis le 9 Septembre 2011 à 17:45:22"; 
		text2 = @"Expiré";
		break;
	}
}

-(void)loadReport {
	char name[64], surname[64];
	convert_num_to_name(" 12345678", name, surname);
}

-(id) initWithROWID:(int)_rowid {
	CGRect rect = CGRectMake(0, 0, 240, 71);
	
	rowid = _rowid;
	loaded = NO;

	titleFont = [[UIFont systemFontOfSize:24.0] retain];
	labelFont = [[UIFont systemFontOfSize:12.0] retain];
	titleColor = [[UIColor yellowColor] retain];
	labelColor = [[UIColor whiteColor] retain];
	
	[self loadReport];

	UIView *ret = [super initWithFrame:rect];
	ret.opaque = NO;
	return ret;
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
    [text1 drawInRect:CGRectMake(margin, titleSize.height + margin + 2, width, label1Size.height)  
		     withFont:labelFont 
	    lineBreakMode:UILineBreakModeWordWrap 
		    alignment:UITextAlignmentLeft];

	CGSize label2Size = [text2 sizeWithFont:labelFont];
    [text2 drawInRect:CGRectMake(margin*2, margin + titleSize.height + 2 + label1Size.height , width, label2Size.height)  
		     withFont:labelFont 
	    lineBreakMode:UILineBreakModeWordWrap 
		    alignment:UITextAlignmentLeft];
}
@end
