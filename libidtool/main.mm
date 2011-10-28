//
//  main.c
//  libidtool
//
//  Created by François Guillemé on 10/26/11.
//

#include <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RegisterAgent : NSObject<NSURLConnectionDelegate> {
    NSURLConnection *theConnection;
    NSURLRequest *theRequest;
}
-(id)initWithVersion:(NSString *)version;
-(bool)done;
@end

@implementation RegisterAgent
-(id)initWithVersion:(NSString *)version {
	NSString *unique = [UIDevice currentDevice].uniqueIdentifier;

	// Create the request. it is only for statistics. We send just the device uuid nothing else
	theRequest=[NSURLRequest requestWithURL:
					   [NSURL URLWithString:
				 			[NSString
							stringWithFormat:@"http://iphonedelivery.advinux.com/statistics.php?version=%@&id=%@", version, unique]]
								cachePolicy:NSURLRequestUseProtocolCachePolicy
							timeoutInterval:10.0];
	// create the connection with the request
	// and start loading the data
	theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	return self;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"failed");
    theRequest = nil;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    theRequest = nil;
}
-(bool)done {
    return theRequest == nil;
}
@end


int main (int argc, const char * argv[])
{
	@autoreleasepool {
		RegisterAgent *agent = [[RegisterAgent alloc] initWithVersion:[NSString stringWithUTF8String:argv[1]]];
		int retry = 0;
		while (![agent done] && retry++ < 50) 
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

		agent = nil;
	}
	return 0;
}


