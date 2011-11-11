#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>
#include <objc/runtime.h>

#import "needed-stuff.h"

#import "UIImage+scale.h"
#import "Snapshot.h"

static NSMutableDictionary *dict = NULL;

@interface Snapshot(__private)
-(void)doSnap;
-(BOOL)needsNewSnap;
@end

@implementation Snapshot
@synthesize app, image, elapsedCPUTime, last;

-(id)initWithApplication:(id)_app {
	self = [super init];

	self.app = _app;
	self.elapsedCPUTime = 0;
	self.image = nil;
	self.last = nil;

	return self;
}

-(void)doSnap {
	SBApplication *_app = app;

	NSLog(@"make snapshot for %@", _app.displayName);

	// get the latest live snapshot of the app
	UIView *zoom = [[objc_getClass("SBUIController") sharedInstance] _zoomViewForAppDosado:app includeStatusBar:NO includeBanner:NO];
	// build a snapshot of the image
	image = [[UIImage imageFromView:zoom scaledToSize:CGSizeMake(320.0 / 3.0, 470.0 / 3.0)] retain];

	self.elapsedCPUTime = _app.process.elapsedCPUTime;
}

-(BOOL)needsNewSnap {
	SBApplication *_app = app;
	BOOL res = (image == nil || _app.process.elapsedCPUTime > self.elapsedCPUTime);
	NSLog(@"%s %@ image = %@ %f > %f => %d", __FUNCTION__, [app displayName], image, _app.process.elapsedCPUTime, self.elapsedCPUTime, res);
	return res;
}

-(void)dealloc {
	NSLog(@"%s %@", __FUNCTION__, [app displayName]);
	image = nil;
	app = nil;
	last = nil;
	[super dealloc];
}

+(void)gc {
	NSMutableArray *tbf = [[NSMutableArray alloc] initWithCapacity:16];
	NSDate *now = [NSDate date];

	for (NSString *key in [dict keyEnumerator]) {	
		Snapshot *o = [dict objectForKey:key];
		if ([now timeIntervalSinceDate:o.last] > 10.0) {
			[tbf addObject:o];
		}
	}
	[tbf enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) { 
		NSLog(@"remove snapshot for %@", [[[tbf objectAtIndex:index] app] displayName]);
		[dict removeObjectForKey:[[[tbf objectAtIndex:index] app] displayName]];
	}];
	[tbf removeAllObjects];
	[tbf release];
}

+(UIImage *)snapshotWithApplication:(SBApplication *)app {
	if (dict == nil) dict = [[NSMutableDictionary alloc] initWithCapacity:16];

	Snapshot *s = [dict objectForKey:app.displayName];

	if (s == nil) {
		s = [[Snapshot alloc] initWithApplication:app];
		[dict setObject:s forKey:app.displayName];
		[s release];
	}

	if ([s needsNewSnap]) {
		[s doSnap];
	}

	// last time it was requested for gc
	s.last = [NSDate date];
	return s.image;
}
@end

