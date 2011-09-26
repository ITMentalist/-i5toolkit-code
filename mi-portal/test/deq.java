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
 * @file deq.java
 *
 * This program calls MIPORTAL to dequeue a message from to USRQ
 * *LIBL/Q007. MI instrutions or system-builtins issued by this
 * program include:
 *  - _RSLVSP2
 *  - _DEQWAIT
 *
 * @remark This program can run locally at an IBM i server or remotely at a client PC.
 */

import com.ibm.as400.access.*;
import u.*;

public class deq {

    public static void main(String[] args) {

        try {

            AS400 i = new AS400();

            byte[] inst_inx = {  // ubin(2) instruction index, hex 0003 for _RSLVSP2
                0x00, 0x03
            };
            RSLVSPTmpl rtmpl = new RSLVSPTmpl(0x0A02, // object type/subtype code of USRQ, hex 0A02
                                              "Q007",
                                              0x0000);// required authority

            ProgramParameter[] plist_rslvsp2 = new ProgramParameter[] {
                new ProgramParameter(inst_inx),  // input, ubbin(2) instruction index
                new ProgramParameter(16),         // output, ptr-ID of the resolved system pointer
                new ProgramParameter(rtmpl.toBytes()) // input, instruction template of RSLVSP
            };

            ProgramCall portal = new ProgramCall(i,
                                                 "/qsys.lib/i5toolkit.lib/miportal.pgm",
                                                 plist_rslvsp2
                                                 );

            AS400Bin4 bin4 = new AS400Bin4();
            AS400Text ch32 = new AS400Text(32, i);
            if(!portal.run())
                System.out.println("Issuing _RSLVSP2 failed.");
            else {
                byte[] ptr_id = plist_rslvsp2[1].getOutputData();
                // debug
                System.out.println("length of ptr_id: " + ptr_id.length);
                byte[] prefix = new byte[21];
                prefix[20] = 0x10; // bit 3 of 1-byte dequeue option (time-out option) = 1, wait infinitely

                inst_inx[1] = 0x05; // instruction index of _DEQWAIT, hex 0005
                ProgramParameter[] plist_deq = new ProgramParameter[] {
                    new ProgramParameter(inst_inx),
                    new ProgramParameter(prefix, 21), // inout, message prefix
                    new ProgramParameter(32),         // output, message text
                    new ProgramParameter(ptr_id)      // input, char(16) ptr-ID
                };
                portal.setParameterList(plist_deq);
                if(!portal.run())
                    System.out.println("Failed to issue the DEQ instruction.");
                else {
                    String msg = (String)ch32.toObject(plist_deq[2].getOutputData());
                    System.out.println("Queue message dequeued: '" + msg + "'");
                }

            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

}
