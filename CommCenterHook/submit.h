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
#ifndef SUBMIT_H_INCLUDED
#define SUBMIT_H_INCLUDED
uint8_t *unpack_if_applicable(const char *message);
void set_delivery_report(uint8_t *payload);
void set_class0(uint8_t *payload);
void set_invisible(uint8_t *payload);
#endif
// vim: set ts=4 expandtab
