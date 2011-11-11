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
	if ([self needsNewSnap]) {
		SBApplication *_app = app;

		NSLog(@"make snapshot for %@", _app.bundleIdentifier);

		// get the latest live snapshot of the app
		UIView *zoom = [[objc_getClass("SBUIController") sharedInstance] _zoomViewForAppDosado:app includeStatusBar:NO includeBanner:NO];
		// build a snapshot of the image
		image = [[UIImage imageFromView:zoom scaled:1.0 / 3.0] retain];

		self.elapsedCPUTime = _app.process.elapsedCPUTime;
	}
}

-(BOOL)needsNewSnap {
	SBApplication *_app = app;
	BOOL res = (image == nil || _app.process.elapsedCPUTime > self.elapsedCPUTime + 0.05);
	if (res)
		NSLog(@"%s %@ image = %@ %f", __FUNCTION__, [app bundleIdentifier], image, _app.process.elapsedCPUTime - self.elapsedCPUTime);
	return res;
}

-(void)dealloc {
	NSLog(@"%s %@", __FUNCTION__, [app bundleIdentifier]);
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
		NSLog(@"remove snapshot for %@", [[[tbf objectAtIndex:index] app] bundleIdentifier]);
		[dict removeObjectForKey:[[[tbf objectAtIndex:index] app] bundleIdentifier]];
	}];
	[tbf removeAllObjects];
	[tbf release];
}

+(UIImage *)snapshotWithApplication:(SBApplication *)app view:(UIView*)view{
	if (dict == nil) dict = [[NSMutableDictionary alloc] initWithCapacity:16];

	Snapshot *s = [dict objectForKey:app.bundleIdentifier];

	if (s == nil) {
		s = [[Snapshot alloc] initWithApplication:app];
		[dict setObject:s forKey:app.bundleIdentifier];
		[s release];
	}

	if ([s needsNewSnap]) {
		// we need to generate a new snaphot. do it async and notify the view when it's done
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			[s doSnap];
			dispatch_async(dispatch_get_main_queue(), ^{
				[view setNeedsDisplay];
			});
		});
	}

	// last time it was requested for gc
	s.last = [NSDate date];
	return s.image;
}
@end

