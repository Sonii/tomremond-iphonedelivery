#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>
#include <objc/runtime.h>

#import "needed-stuff.h"

#import "WeeAppView.h"
#import "UIImage+scale.h"
#import "Snapshot.h"

extern dispatch_queue_t ws_q;

@implementation Snapshot

+(UIImage *)snapshotWithApplication:(SBApplication *)app view:(WeeAppView*)view{

	// we need to generate a new snaphot. do it async and notify the view when it's done
	dispatch_async(ws_q, ^{
		UIView *zoom = [[objc_getClass("SBUIController") sharedInstance] _zoomViewForAppDosado:app includeStatusBar:NO includeBanner:NO];
		UIImage *image = [UIImage imageFromView:zoom scaled:1.0 / 3.5];


		// tell the view the snap is ready
		dispatch_async(dispatch_get_main_queue(), ^{ view.snap = image; [view setNeedsDisplay]; });
	});
	
	return nil;
}
@end

