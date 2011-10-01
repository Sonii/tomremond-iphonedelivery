@interface DeliveryReportCache
+(void)flush;
+(void)flushIfNeeded;
+(id)reportForRowid:(unsigned)rowid;
@end

@interface DeliveryReport : NSObject
-(BOOL)sending;
-(BOOL)delivered;
-(unsigned)category;

@property(retain) NSDate *date;
@property int delay;
@property int ref;
@property int status;
@end

