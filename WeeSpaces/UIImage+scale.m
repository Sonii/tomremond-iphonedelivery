#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>

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

+ (UIImage*)imageFromView:(UIView*)view scaled:(CGFloat)scale
{
	CGSize s = [view bounds].size;
	s.width *= scale;
	s.height *= scale;
	[self beginImageContextWithSize:s];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(context, scale, scale);
    [[view layer] renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    return image;
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

