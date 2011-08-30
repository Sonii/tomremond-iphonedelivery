/*
 Copyright (C) 2011 - F. Guillemé
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
#include <unistd.h>
#include <fcntl.h>
#include <stdarg.h>

#import <Foundation/Foundation.h>
#include "debug.h"

#ifdef DEBUG
void DUMP(const uint8_t *p, size_t n, const char *label, ...) {
    va_list va;
    va_start(va, label);

    if (label != NULL) {
        vfprintf(stderr, label, va);
		fprintf(stderr, "\n");
	}

    if (p != NULL && n > 0)  {
		char hex[16*3+1+1], asc[16+1];
		int col = 0;
		int row = 0;

		for (size_t i = 0; i < n ; i++) {
			unsigned char c = p[i];
			sprintf(hex + 3 * col, "%02X ", c);
			if (c < ' ' || c > 0x7f) c = '.';
			sprintf(asc + col, "%c", c);

			if (++col == 16 || i+1 == n) {
				memset(hex + col * 3, ' ', (16 - col) * 3);
				hex[16 * 3] = 0;
				fprintf(stderr, "%04X: %s| %s\n", row * 16, hex, asc);
				col = 0;
				if (row++ > 4 && i+ 1 < n) {
					fprintf(stderr, "... %u bytes not shown\n", (unsigned)(n - i));
					break;
				}
			}
		}
	}
    va_end(va);     // noop
}

void TRACE(const char *p, size_t n, const char *label, ...) {
    va_list va;
    va_start(va, label);

    if (label != NULL) {
        vfprintf(stderr, label, va);
		fprintf(stderr, "\n");
	}
    if (p != NULL && n > 0)  {
		char s[256], *str = s;

		s[0] = 0;
		for (size_t i = 0; i < n ; i++) {
			unsigned char c = p[i];

			str = s + strlen(s);
			if (str - s > sizeof(s) - 1) {
				fprintf(stderr, "%s", s);
				str = s;
				s[0] = 0;
			}

        	switch (c) {
        	case '\r':
				sprintf(str, "<CR>");
            	break;
        	case '\n':
				sprintf(str, "<LF>");
            	break;
        	case '\t':
				sprintf(str, "<TAB>");
            	break;
        	case 32 ... 126:
				sprintf(str, "%c", c);
            	break;
        	default:
				sprintf(str, "<0x%02X>", c);
            	break;
        	}
    	}
		fprintf(stderr, "%s\n", s);
	}

    va_end(va);     // noop
}
#endif
// vim: set ts=4 expandtab
