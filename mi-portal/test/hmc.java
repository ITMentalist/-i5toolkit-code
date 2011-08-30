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
 * @file hmc.java
 *
 * This program calls MIPORTAL to retrieve HMC information of
 * an IBM i server. MI instruction used here is:
 *  - MATMATR
 *
 * @remark This program can run locally at an IBM i server or remotely at a client PC.
 *
 * Run this program, the result output might like the following:
 * Length of returned HMC info: 100
 * HMC info: HmcStat=1;HscName=70.............;HscHostName=localhost;HscIPAddr=127.0.0.1;HscAddIPs=;HMCAddIPv6s=;
 */

import com.ibm.as400.access.*;

public class hmc {

    public static void main(String[] args) {

        byte[] inst_inx = {  // ubin(2) instruction index, hex 0001 MATMATR
            0x00, 0x01
        };
        byte[] tmpl = new byte[1052]; // bin(4) bytes-in, bin(4) bytes-out, bin(4) entries-returned,
                                      // char(4) reserved, ubin(2) HMC info length, char(1034) HMC info
        tmpl[2] = 0x04; tmpl[3] = 0x1C; // byte-in = 1052
        byte[] opt = {0x02, 0x04};

        AS400 i = new AS400();
        ProgramParameter[] plist_matmatr = new ProgramParameter[] {
            new ProgramParameter(inst_inx),  // input, ubbin(2) instruction index
            new ProgramParameter(tmpl, 1052),  // inout, instruction template
            new ProgramParameter(opt) // input, instruction template of RSLVSP
        };
        ProgramCall portal = new ProgramCall(i,
                                             "/qsys.lib/i5toolkit.lib/miportal.pgm",
                                             plist_matmatr);

        try {
            if(!portal.run())
                System.out.println("Issuing _RSLVSP2 failed.");
            else {
                tmpl = plist_matmatr[1].getOutputData();
                int hmc_info_len = 0;
                hmc_info_len |= (int)(tmpl[16]) << 8;
                hmc_info_len |= (int)(tmpl[17]);
                System.out.println("Length of returned HMC info: " + hmc_info_len);
                String hmc_info = new String(tmpl, 18, hmc_info_len);
                System.out.println("HMC info: " + hmc_info); // returned HMC info are in ASCII charset
            }
        } catch(Exception e) {
            e.printStackTrace();
        }

    }

}
