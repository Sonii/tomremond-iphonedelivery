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
#include <stdio.h>
#include <stddef.h>
#include <unistd.h>
#include <time.h>
#include <string.h>

typedef unsigned char uint8_t;

#include "utils.h"
#include "debug.h"

/** 
 * @brief extract the phone number rom the PDU
 * 
 * @param p point to the first char
 * @param n length of the data
 * @param s buffer to tore the phone number
 */
void xtract_phone_number(const uint8_t *p, int n, char *s) {
	uint8_t tp = *p++;

	if (tp == 0x91) {
		*s++ = '+';
	}

	n = ( n + 1) / 2;
	for (int i = 0; i < n; i++) {
		uint8_t c = *p++;
		*s++ = '0' + (c & 15);
		if (c < 0x99) *s++ = '0' + ((c >> 4) & 15);
	}
	*s++ = 0;
}

static inline uint8_t swapbcd(uint8_t val) {
	return (val & 0xF) * 10 + ((val >> 4) & 0x0F);
}

/** 
 * @brief extract the time from the 7 char PDU representation
 * 
 * @param p the 7 char string
 * 
 * @return the time in secs from 1970 (standart time)
 */
time_t xtract_time(const uint8_t *p) {
	struct tm tm;

	memset(&tm, 0, sizeof(tm));

	tm.tm_year = 100 + swapbcd(p[0]);
	tm.tm_mon = swapbcd(p[1]) - 1;
	tm.tm_mday = swapbcd(p[2]) ;
	tm.tm_hour = swapbcd(p[3]);
	tm.tm_min = swapbcd(p[4]);
	tm.tm_sec = swapbcd(p[5]);

   // take care of the timezone
    int tz = p[6];
    if (tz & 0x80) {
        tz = (tz & ~0x80);
        tz = - swapbcd(tz);
    }
    else
        tz = swapbcd(tz);

	tm.tm_gmtoff = 3600 * tz / 4;

	return mktime(&tm);
}

// vim: set ts=4 expandtab
