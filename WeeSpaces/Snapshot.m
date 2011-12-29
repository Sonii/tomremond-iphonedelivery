#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>
#include <objc/runtime.h>

#import "needed-stuff.h"

#import "UIImage+scale.h"
#import "Snapshot.h"

static NSMutableArray *used = nil;
static NSMutableDictionary *dict = nil;

@interface Snapshot(__private)
-(void)doSnap;
-(BOOL)needsNewSnap;
@end

@implementation Snapshot
@synthesize app, image, elapsedCPUTime;

-(id)initWithApplication:(id)_app {
	self = [super init];

	self.app = _app;
	self.elapsedCPUTime = 0;
	self.image = nil;

	return self;
}

-(void)doSnap {
	if ([self needsNewSnap]) {
		SBApplication *_app = app;

		NSLog(@"make snapshot for %@", _app.bundleIdentifier);

		// get the latest live snapshot of the app
		UIView *zoom = [[objc_getClass("SBUIController") sharedInstance] _zoomViewForAppDosado:app includeStatusBar:NO includeBanner:NO];
		// build a snapshot of the image
		image = [[UIImage imageFromView:zoom scaled:1.0 / 3.5] retain];

		self.elapsedCPUTime = _app.process.elapsedCPUTime;
	}
}

-(BOOL)needsNewSnap {
	SBApplication *_app = app;
	BOOL res = (image == nil || _app.process.elapsedCPUTime > self.elapsedCPUTime + 0.05);
#if 0
	if (res)
		NSLog(@"%s %@ image = %@ %f", __FUNCTION__, [app bundleIdentifier], image, _app.process.elapsedCPUTime - self.elapsedCPUTime);
#endif
	return res;
}

-(void)dealloc {
	NSLog(@"%s %@", __FUNCTION__, [app bundleIdentifier]);
	image = nil;
	app = nil;
	[super dealloc];
}

+(void)gc {
	/*
	   perform garbage collection in async so it will be done serialized after all snaps
	*/
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
			NSMutableArray *unused = [[NSMutableArray array] retain];

			// enumarate unused ids
			for (NSString *key in [dict keyEnumerator]) {	
				if ([used containsObject:key] == NO) [unused addObject:key];
			}

			// remove all unused snapshots
			for (NSString *key in unused) {
				[dict removeObjectForKey:key];
			}
			[unused release];

			// empty used list
			[used removeAllObjects];
	});
}

+(UIImage *)snapshotWithApplication:(SBApplication *)app view:(UIView*)view{
	// first time. build the dict holding the snaps
	if (dict == nil) dict = [[NSMutableDictionary alloc] initWithCapacity:16];
	if (used == nil) used = [[NSMutableArray alloc] initWithCapacity:16];

	Snapshot *s = [dict objectForKey:app.bundleIdentifier];

	if (s == nil) {
		// no snap for this id. make one and add it to the dict
		s = [[Snapshot alloc] initWithApplication:app];
		[dict setObject:s forKey:app.bundleIdentifier];
		[s release];
	}

	if ([s needsNewSnap]) {
		extern dispatch_queue_t ws_q;
		dispatch_queue_t q = ws_q;

		if (q == NULL) 
			q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);

		// we need to generate a new snaphot. do it async and notify the view when it's done
		dispatch_async(q, ^{
			[s doSnap];

			// tell the view the snap is ready
			dispatch_async(dispatch_get_main_queue(), ^{
				[view setNeedsDisplay];
			});
		});
	}
	
	// add the id to the list of used bundles in the pass
	[used addObject:app.bundleIdentifier];

	return s.image;
}
@end

