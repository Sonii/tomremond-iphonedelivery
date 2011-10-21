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
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#import <arpa/inet.h>
#include <stdarg.h>

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#include <CFNetwork/CFSocketStream.h>

#include "utils.h"
#include "debug.h"
#include "unpack.h"
#include "notify.h"
#include "submit.h"
#include "rewrite.h"

#ifndef USES_MS
#define MSHook(type,name,param...) static type __ ## name(param)
#define _open open
#define _close close
#define _read read
#define _write write

static int __open(char *name, int flags, ...);
static int __close(int fd);
static size_t __read(int fd, void *p, size_t n); 
static size_t __write(int fd, void *p, size_t n); 

struct interpose {
        void *newf;
        void *oldf;
} interposers[] __attribute((section("__DATA, __interpose"))) = {
		{       (void*)__open, (void*)open },
        {       (void*)__close, (void*)close },
        {       (void*)__read, (void*)read },
        {       (void*)__write, (void*)write },
};

#else
#include <substrate.h>
#endif

static int sms_fd = -1;

char last_number[32];
static time_t last_time_stamp;

#ifdef  MONITOR
static CFSocketRef spy_socket = nil;
static int spy_fd = -1;

static void CallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
	if (kCFSocketAcceptCallBack == type) { 
		CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
		struct sockaddr_in peerAddress;
		socklen_t peerLen = sizeof(peerAddress);
		NSString * peer = nil;

		if (getpeername(nativeSocketHandle, (struct sockaddr *)&peerAddress, (socklen_t *)&peerLen) == 0) {
			peer = [[NSString alloc] initWithUTF8String:inet_ntoa(peerAddress.sin_addr)];
		}
		NSLog(@"connected from %@ socket %d", peer, nativeSocketHandle);
		spy_fd = nativeSocketHandle;
		[peer release];
	}
}

static void create_spy() {
	uint16_t chosenPort = 0;
	struct sockaddr_in serverAddress;
	socklen_t nameLen = sizeof(serverAddress);

	spy_socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 
								kCFSocketAcceptCallBack,
								(CFSocketCallBack)&CallBack, NULL);

	if (spy_socket == NULL) {
		NSLog(@"SocketCreate error %s:%d", __FUNCTION__, __LINE__);
		return;
	}

	int yes = 1;
	setsockopt(CFSocketGetNative(spy_socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));

	memset(&serverAddress, 0, sizeof(serverAddress));
	serverAddress.sin_len = sizeof(serverAddress);
	serverAddress.sin_family = AF_INET;
	serverAddress.sin_port = htons(12345);
	serverAddress.sin_addr.s_addr = htonl(INADDR_ANY);
	NSData * address4 = [[NSData alloc] initWithBytes:&serverAddress length:nameLen];

	if (kCFSocketSuccess != CFSocketSetAddress(spy_socket, (CFDataRef)address4)) {
		NSLog(@"SetAddress error: %s:%d", __FUNCTION__, __LINE__);
		CFRelease(spy_socket);
		spy_socket = NULL;
		[address4 release];
		return;
	}
	[address4 release];

	// now that the binding was successful, we get the port number 
	// -- we will need it for the NSNetService
	NSData * addr = (NSData*)CFSocketCopyAddress(spy_socket);
	memcpy(&serverAddress, [addr bytes], [addr length]);
	[addr release];

	chosenPort = ntohs(serverAddress.sin_port);

	// set up the run loop sources for the sockets
	CFRunLoopRef cfrl = CFRunLoopGetMain();
	CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, spy_socket, 0);
	CFRunLoopAddSource(cfrl, source, kCFRunLoopCommonModes);
	NSLog(@"##################### Socket on port %d created", chosenPort);
	CFRelease(source);
}

static void forward_spy(bool dir, const uint8_t *p, size_t n) {
	if (spy_fd > 0) {
		char tmp[8];

		write(spy_fd, dir ? "> " : "< ", 3);

		for (int i = 0; i < n; i++) {
			switch (p[i]) {
			case '\r': write(spy_fd, "<CR>", 4); break;
			case '\n': write(spy_fd, "<LF>", 4); break;
			case ' ' ... 0x7f: write(spy_fd, &p[i], 1); break;
			default:
				sprintf(tmp, "<0x%02X>", p[i]);
				write(spy_fd, tmp, strlen(tmp));
				break;
			}
		}
		write(spy_fd, "\n", 1);
	}
}
#else
static inline void create_spy() {}
static inline void forward_spy(bool dir, const uint8_t *p, size_t n) {}
#endif

/** 
 * @brief hook open. we just check the path and store the fd when it's SMS path
 * 
 * @param int 
 * @param open 
 * @param name 
 * @param mode 
 */
MSHook(int, open, char *name, int oflag, ...) {
	va_list va;
	mode_t mode = 0;
	va_start(va, oflag);

	if (oflag & O_CREAT) mode = va_arg(va, int);
	va_end(va);

	int ret = _open(name, oflag, mode);
	if (strcmp(name, "/dev/dlci.spi-baseband.sms") == 0) {
		notify_started();
		create_spy();
		sms_fd = ret;
	}
	//LOG("open(\"%s\", 0x%x) => %d", name, mode, ret);	
	return ret;
}

/** 
 * @brief same for close
 * 
 * @param int 
 * @param close 
 * @param fd 
 */
MSHook(int, close, int fd) {
	int ret = _close(fd);
	if (fd == sms_fd) sms_fd = -1;
	//LOG("close(%d) => %d", fd, ret);
	return ret;
}

/** 
 * @brief on read we monitor what is coming
 *           +CDS: it is a delivery report. process it and send a message to the SpringBoard 
 *                 so it can notify the user and change the db
 *           +CMGS: it is the response to CMGS so we need the ref. Anyway it is s nice to
 *                 notify the Springboard to it can save it in the db
 *           +CMT: it may be useful the future to process it
 * 
 * @param size_t 
 * @param read 
 * @param fd 
 * @param p 
 * @param n 
 */
MSHook(size_t, read, int fd, void *p, size_t n) {
	size_t ret = _read(fd, p, n);
	if (ret != -1 && ret <= n && sms_fd != -1 && sms_fd == fd) {
		int ref;
		int len;
		char buffer[256];

		TRACE(p, ret, "read(sms, %d) => %d", n, ret);

		forward_spy(false, p, ret);

		if (sscanf(p, "\r\n+CDS: %d\r\n%s\r\n", &len, buffer) == 2) {
			char number[32];
			size_t size;
			uint8_t *payload = unpack(buffer, &size);
			uint8_t ref = payload[payload[0] + 2];
			time_t when_delivered = 0, when_sent = 0;
			uint8_t status;

			DUMP(payload, size, "Received a CDS ref = %d", ref);

			int index = 1 + payload[0];
			xtract_phone_number(&payload[index+ 3], payload[index + 2], number);
			index += ((payload[index + 2] + 1) / 2 + 1 + 2 + 1);

			when_sent = xtract_time(&payload[index]);
			when_delivered = xtract_time(&payload[index + 7]);
			status = payload[index+14];

			// rewrite the report int a nice looking message
			size_t new_size = 0;
			int offset;
			uint8_t *new_payload = rewrite_cts(payload, size, &new_size, &offset);
			free(payload);

			notify_report(ref, when_sent, when_delivered, number, status, payload, size);
			
			if (new_payload != NULL) {
				char *serialized_payload = pack(new_payload, new_size);
				if (serialized_payload != NULL) {
					sprintf(p, "\r\n+CMT: ,%d\r\n%s\r\n", (int)(new_size - offset + 19), serialized_payload);
					free(serialized_payload);
					ret = strlen(p);
					TRACE(p, ret, "new payload");
				}
				else {
					LOG("failed to serialized the new payload");
				}
				free(new_payload);
			}
		}
		else if (sscanf(p, "\r\n+CMGS: %d", &ref) == 1) {
			TRACE(p, ret, "read(sms, %d) => %d", n, ret);
			if (last_number[0] && last_time_stamp) {
				notify_submit(ref, last_time_stamp, last_number);

				last_number[0] = 0;
				last_time_stamp = 0;
			}
		}
#if 0
		else if (sscanf(p, "\r\n+CMT: ,%d\r\n", &len) == 1) {
			char *b = strchr(p + 2, '\r');
			if (b != NULL) {
				TRACE(p, ret, "read(sms, %d) => %d", n, ret);
				size_t size;
				uint8_t *payload = unpack(b + 2, &size);
				if (payload != NULL) {
					//notify_received(payload, size);
					if (unset_class0(payload)) {
						char *new_str = pack(payload, size);
						if (new_str != NULL) {
							memcpy(b + 2 , new_str, strlen(new_str));
							free(new_str);
							TRACE(p, ret, "new payload");
						}
					}
					free(payload);
				}
			}
		}
#endif
	}
	return ret;
}

/** 
 * @brief hook the write. on CMGS set the report flag
 *        but on concateneted SMS we must set it only on the last fragment
 *        Also process he ! to make a flash SMS ans <space> o make it invisible
 * 
 * @param size_t 
 * @param write 
 * @param fd 
 * @param p 
 * @param n 
 */
MSHook(size_t, write, int fd, void *p, size_t n) {
	static bool cmgs_seen = false;
	if (sms_fd != -1 && sms_fd == fd) {
		int dummy;
		TRACE(p, n, "write(sms, %d)", n);
		if (cmgs_seen) {
			TRACE(p, n, "write(sms, %d)", n);
			// in some case an "at" command comes out. so we can safely ignore it
			if (memcmp(p, "at+", 3) != 0) {
				uint8_t *payload = unpack_if_applicable(p); 
				if (payload != NULL) {
					last_time_stamp = time(NULL);

					LOG("PATCH SUBMIT");
					set_delivery_report(payload);
					set_class0(payload);
					set_invisible(payload);

					DUMP(payload, n / 2, "New payload");

					char *new_str = pack(payload, n / 2);

					if (new_str == NULL) 
						LOG("Failed to patch....(allocation error)");
					else  {
						// replace by the new payload
						// the string length must have not changed
						if (strlen(new_str) != n - 1) 
							LOG("Error new playload has not the correct length %lu => %lu", n - 1, strlen(new_str));
						else
							memcpy(p, new_str, n - 1);
						free(new_str);
					}
					free(payload);
					TRACE(p, n, "new payload");
				}
				cmgs_seen = false;
			}
		}
		else if (sscanf(p, "at+cmgs=%d", &dummy)) {
			cmgs_seen = report_enabled();
		}
		else {
			cmgs_seen = false;
		}
	}
	forward_spy(true, p, n);
	return _write(fd, p, n);
}

#ifdef USES_MS
extern void idccInitialize() {
	LOG("iPhoneDelivery %s %s", __DATE__, __TIME__);
	MSHookFunction((void*)open, (void*)$open, (void**)&_open);
	MSHookFunction((void*)close, (void*)$close, (void**)&_close);

	MSHookFunction((void*)read, (void*)$read, (void**)&_read);
	MSHookFunction((void*)write, (void*)$write, (void**)&_write);
}
#endif
// vim: set ts=4 expandtab
