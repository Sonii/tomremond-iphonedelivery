@interface UIImage (scale)
+ (UIImage*)imageFromView:(UIView*)view;
+ (UIImage*)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIImage*)imageFromView:(UIView*)view scaled:(CGFloat)scale;
@end

