#import "needed-stuff.h"

@interface WeeAppView : UIView {
	SBApplication * app;
}
-(id)initWithApplication:(id)app withLocation:(CGFloat)x;
@end

