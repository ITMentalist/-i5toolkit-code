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
 * @file enq.java
 *
 * This program calls MIPORTAL to enueue a message onto to USRQ
 * *LIBL/Q007. MI instrutions or system-builtins issued by this
 * program include:
 *  - _RSLVSP2
 *  - ENQ
 *
 * @remark This program can run locally at an IBM i server or remotely at a client PC.
 */

import com.ibm.as400.access.*;

public class enq {

    public static void main(String[] args) {

        AS400 i = new AS400();  // in case running at an IBM i server

        byte[] inst_inx = {  // ubin(2) instruction index, hex 0003 for _RSLVSP2
            0x00, 0x03
        };
        int ptr_id = 0;
        byte[] rslvsp_tmpl = new byte[34]; // instruction template of RSLVSP
        rslvsp_tmpl[0] = 0x0A; // object type code of USRQ, hex 0A
        rslvsp_tmpl[1] = 0x02; // object subtype code of USRQ, hex 02
        AS400Text objname = new AS400Text(30, i);
        objname.toBytes("Q007                          ", rslvsp_tmpl, 2); // char(30) object name
        rslvsp_tmpl[32] = rslvsp_tmpl[33] = 0x00; // required authority

        ProgramParameter[] plist_rslvsp2 = new ProgramParameter[] {
            new ProgramParameter(inst_inx),  // input, ubbin(2) instruction index
            new ProgramParameter(4),         // output, ptr-ID of the resolved system pointer
            new ProgramParameter(rslvsp_tmpl) // input, instruction template of RSLVSP
        };

        ProgramCall portal = new ProgramCall(i,
                                             "/qsys.lib/i5toolkit.lib/miportal.pgm",
                                             plist_rslvsp2
                                             );

        try {

            AS400Bin4 bin4 = new AS400Bin4();
            AS400Text ch32 = new AS400Text(32, i);
            if(!portal.run())
                System.out.println("Issuing _RSLVSP2 failed.");
            else {
                ptr_id = bin4.toInt(plist_rslvsp2[1].getOutputData());
                String msg = "Hello MI!";

                inst_inx[1] = 0x04; // instruction index of ENQ, hex 0004
                ProgramParameter[] plist_enq = new ProgramParameter[] {
                    new ProgramParameter(inst_inx),
                    new ProgramParameter(bin4.toBytes(ptr_id)), // input, bin(4) ptr-ID
                    new ProgramParameter(bin4.toBytes(msg.getBytes().length)), // input, message prefix (bin(4) message length and optional message key)
                    new ProgramParameter(ch32.toBytes(msg))  // input, message text
                };
                portal.setParameterList(plist_enq);
                if(!portal.run())
                    System.out.println("Failed to issue the ENQ instruction.");
                else
                    System.out.println("Check the enqueued message using the DSPQMSG command.");
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

}
