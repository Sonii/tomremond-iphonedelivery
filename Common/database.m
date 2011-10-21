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
	PARAM_END,
    PARAM_INT,
    PARAM_STR,
	PARAM_LOOP,
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
	else if (num[0] == '0')
		num++;		// skip leading 0 if it is a local number
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
    int rc = -1;

	va_list loop_start = NULL;
	int loop_count;

    va_start(va, sql);

    rc = sqlite3_open_v2(db, &h, ro ? SQLITE_OPEN_READONLY : SQLITE_OPEN_READWRITE, NULL);
    if (rc != SQLITE_OK)  goto fail;

    NSLog(@"%s: query = %s\n", __FUNCTION__, sql);

    if (ro == false) {
        rc = sqlite3_create_function(h, "read", 1, SQLITE_UTF8, NULL, my_sqlite3_read, NULL, NULL);
        if (rc != SQLITE_OK) goto fail;
    }

    rc = sqlite3_prepare(h, sql, -1, &stmt,  &dummy);
    if (rc != SQLITE_OK)  goto fail;

	int nrow = 0;
    int type = va_arg(va, int);
	if (type == PARAM_LOOP) {
		loop_count = va_arg(va, int);
		nrow = 0;
		loop_start = va;
		type = va_arg(va, int);
	}
    for (bool done = false; done == false; ) {
retry:
        rc = sqlite3_step(stmt);

		if (type == PARAM_END) {
			if (loop_start == NULL) {
				NSLog(@"no more storage exit" );
				rc = nrow;
				break;
			}
			
			if (nrow >= loop_count) {
				NSLog(@"All items in loop were retrieved");
				rc = nrow;
				break;
			}
			va = loop_start;		// rewind
			type = va_arg(va, int);
		}

        switch (rc) {
        case SQLITE_BUSY:
        case SQLITE_ERROR:
        case SQLITE_MISUSE:
        default:
            NSLog(@"%s\n", sqlite3_errmsg(h));
            rc = -1;
            done = true;
            break;

        case SQLITE_ROW:
			nrow++;
            for (int column = 0; /* break when it finds a PARAM_eND */; column++) {
                switch (type) {
				case PARAM_END:
					// the list of receiver is incomplete recover as we can
					goto retry;

                case PARAM_INT: 
					do {
						int *addr = va_arg(va, int *);
						
						if (loop_start != NULL) addr += (nrow - 1);
                        *addr = sqlite3_column_int(stmt, column);
                        NSLog(@"COL %d => %d\n", column, *addr);
                    } while(0);
					break;

                case PARAM_STR:
					do {
						const char *str;
						char **addr = va_arg(va, char **);

						if (loop_start != NULL) addr += (nrow - 1);
                        str = (const char *)sqlite3_column_text(stmt, column);
                        if (str != NULL)
							*addr = strdup(str);
                        else
                            *addr = NULL;
                        NSLog(@"COL %d => \"%s\"\n", column, *addr);
					} while (0);
                    break;

                default:
                    NSLog(@"%s: unknown data type %d\n", __FUNCTION__, type);
                    break;
				}
        		type = va_arg(va, int);
            }
            break;
        case SQLITE_DONE:
            NSLog(@"%s: SQLITE_DONE storage no more result\n", __FUNCTION__);
			rc = nrow;
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

	if (rc > 0) rc = -1;
	goto ok;
}

/** 
 * @brief execute a sql command that modifies the db as an update
 * 
 * @param query 
 * @param ... 
 * 

 */
int exec_sql(const char *query, ...) {
    va_list va;
    int res = -1; 
    char *p = NULL;

    va_start(va, query);
    vasprintf(&p, query, va);
	if (p != NULL) {
    	res = run_sql(SMS_DB, false, p, PARAM_END);
		free(p);
	}
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
		int rowid[2];
		int rc;

		// the idea is to get the first SMS sent to a destination recently that has no smsc_ref
		rc = run_sql(SMS_DB, true, p, PARAM_LOOP, 2, PARAM_INT, &rowid, PARAM_END);
		if (rc < 1) NSLog(@"no sent SMS found for %s", num);
		else if (rc > 1) NSLog(@"several SMS sent to %s in 120 sec still waiting for a status. Choose the first", num);
		free(p);

		return rowid[0] != 0 ? exec_sql("update message set smsc_ref=%d where ROWID = %d ", ref, rowid[0]) : -1;
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
		rc = run_sql(SMS_DB, true, p, PARAM_INT, &n, PARAM_END);
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
	int status = 0;

    asprintf(&p, 
            "select delivery_status from message"  
			"where ROWID=%d and (delivery_status is not null or smsc_ref is not null",
            rowid);
	if (p != NULL) {
		rc = run_sql(SMS_DB, true, p, PARAM_INT, &status, PARAM_END);
		if (rc == 1) {
			rc = status;
		}
		else rc = -1;
		free(p);
	}
	return rc;
}

int get_delivery_info_for_rowid(uint32_t rowid, int *pref, time_t *pdate, int *pdelay, int *pstatus) {
	char *p = NULL;
	int rc = -1;
	int status = 0, ref = 0;
	time_t date, s_date, r_date;
	time_t dr_date;

	*pstatus = 1003;
    asprintf(&p, 
            "select smsc_ref, delivery_status, date, s_date, r_date, dr_date from message "
			"where ROWID=%d and ((flags != 0 and flags != 2 and flags < 32))",
            rowid);
	if (p != NULL) {
		rc = run_sql(SMS_DB, true, p, 
				PARAM_INT, &ref, 
				PARAM_INT, &status, 
				PARAM_INT, &date, 
				PARAM_INT, &s_date, 
				PARAM_INT, &r_date, 
				PARAM_INT, &dr_date, 
				PARAM_END);
		if (rc == 1) {			// one row was returned

			// this is a huge mess...

			if (dr_date != 0) {
				// it is a report from old version. Try to extract what we can
				if (dr_date < 0) {
					// it is an error
					*pstatus = 192;
					*pdate = date;
					*pdelay = -1;
					*pref = -1;
					rc = 0;
				}
				else {
					// it is a valid report
					*pstatus = 0;
					*pdate = date;
					*pdelay = dr_date - date;
					rc = 0;
					*pref = -1;
				}
			}
			else {
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
					rc = 0;
				}
				else
					rc = 0;
			}
		}
		else {
			rc = -1;
			*pstatus = 1004;
		}

		free(p);
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
	char *s1 = NULL, *s2 = NULL;
	char *p = NULL;
	bool rc = false;
	
    name[0] = surname[0] = 0;

	if (num[0] == 0) return false;

	asprintf(&p, "select First,Last from ABPerson,ABMultiValue "
                 "where ROWID=record_id and property=3 and value like '%s'",
            build_phone_number_pattern(num));
    
    if (p != NULL) {
		if (1 == run_sql(AB_DB, true, p, PARAM_STR, &s1, PARAM_STR, &s2, PARAM_END)) {
			if (s1 != NULL) {
				strcpy(surname, s1);
				free(s1);
			}
			if (s2 != NULL) {
				strcpy(name, s2);
				free(s2);
			}
		}
		free(p);
		rc = true;
	}
	return rc;
}

int get_list_of_rowids(int max, uint32_t *buffer) {
	const char *sql = "select ROWID from Message " 
			          "where address not like '%@%' and (flags < 32 and flags != 0 and flags != 2 and address is not null) order by date desc";

	return run_sql(SMS_DB, true, sql, PARAM_LOOP, max, PARAM_INT, buffer, PARAM_END);
}

NSString *get_address_for_rowid(int rowid) {
	char *str;
	char *p;

	asprintf(&str, " select address from Message where ROWID=%d", rowid);
	if (str == NULL) return nil;

	if (1 == run_sql(SMS_DB, true, str, PARAM_STR, &p, PARAM_END)) {
		return p != NULL ? [NSString stringWithUTF8String:p] : @"";
	}
	return nil;
}
int get_groupid_for_smsc_ref(int ref) {
	int group_id;
	char *str;

	asprintf(&str, "select group_id from Message where smsc_ref=%d", ref);
	if (str == NULL) return 0;

	if (1 == run_sql(SMS_DB, true, str, PARAM_INT, &group_id, PARAM_END)) {
		return group_id;
	}
	return 0;

}
// vim: set ts=4 expandtab
