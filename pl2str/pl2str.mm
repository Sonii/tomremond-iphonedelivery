/*
 Copyright (C) 2009 - F. Guillemé
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

#import <AppKit/AppKit.h>
#import <CoreFoundation/CoreFoundation.h>

#define WARN_IF(cond, text...) if (cond) fprintf(stderr, text)
#define RET_IF(cond, val, text...) if (cond) { fprintf(stderr, text); return val; }

CFPropertyListRef LoadPropertyList(CFURLRef *url, const char *path, CFPropertyListFormat *format) {
    CFPropertyListRef plist;

    *url = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, (uint8_t *) path, strlen(path), false);
    CFReadStreamRef stream = CFReadStreamCreateWithFile(kCFAllocatorDefault, *url);
    CFReadStreamOpen(stream);
    plist = CFPropertyListCreateFromStream(kCFAllocatorDefault, stream, 0, kCFPropertyListMutableContainersAndLeaves, format,
            NULL);
    CFReadStreamClose(stream);
    CFRelease(stream);
    return plist;
}

int main(int ac, const char **av) {
    CFPropertyListFormat format;
    CFURLRef url = NULL;
    NSMutableDictionary *plist;

    plist = (NSMutableDictionary *)LoadPropertyList(&url, av[1], &format);
    RET_IF(plist == NULL,-1, "error loading %s\n", av[1]);

	for (NSString *s in [plist keyEnumerator]) {
		NSString *v = (NSString *)[plist objectForKey:s];
		fprintf(stdout, "\"%s\" = \"%s\";\n", [s UTF8String], [v UTF8String]);
	}
    return 0;
}
// vim: set ft=objc §ts=4 expandtab
