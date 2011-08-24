@interface DeliveryDateView : UIView {
	NSString *text1, *text2;
	CGRect rect1, rect2;
	UIFont *font;
}
-(id)initWithDate:(NSDate *)d1  date:(NSDate *)d2 view:(UIView *)v;
-(void)drawRect:(CGRect)rect;
@end
// vim: ft=objc ts=4 expandtab


