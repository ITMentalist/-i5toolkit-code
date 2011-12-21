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
 * @file e014.c
 */

# include <stdlib.h>
# include <stdio.h>
# include <string.h>

# include <heap.h>

# define NL "\x25"

int main() {

  crths_t tmpl;
  unsigned heap_id = 0;
  void *spp = NULL;

  memset(&tmpl, 0, sizeof(tmpl));
  tmpl.max_alloc     = 0xFFF000;   // hex 01000000 - hex 1000 (16M - 1 page)
  tmpl.min_bdry_algn = 0x0200;     // 512 bytes
  tmpl.domain        = 0x0001;     // user domain
  tmpl.heap_attr.bits.init_alloc = 1;
  tmpl.heap_attr.bits.ovr_freed = 1;
  tmpl.alloc_val[0] = 0x40;
  tmpl.free_val[0]  = 0x60;
  _CRTHS(&heap_id, &tmpl);

  spp = _ALCHSS(heap_id, 128); // 512 bytes of 0x40 is allocated
  _FREHSS(spp);                // Freed heap storage is now 512 bytes of 0x60

  _DESHS(&heap_id);
  return 0;
}
