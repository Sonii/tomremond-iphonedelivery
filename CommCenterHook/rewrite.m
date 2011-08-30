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
#include <unistd.h>
#include <fcntl.h>
#import <Foundation/Foundation.h>

#include "debug.h"
#include "utils.h"
#include "rewrite.h"
 
/** 
 * @brief rewrite a CDS to an empty and invisible CMT
 *        empty because we don´t care about the content
 *        and invisible because we don't wanr the user to see it but it must be well formed so the upper layer will be happy
 * 
 * @param payload 
 * @param n  length of the cds payload
 * @param pn receiving total length of the final payload
 * @param offset to the start of the nessage (end of the payload anyway)
 * 
 * @return a pointer to the CMT payload 
 */
uint8_t *rewrite_cts(uint8_t *payload, size_t n, size_t *pn, int *offset) {
	uint8_t *p = malloc(256);
	int index1 = 0, index2 = 0;

	// SMSC length + address
	memcpy(&p[0], &payload[0], payload[0] + 1);
	index1 = index2 = payload[0] + 1;

	p[index1++] = 4; index2++;		// SM-DELIVER

	index2++;	// skip ref

	// copy phone number
	uint8_t l = p[index1++] = payload[index2++];
	l = 1 + ( l + 1) / 2;
	memcpy(&p[index1], &payload[index2], l);
	index1 += l;
	index2 += l;

	// set encoding and class type
	p[index1++] = 0x40;		// invisible
	p[index1++] = 0x00;

	// just copy the delivery date
	memcpy(&p[index1], &payload[index2], 7);
	index1 += 7; index2 += 14;

    p[index1] = 0;

	*offset = index1 + 1;
	*pn = index1 + p[index1] + 1;

	DUMP(p, *pn, "rewritten CMT payload len = %d", *pn);
	return p;
}
// vim: set ts=4 expandtab
