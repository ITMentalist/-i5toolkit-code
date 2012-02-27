     /**
      * This file is part of i5/OS Programmer's Toolkit.
      *
      * Copyright (C) 2010, 2011  Junlei Li.
      *
      * i5/OS Programmer's Toolkit is free software: you can
      * redistribute it and/or modify it under the terms of the GNU
      * General Public License as published by the Free Software
      * Foundation, either version 3 of the License, or (at your
      * option) any later version.
      *
      * i5/OS Programmer's Toolkit is distributed in the hope that it
      * will be useful, but WITHOUT ANY WARRANTY; without even the
      * implied warranty of MERCHANTABILITY or FITNESS FOR A
      * PARTICULAR PURPOSE.  See the GNU General Public License for
      * more details.
      *
      * You should have received a copy of the GNU General Public
      * License along with i5/OS Programmer's Toolkit.  If not, see
      * <http://www.gnu.org/licenses/>.
      */

     /**
      * @file upsi.cbl
      *
      * Example of accessing job switches (UPSI switches) in COBOL.
      */
       ID DIVISION.
       PROGRAM-ID. UPSI.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
      * Define a mnemonic-name to be associated with job switch 1
            UPSI-0 IS UUU
      * Define switch-status conditions for job switch 1
                ON STATUS IS UUU-ON
                OFF STATUS IS UUU-OFF.
       DATA DIVISION.

       LINKAGE SECTION.

       PROCEDURE DIVISION.
       MAIN-PROGRAM.
      * Reverse the current setting of job switch 1
           IF UUU-ON THEN
               DISPLAY "JOB SWITCH 1 IS ON"
               SET UUU TO OFF
           ELSE
               DISPLAY "JOB SWITCH 1 IS OFF"
               SET UUU TO ON
           END-IF.

       SEE-YOU.
           STOP RUN.
