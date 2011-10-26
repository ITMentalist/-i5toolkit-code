/**
 * This file is part of i5/OS Programmer's Toolkit.
 * 
 * Copyright (C) 2010, 2011  Junlei Li
 * 
 * i5/OS Programmer's Toolkit is free software: you can redistribute
 * it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 * 
 * i5/OS Programmer's Toolkit is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with i5/OS Programmer's Toolkit.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/**
 * @file lsobjtypes.c
 *
 * List all MI object types supported by the current VRM.
 */

# include <stdlib.h>
# include <stdio.h>
# include <string.h>

# pragma linkage (_SYSEPT, builtin)
void *_SYSEPT (void);

# pragma linkage (_SETSPPFP, builtin)
void *_SETSPPFP (void*);

# define EPT_QLICNV 0x49   // array subscript of QLICNV's SYP in SEPT

typedef _Packed struct {
  char ex_obj_type[7];
  char mi_obj_type[4];
} qlicnv_entry_t;

/// i expect no input arguments :p
int main(int argc, char *argv[]) {

  void **sept = NULL;  // space pointer to SEPT
  char *pos = NULL;
  qlicnv_entry_t *ent = NULL;
  unsigned num_ent = 0;
  unsigned u = 0;

  // locate QLICNV's SYP in SEPT
  sept = _SYSEPT();

  // retrieve a SPP addressing QLICNV's associated space
  pos = _SETSPPFP(sept[EPT_QLICNV]);
  pos += 32;
  num_ent = *(unsigned*)pos;

  pos += 32;
  ent = (qlicnv_entry_t*) pos;
  for(u = 0; u < num_ent; u++, pos += sizeof(qlicnv_entry_t)) {
    ent = (qlicnv_entry_t*) pos;
    printf("%4.4s  %7.7s\x25",
           ent->mi_obj_type, ent->ex_obj_type);
  }

  return 0;
}
