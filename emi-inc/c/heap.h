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
 * @file heap.h
 *
 * C header for activation group-based heap management instructions.
 */

# ifndef __emi_heap_h__
# define __emi_heap_h__

/**
 * Creation template of CRTHS
 */
typedef _Packed struct {

  unsigned : 32; // reserved char(8)
  unsigned : 32;
  unsigned max_alloc;     // Maximum single allocation
  unsigned min_bdry_algn; // Minimum boundary alignment
  unsigned crt_size;      // Creation size.
                          // @remark should be less than 16M - 1 page and larger than 1 page.
                          // @remark If zero is specified, the system computes a default value.
  unsigned ext_size;      // Extension size
                          // If zero is specified, the system computes
                          // a default value. The minimum value that can be specified is 1 page (in
                          // bytes). The maximum value that can be specified is (16M - 1 page)
                          // bytes.
  unsigned short domain;  // Domain/Storage protection.
                          // Hex 0000 = System should chose the domain
                          // Hex 0001 = The heap space domain should be "User"
                          // Hex 8000 = The heap space domain should be "System"
  union {
    char attr_val[1];
    struct {
      int alloc_stg : 1;       // Allocation strategy
      int prevent_mark : 1;    // Prevent heap space mark. 0=Allow, 1=prevent
      int block_tfr : 1;       // Block transfer.
                               // 0=Transfer the minimum storage transfer size for this object
                               // Transfer the machine default storage transfer size for this object
      int agp_mbr : 1;         // Process access group member
      int init_alloc : 1;      // Initialize allocations. 0=No, 1=yes
      int ovr_freed : 1;       // Overwrite freed allocations. 0=No, 1=yes
      int : 2;                 // bits 6-7. Reserved
    } bits;
  } heap_attr;            // Heap space creation options

  char alloc_val[1];      // Allocation value
  char free_val[1];       // Freed value
  char filler[67];

} crths_t;

# pragma linkage (_CRTHS, builtin)
void _CRTHS (void *,  // Address of returned bin(4) heap-id
             void *); // Creation template

# pragma linkage (_DESHS, builtin)
void _DESHS (void*);  // Heap ID

# pragma linkage (_ALCHSS, builtin)
void* _ALCHSS (unsigned,  // Heap ID
               int);      // Size of space allocation

# pragma linkage (_FREHSS, builtin)
void _FREHSS(void*);  // Space allocation

# pragma linkage (_REALCHSS, builtin)
void* _REALCHSS (void*,  // Space allocation
                 int);   // Size of space reallocation

# pragma linkage (_SETHSSMK, builtin)
void _SETHSSMK (void **,   // Mark ID
                unsigned); // Heap ID

# pragma linkage (_FREHSSMK, builtin)
void _FREHSSMK (void **);  // Mark ID

# pragma linkage (_MATHSAT, builtin)
void _MATHSAT (void *,      // Materialization template
               void *,      // Heap ID template
               void *       // Attribute selection
               );

// @remark _MATHSAT2 accepts 8-byte AGP mark
# pragma linkage (_MATHSAT2, builtin)
void _MATHSAT2 (void *,      // Materialization template
                void *,      // Heap ID template
                void *       // Attribute selection
                );

# endif // !defined __emi_heap_h__
