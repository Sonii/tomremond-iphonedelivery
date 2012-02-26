#import "needed-stuff.h"

@interface WeeAppView : UIView {
	SBApplication * app;
	UIImage *snap;
}
@property(strong) UIImage *snap;
-(id)initWithApplication:(id)app withLocation:(CGFloat)x;
@end

