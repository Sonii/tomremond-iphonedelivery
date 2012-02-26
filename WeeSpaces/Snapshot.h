@interface Snapshot  : NSObject
@property(strong) id app;
@property(strong) UIImage *image;
@property double elapsedCPUTime;

-(id)initWithApplication:(id)app;

+(void)gc;
+(UIImage *)snapshotWithApplication:(id)app view:(UIView*)view;
@end

