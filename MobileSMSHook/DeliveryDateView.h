@interface DeliveryDateView : UIView {
	NSString *text1, *text2;
	CGRect rect1, rect2;
	UIFont *font;
}
+(void)setRowid:(int)rowid;
+(int)rowid;
+(bool)undisplay:UIView;
-(id)initWithDate:(NSDate *)date forBalloonRect:(CGRect)r andRowid:(int)rowid;
-(void)drawRect:(CGRect)rect;
@end
// vim: ft=objc ts=4 expandtab


