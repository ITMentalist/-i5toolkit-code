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

        CRTSTmpl tmpl = new CRTSTmpl();
    }

}

/**
 * This class implements the basic creation template of the CRTS instruction.
 * @remark Length of the basic creattion tmplate of CRTS is 96 bytes.
 */
class CRTSTmpl {

    public static final int _template_size = 96;

    public CRTSTmpl() {
    }

    public byte[] toBytes() {

        ByteArray arr = new ByteArray();

        try {
            arr.writeInt32(_template_size).
                writeInt32(0).
                writeInt16(0x19EF). // MI object type
                writeEBCDIC37("piggy pot :-)                 ").
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

    public void fromBytes(byte[] arr) {
    }

}
