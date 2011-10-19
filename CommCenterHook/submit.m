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
#include "submit.h"
#include "notify.h"
#include "unpack.h"
#include "utils.h"

extern char last_number[32];

uint8_t *unpack_if_applicable(const char *message) {
	int index = 0;
	size_t size = 0;
	uint8_t *payload;
	
	payload = unpack(message, &size);
	if (payload == NULL) return NULL;

	DUMP(payload, size, "Check SUBMIT %d", size);
			
	// Check if it is a submit
	if (!(payload[0] == 0 && (payload[1] & 0x01))) {
		free(payload);
		return NULL;
	}

	bool has_ud = payload[1] & (1 << 6); 
	// it has a UDH so we need to check it to find if it is the last fragment
	uint8_t tp_vpf = (payload[1] & 0x18) >> 3;

	index++;	// skip SMSC length
	index++;	// skip command
	index++;	// skip ref
	uint8_t len = payload[index++];				// phone number length
	uint8_t len1 = 1 + (len + 1) / 2;			// pad to pair
	if (len1 > 16) {
		LOG("Incorrect phone number length");
		free(payload);
		return NULL;
	}
	xtract_phone_number(payload+index, len, last_number);
	LOG("to = %s", last_number);

	index += len1;		// skip phone number

	// if the message has no user data header it is applicable
	// we wait until here so we can  get the phone number
	if (has_ud == false) return payload;

	index += 2;
	
	// Validity period duration
	switch (tp_vpf) {
	case 0: index++; break;
	case 2: index+=2; break;
	default: index+=8; break;
	}

	// payload data
	index++;									// skip udhl
	if (payload[index++] != 0) return payload;		// it is not a concatenation so we assume true
	index+=2;

	uint8_t nfrag = payload[index++];
	uint8_t num = payload[index++];

	LOG("Fragment %d/%d", num, nfrag);

	if (num == nfrag)
		return payload;
	else {
		last_number[0] = 0;
		free(payload);
		return NULL;
	}
}

void set_delivery_report(uint8_t *payload) {
	payload[1] |= (1 << 5);
}

static int16_t get_first_char(uint8_t *payload, uint8_t **coding, uint8_t *plen) {
	bool has_ud = payload[1] & (1 << 6); 
	uint8_t tp_vpf = (payload[1] & 0x18) >> 3;

	payload++;		// SMSC length. must be zero
	payload++;		// command		
	payload++;		// ref
	payload += (1 + 1 + (payload[0] + 1)/2);		// number

	*coding = payload;

	payload += 2;
	
	// Validity period duration
	switch (tp_vpf) {
	case 0: break;				// no period means default
	case 2: payload+=1; break;	// 1 byte period
	default: payload+=7; break;	// 7 bytes period
	}

	*plen = *payload++;	// skip the message length

	// payload data
	if (has_ud) payload += payload[0];

	switch (((*coding)[1] & 0x0C) >> 2) {
	case 0:
		return payload[0] & 0x7f;	// we should consider the blank having the value zero in this charset
	case 1:
		return payload[0];
	case 2:
		return (payload[0] << 8) | payload[1];
	case 3:
		return payload[0];		// I don't think this case occurs
	}
	return 0;
}

static void set_first_char(uint8_t *payload, char c) {
	bool has_ud = payload[1] & (1 << 6); 
	uint8_t tp_vpf = (payload[1] & 0x18) >> 3;
	uint8_t *coding;

	payload++;		// SMSC length. must be zero
	payload++;		// command		
	payload++;		// ref
	payload += (1 + 1 + (payload[0] + 1)/2);		// number

	coding = payload;

	payload += 2;
	
	// Validity period duration
	switch (tp_vpf) {
	case 0: break;				// no period means default
	case 2: payload+=1; break;	// 1 byte period
	default: payload+=7; break;	// 7 bytes period
	}

	payload++;	// skip the message length

	// payload data
	if (has_ud) payload += payload[0];

	switch (((coding)[1] & 0x0C) >> 2) {
	case 0:
		payload[0] = (c & 0x7f) | (payload[0] & 0x80);
		break;
	case 1:
		payload[0] = c;
		break;
	case 2:
		payload[0] = 0; payload[1] = c;
		break;
	case 3:
		payload[0] = c;		// I don't think this case occurs
		break;
	}
}

void set_class0(uint8_t *payload) {
	uint8_t *coding = NULL;
	uint8_t len = 0;
	if (get_first_char(payload, &coding, &len) == '!' && coding != NULL) {
		coding[1] |= 0x10;
		set_first_char(payload, ' ');
	}
}

void set_invisible(uint8_t *payload) {
	uint8_t *coding = NULL;
	uint8_t len = 0;
	if (get_first_char(payload, &coding, &len) == ' ' && len == 1 && coding != NULL) coding[0] = 0x40;
}

bool unset_class0(uint8_t *payload) {
	bool rc = false;
	int index = payload[0] + 2;
	uint8_t l = payload[index++];
	l = 1 + ( l + 1) / 2;
	index += l;

	// index is now the offset of TP-PID TP-DCS
	if ((payload[index] & 0x40) == 0 && 			// not invisible
		 (payload[index + 1] & 0x10) && 			// class 0
		 filter_class0()) {
		payload[index + 1] &= ~0x10;
		rc = true;
	}
	return rc;
}
// vim: set ts=4 expandtab
