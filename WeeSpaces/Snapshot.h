@interface Snapshot  : NSObject
@property(retain) id app;
@property(retain) UIImage *image;
@property double elapsedCPUTime;

-(id)initWithApplication:(id)app;

+(void)gc;
+(UIImage *)snapshotWithApplication:(id)app view:(UIView*)view;
@end

