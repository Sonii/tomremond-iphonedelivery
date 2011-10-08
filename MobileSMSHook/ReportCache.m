#import "database.h"
#import "ReportCache.h"

#define MAX_CACHE_SIZE 256

#if !defined(DEBUG)
#define NSLog(...) 
#endif

static NSMutableDictionary *cache = nil;

@implementation DeliveryReportCache 
+(void)init {
	if (cache == nil)
		cache =[ [NSMutableDictionary dictionaryWithCapacity:64] retain];
}

+(void)flush {
	[cache removeAllObjects];
}

+(void)flushIfNeeded {
	if ([cache count] > MAX_CACHE_SIZE)
		[DeliveryReportCache flush];
}

+(id)reportForRowid:(unsigned)rowid {
    DeliveryReport *report = nil;
    int ref, delay, status;
    time_t date;
	NSNumber *key = [NSNumber numberWithInteger:rowid];

	NSLog(@"%s rowid=%d", __FUNCTION__, rowid);
    if (cache == nil) [DeliveryReportCache init];
    report = [cache objectForKey:key];

	if (report == nil) {
		int rc = get_delivery_info_for_rowid(rowid, &ref, &date, &delay, &status);
		if (rc == 0) {
			report = [[DeliveryReport alloc] init];
			report.date = [NSDate dateWithTimeIntervalSince1970:date];
			report.delay = delay;
			report.ref = ref;
			report.status = status;

			[DeliveryReportCache flushIfNeeded];

			[cache setObject:report forKey:key];
			[report release];
		}
	}
	NSLog(@"report = %@", report);
    return report;
}
@end

@implementation DeliveryReport
@synthesize date = _date, delay = _delay, ref = _ref, status = _status;

-(BOOL)sending {
	return _status == 0 && _delay == -1 && _ref == 0;
}

-(unsigned)category {
	unsigned code = 3;

	if (_date != nil && _delay >= 0 && _status == 0)
		code = 1;
	else if (_date != nil && _ref >= 0)
		code = 0;
	else if (_status == 70)
		code = 2;

	return code;
}

-(BOOL)delivered {
	return _date != nil && _delay != -1 && _status == 0;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"Delivery report ref = %d %@ delay = %d status = %d", _ref, _date, _delay, _status];
}

-(void)dealloc {
    _date = nil;
    [super dealloc];
}
@end
// vim: ft=objc ts=4 expandtab
