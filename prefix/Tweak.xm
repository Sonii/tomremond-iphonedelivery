#import "CT.h"

%hook CTMmsEncoder
+ (id)encodeSms:(CTMessage *)message {
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	[def addSuiteNamed:@"com.guilleme.prefix"];

	[def synchronize];

	NSString *str = [def stringForKey:@"prefix"];

	if (str != nil) {
		NSMutableData *prefixData = [NSMutableData dataWithData: [str dataUsingEncoding:[NSString defaultCStringEncoding]]];

		CTMessagePart *firstPart = [message.items objectAtIndex:0];
		[prefixData appendData:firstPart.data];

		firstPart.data = prefixData;
	}
	%log; 
	return %orig;
}
#if 0
+ (id)encodeMessage:(CTMessage *)message { 
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
		@"yes", @"X-Mms-Delivery-Report", nil
	];
	message.rawHeaders = headers;
	%log; 
	return %orig; 
}
#endif
%end

