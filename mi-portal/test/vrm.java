/**
 * This file is part of i5/OS Programmer's Toolkit.
 * 
 * Copyright (C) 2010, 2011  Junlei Li (李君磊).
 * 
 * i5/OS Programmer's Toolkit is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * i5/OS Programmer's Toolkit is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with i5/OS Programmer's Toolkit.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/**
 * @file vrm.java
 *
 * Retrieving the LIC VRM (Version Release Modification) in java via MI Portal.
 *
 * @remark This program can run locally at an IBM i server or remotely at a client PC.
 */

import com.ibm.as400.access.*;

public class vrm {

    /// ctor
    public static void main(String[] args) {

        byte[] inst_inx = {  // ubin(2) instruction index, hex 0001 for MATMATR
            0x00, 0x01
        };
        byte[] matmatr_tmpl = {
            0x00, 0x00, 0x00, 0x10, // bin(4) bytes-in = 16
            0x00, 0x00, 0x00, 0x00, // bin(4) bytes-out
            0x00, 0x00, 0x00, 0x00, // char(6) VRM, char(2) reserved
            0x00, 0x00, 0x00, 0x00
        };
        byte[] matmatr_opt = {  // char(2) materialization option, hex 020C for LIC VRM
            0x02, 0x0C
        };

        AS400 i = new AS400();  // in case running at an IBM i server
        ProgramParameter[] plist = new ProgramParameter[] {
            new ProgramParameter(inst_inx),  // input, ubin(2) instruction index
            new ProgramParameter(matmatr_tmpl, 16), // inout, instruction template of MATMATR
            new ProgramParameter(matmatr_opt)   // input, char(2) materialization option
        };

        ProgramCall portal = new ProgramCall(i,
                                             "/qsys.lib/i5toolkit.lib/miportal.pgm",
                                             plist
                                             );

        try {
            if(!portal.run())
                System.out.println("Oops!");
            else {
                byte[] tmpl = plist[1].getOutputData();

                AS400Text cvt = new AS400Text(6, i); // use the CCSID of the currently connected AS400 object
                String vrm = (String)cvt.toObject(tmpl, 8);
                System.out.println("LIC VRM of the current IBM i server is: " + vrm);
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

}
