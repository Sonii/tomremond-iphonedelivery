/** 
 2011 - F. Guillemé
 Copyright (C) 
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
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "unpack.h"
#include "debug.h"

/*
 * @brief unpack data coded in ascii represetation of hexadecimal
 * 
 * @param p string to unpack
 * @param pn pointer to length of resulting data
 * 
 * @return the data or NULL in case of error
 */
uint8_t *unpack(const char *p, size_t *pn) {
	uint8_t *data = malloc(strlen(p) / 2);
	size_t i = 0;

	for (; *p && *p != 0x1A; i++) {
		unsigned n = 0;
		if (sscanf(p, "%02x", &n) != 1) {
			LOG("unpacking failed at %d", (int)i);
			free(data);
			*pn = 0;
			return NULL;
		}
		p+=2;
		data[i] = n;
	}
	*pn = i;
	return data;
}

/** 
 * @brief pack binary data to an ascii representation of its hex
 * 
 * @param data to pack
 * @param n length of data
 * 
 * @return resulting strinf
 */
char *pack(const uint8_t *data, size_t n) {
	char *str = malloc(n * 2 + 1);

	if (str != NULL) {
		for (int i = 0; i < n; i++) {
			sprintf(&str[2*i], "%02x", data[i]);
		}
		str[2 * n] = 0;
	}
	return str;
}
// vim: set ts=4 expandtab
