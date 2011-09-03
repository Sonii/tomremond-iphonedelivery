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
#include <stdarg.h>
#include <sys/types.h>
#include <unistd.h>
#include <time.h>
#include <stdbool.h>
#include <sqlite3.h>

#import <UIKit/UIKit.h>

#import <CoreFoundation/CoreFoundation.h>

#define SMS_DB "/private/var/mobile/Library/SMS/sms.db"
#define AB_DB "/private/var/mobile/Library/AddressBook/AddressBook.sqlitedb"
#define MAX_STR_SIZE 128

#if !defined(DEBUG) && !defined(YESDEBUG)
#define NSLog(...) 
#endif

enum {
    PARAM_INT,
    PARAM_STR
}; 

/** 
 * @brief remove the international prefix from a number
 * 
 * @param number to process
 * 
 * @return retulting number without the prefix
 */
static const char *trim_international_prefix(const char *num) {
    // 1
    // 20 21X 22X 23X ... 27 28..29
    // 30 -> 34 35X 36 37X 38X 39
    // 40 41 43 -> 49 42X
    //  etc..
    if (num[0] == '+') {
        switch (num[1]) {
            case '1':
                num += 2; // skip +1
                break;
            case '2':
                if (num[2] == '7')
                    num += 3;
                else
                    num += 4;
                break;
            case '3':
                if (num[2] >= '5' && num[2] <= '8')
                    num += 4;
                else
                    num += 3;
                break;
            case '4':
                if (num[2] == '2')
                    num += 4;
                else
                    num += 3;
                break;
            case '5':
                if (num[2] == '0' || num[2] == '9')
                    num += 4;
                else
                    num += 3;
                break;
            case '6':
                if (num[2] < '7')
                    num +=3;
                else
                    num += 4;
                break;
            case '7':
                num += 2;
                break;
            case '8':
                if ((num[2] >= '1'  && num[2] <= '4') || num[2] == '6')
                    num += 3;
                else
                    num += 4;
                break;
            case '9':
                if (num[2] < '6' || num[2] == '8')
                    num += 3;
                else
                    num += 4;
                break;
            default:
                NSLog(@"bad international code\n");
                break;
        }
    }
    return num;
}

/** 
 * @brief from a fully qualified phone number, build a pattern to be used in a SQL like clause
 * 
 * @param fully quaalified number 
 * 
 * @return the pattern to be used in the like clause
 */
static const char *build_phone_number_pattern(const char *num) {
    int i;
    static char str2[64];

    num = trim_international_prefix(num);

    str2[0] = 0;
    for (i = 0; num[i] != 0 && strlen(str2) < sizeof(str2); i++) {
        snprintf(str2 + strlen(str2), sizeof(str2) - strlen(str2) - 1, "%%%c", num[i]);
    }
    return str2;
}

static void my_sqlite3_read(sqlite3_context*context, int argc, sqlite3_value **argv) {
      sqlite3_result_int(context, (sqlite3_value_int(argv[0]) & 2) >> 1);
}

/** 
  SQL command on the SMS database
 * 
 * @param db 
 * @param ro 
 * @param sql 
 * @param list of parameters (printf like) to build the command
 * 
 * @return 
 */
static int run_sql(const char *db, bool ro, const char *sql, ...) {
    va_list va;
    const char *dummy;
    sqlite3 *h;
    sqlite3_stmt *stmt = NULL;
    int rc;
    void *addr;
    const char *str;

    va_start(va, sql);
    addr = va_arg(va, void *);

    rc = sqlite3_open_v2(db, &h, ro ? SQLITE_OPEN_READONLY : SQLITE_OPEN_READWRITE, NULL);
    if (rc != SQLITE_OK)  goto fail;

    NSLog(@"%s: query = %s\n", __FUNCTION__, sql);

    if (ro == false) {
        rc = sqlite3_create_function(h, "read", 1, SQLITE_UTF8, NULL, my_sqlite3_read, NULL, NULL);
        if (rc != SQLITE_OK) goto fail;
    }

    rc = sqlite3_prepare(h, sql, -1, &stmt,  &dummy);
    if (rc != SQLITE_OK)  goto fail;

    for (bool done = false; done == false; ) {
        rc = sqlite3_step(stmt);
        switch (rc) {
        case SQLITE_BUSY:
        case SQLITE_ERROR:
        case SQLITE_MISUSE:
            NSLog(@"%s\n", sqlite3_errmsg(h));
        default:
            rc = -1;
            done = true;
            break;

        case SQLITE_ROW:
            if (addr == NULL) {
                NSLog(@"%s SQLITE_ROW but no more storage argument\n", __FUNCTION__); 
            }
            for (int column = 0; addr != NULL; column++) {
                int type = va_arg(va, int);
                switch (type) {
                    case PARAM_INT:
                        *(int *)(addr) = sqlite3_column_int(stmt, column);
                        NSLog(@"COL %d => %d\n", column, *(int *)(addr));
                        break;
                    case PARAM_STR:
                        str = (const char *)sqlite3_column_text(stmt, column);
                        NSLog(@"COL %d => \"%s\"\n", column, (str != NULL ? str : NULL));
                        if (str != NULL)
                            strncpy((char*)addr, str, MAX_STR_SIZE);
                        else
                            *(char *)addr = 0;
                        break;
                    default:
                        NSLog(@"%s: unknown %d\n", __FUNCTION__, type);
                        addr = NULL;
                        break;
                }
                if (addr != NULL) addr = va_arg(va, void *);
            }
            break;
        case SQLITE_DONE:
			rc = 0;
            if (addr != NULL) {
                NSLog(@"%s: SQLITE_DONE storage no result\n", __FUNCTION__);
				rc = -1;
			}
            done = true;
            break;
        }
    }
ok:
    if (stmt != NULL) sqlite3_finalize(stmt);
    sqlite3_close(h);
	NSLog(@"SQL RUN returned %d", rc);
    return rc;
fail:
    NSLog(@"SQL Error %s\n", sqlite3_errmsg(h));
	goto ok;
}

/** 
 * @brief execute a sql command that mody the db as an update
 * 
 * @param query 
 * @param ... 
 * 
 * @return the result of the SQl execution
 */
int exec_sql(const char *query, ...) {
    va_list va;
    int res; 
    char tmp[512];
    va_start(va, query);
    vsnprintf(tmp, sizeof(tmp), query, va);
    res = run_sql(SMS_DB, false, tmp, /* no return value */ NULL);
    va_end(va);
    return res;
}

/** 
 * @brief set the smsc_ref of the last sms sent to a particular number
 *        NOTE it may set the wrong SMS if too many SMS are sent to a particular number or
 *             if the network is loaded. 
 *             This is the tricky phase and in some (rare??) case the wrong SMS might be selected
 * 
 * @param num 
 * @param ref 
 * 
 * @return  the SQL result or -1 in error
 */
int set_ref_for_last_sent_sms(const char *num, uint8_t ref) {
    const int delay = 120;            // the last 120 seconds (it might be too long...)
    time_t now = time(NULL);
	char *p;

	// get a list of sent MS to this destination and still not acknowledged
    asprintf(&p, "select ROWID from message "
				 "where address like '%s' and date > %d and smsc_ref is null and "
				 "      delivery_status is null and flags != 2 and flags != 0"
				 "      order by ROWID",
                  build_phone_number_pattern(num),  (int)(now - delay));

	if (p != NULL) {
		int rowid = 0, rowid1 = 0;
		int rc;

		// the idea is to get the first SMS sent to a destination recently that has no smsc_ref
		rc = run_sql(SMS_DB, true, p, &rowid, PARAM_INT, &rowid1, PARAM_INT, NULL);
		if (rowid == 0) NSLog(@"no sent SMS found for %s", num);
		if (rowid1 != 0) NSLog(@"several SMS sent to %s in 120 sec still waiting for a status. Choose the first", num);
		free(p);

		return rowid != 0 ? exec_sql("update message set smsc_ref=%d where ROWID = %d ", ref, rowid) : -1;
	}
	return -1;
}

/** 
 * @brief get the sent time for a given destination and smsc ref
 *        hopefully only one SMS must be selected but in a broken database...
 * 
 * @param num 
 * @param ref 
 * 
 * @return 
 */
int get_sent_time_for_sms(const char *num, uint8_t ref) {
	char *p = NULL;
	int rc = 0;
	int n = 0;

    asprintf(&p, 
            "select date from message where address like '%s' and smsc_ref = %d",
            build_phone_number_pattern(num),  ref);
	if (p != NULL) {
		n = -1;
		rc = run_sql(SMS_DB, true, p, &n, PARAM_INT, NULL);
		free(p);
	}
	return n;
}

/** 
 * @brief update a SMS. As above only one SMS should be selected
 *        after a delivery report has been received or in case of a permanent error
 *        the database entry has at least s_date and delivery status set.
 *        If the SMS was delivered  correctly then smsc_ref is null, s_dateand r_date are set to the smsc dates
 *        and delivery_status is zero
 * 
 * @param num 
 * @param ref 
 * @param status 
 * @param s_date 
 * @param d_date 
 * 
 * @return 
 */
int update_sms_for_delivery(const char *num, uint8_t ref, uint8_t status, time_t s_date, time_t d_date) {

    return exec_sql("update message set smsc_ref=null, delivery_status=%d, s_date=%lu, r_date=%lu " 
					"where address like '%s' and smsc_ref=%d",
                    status, s_date, d_date, 
					build_phone_number_pattern(num), ref);
}

int get_status_for_rowid(uint8_t rowid) {
	char *p = NULL;
	int rc = 0;
	int status = 0, ref = 0;

    asprintf(&p, 
            "select delivery_status, smsc_ref from message"  
			"where ROWID=%d and (delivery_status is not null or smsc_ref is not null",
            rowid);
	if (p != NULL) {
		rc = run_sql(SMS_DB, true, p, &status, PARAM_INT, &ref, PARAM_INT, NULL);
		if (rc == SQLITE_OK) {
			if (ref != 0)
				rc = -2;
			else
				rc = status;
		}
		else rc = -1;
		free(p);
	}
	return rc;
}

int get_delivery_info_for_rowid(uint8_t rowid, int *pref, time_t *pdate, int *pdelay, int *pstatus) {
	char *p = NULL;
	int rc = 0;
	int status = 0, ref = 0;
	time_t date, s_date, r_date;

	*pstatus = 1003;
    asprintf(&p, 
            "select smsc_ref, delivery_status, date, s_date, r_date from message "
			"where ROWID=%d and flags != 0 and flags != 2 and flags < 32",
            rowid);
	if (p != NULL) {
		rc = run_sql(SMS_DB, true, p, &ref, PARAM_INT, &status, PARAM_INT, &date, PARAM_INT, &s_date, PARAM_INT,
				&r_date, PARAM_INT, NULL);
		if (rc == SQLITE_OK) {

			// this is a huge mess...
			*pref = ref == 0 ? -1 : ref;
			*pdate = date;
			if (s_date == 0 || r_date == 0) {
				if (status < 0) *pstatus = 1000;
				*pdelay = -1;
			}
			else {
				*pdelay = (r_date - s_date);
			}
			if (status != 0 || (ref == 0 && s_date != 0 && r_date != 0))
				*pstatus = status;
			else if (status == 0)
				*pstatus = 1001;
			if (ref == 0 && s_date == 0 && r_date == 0) {
				if (*pstatus >= 1000) *pstatus = 1002;
				rc = -1;
			}
			else
				rc = 0;
		}
		else
			*pstatus = 1004;
	}
	return rc;
}

/** 
 * @brief convert a phone numbr to a contact name
 * 
 * @param numner in asci
 * 
 * @return the name if it was found in the AB or the number otherwise. It is a static buffer so it wiill be modified at the next
 * invocaion
 */
bool convert_num_to_name(const char *num, char *name, char *surname) {
	char tmp[256];

    snprintf(tmp, sizeof(tmp), "select First,Last from ABPerson,ABMultiValue "
                               "where ROWID=record_id and property=3 and value like '%s'",
            build_phone_number_pattern(num));
    
    name[0] = surname[0] = 0;

    return run_sql(AB_DB, true, tmp, surname, PARAM_STR, name, PARAM_STR, NULL) == 0;
}

// vim: set ts=4 expandtab
