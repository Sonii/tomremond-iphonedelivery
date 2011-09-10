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
#ifndef DATABASE_H_INCLUDED
#define DATABASE_H_INCLUDED

/** 
 * @brief run a sql query
 * 
 * @param query 
 * @param ... 
 * 
 * @return 
 */
int exec_sql(const char *query, ...);

/** 
 * @brief check if there is a message for a given smsc ref
 * 
 * @param ref 
 * 
 * @return 
 */
bool has_message_for_ref(int ref);

int set_ref_for_last_sent_sms(const char *num, uint8_t ref);

int get_sent_time_for_sms(const char *num, uint8_t ref);

int update_sms_for_delivery(const char *num, uint8_t ref, uint8_t status, time_t s_date, time_t d_date);

/** 
 * @brief convert a phone numbr to a contact name
 * 
 * @param numner in asci
 * 
 * @return the name if it was found in the AB or the number otherwise. It is a static buffer so it wiill be modified at the next
 * invocaion
 */
bool convert_num_to_name(const char *num, char *name, char *surname);

int get_status_for_rowid(uint8_t rowid);

int get_delivery_info_for_rowid(uint32_t rowid, int *pref, time_t *pdate, int *pdelay, int *pstatus);

int get_list_of_rowids(int max, uint32_t *buffer);

NSString *get_address_for_rowid(int rowid) ;
#endif
// vim: set ts=4 expandtab
