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
 * @file PiggyPot.java
 *
 * Operating space objects via the Space Management Instructions
 *
 * MI instructions used here are the following:
 *  - CRTS
 */

import com.ibm.as400.access.*;

public class PiggyPot {

    public static void main(String[] args) {

        CRTSTmpl tmpl = new CRTSTmpl("piggy pot :-)");
        ProgramParameter[] plist_crts = new ProgramParameter[] {
            new ProgramParameter(new byte[] {0x00, 0x16}), // instrunction index of CRTS, hex 0016
            new ProgramParameter(16), // output, pointer ID of the SYP to the created space object
            new ProgramParameter(tmpl.toBytes()) // input, creation template of CRTS
        };
        AS400 i = new AS400();
        ProgramCall portal =
            new ProgramCall(i,
                            "/qsys.lib/i5toolkit.lib/miportal.pgm",
                            plist_crts
                            );

        try {

            // CRTS
            portal.run();

            // SETSPPFP
            byte[] syp = plist_crts[1].getOutputData();
            ProgramParameter[] plist_setsppfp = new ProgramParameter[] {
                new ProgramParameter(new byte[] {0x00, 0x07}), // instrunction index of SETSPPFP, hex 0007
                new ProgramParameter(16), // output, pointer ID of the SPP
                new ProgramParameter(syp) // input
            };
            portal.setParameterList(plist_setsppfp);
            portal.run();
            byte[] spp = plist_setsppfp[1].getOutputData();

            // utilize the created space object via spp.

        } catch(Exception e) { e.printStackTrace(); }

    }

}

/**
 * Creation template of CRTS
 */
class CRTSTmpl {

    private static final int _template_size = 160;

    private String name_;

    public CRTSTmpl(String name) {
        name_ = name;
        if(name_.length() > 30)
            name_ = name_.substring(0, 30);
        else
            for(int i = name_.length(); i < 30; i++)
                name_ += " ";
    }

    public byte[] toBytes() {

        ByteArray arr = new ByteArray();

        try {
            arr.writeInt32(_template_size).
                writeInt32(0).
                writeInt16(0x19EF). // MI object type
                writeEBCDIC37(name_).
                // creation option: temporary, var-length,
                // not in context, auto-extended, tracking by MI process
                writeInt32(0x40020000).
                writeBytes(0, 2). // reserved
                writeInt16(0).    // ASP number
                writeInt32(0x2000). // size: 8K
                writeBytes(0x00, 1). // initial value of space
                writeInt32(0xF0000000). // perfermance class
                writeBytes(0x00, 1). // reserved
                writeBytes(0x00, 2). // public auth (not used in this example)
                writeInt32(0).       // extended tmpl offset
                writeBytes(0x00, 16). // NULL ctx pointer
                writeBytes(0x00, 16). // NULL access group pointer
                writeBytes(0x00, 64)  // extended template (not used)
                ;
        } catch(Exception e) {}

        return arr.toBytes();
    }

    public void fromBytes(byte[] data) {
    }

}

class MATPTRSYPTmpl {

    public static final int SYSPTR = 0x01; // system pointer
    public static final int SPCPTR = 0x02; // space pointer
    public static final int DTAPTR = 0x03; // data pointer
    public static final int INSPTR = 0x04; // instruction pointer
    public static final int INVPTR = 0x05; // invocation pointer
    public static final int PROCPTR = 0x06; // procedure pointer (NMI)
    public static final int LBLPTR = 0x07; // label pointer (NMI)
    public static final int SUSPTR = 0x08; // suspend pointer
    public static final int SYNPTR = 0x09; // synchronization pointer
    public static final int UNSUPPORTED = 0xFF; // unsupported pointer

    private static final int _syp_tmpl_len = 77;

    // properties
    public int ptrType = SYSPTR;

    public byte[] toBytes() {
        ByteArray arr = new ByteArray();
        try {
            arr.writeInt32(_syp_tmpl_len).
                writeBytes(0x00, _syp_tmpl_len - 4);
        } catch(Exception e) {}

        return arr.toBytes();
    }

    public void fromBytes(byte[] data) {
    }

}
