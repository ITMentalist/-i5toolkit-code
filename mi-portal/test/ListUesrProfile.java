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
 * @file ListUesrProfile.java
 *
 * This example Java program lists all User Profiles (USRSRFs) on an
 * IBM i server via the Materrialize Context (MATCTX) MI instruction.
 *
 * @remark This program can run locally at an IBM i server or remotely at a client PC.
 *
 * @todo Finish it!
 */

import com.ibm.as400.access.*;
import u.ByteArray;

public class ListUesrProfile {

    public static void main(String[] args) {

        byte[] mat_tmpl = new ByteArray(8).
            writeInt32(8).  // Number of bytes provided for materialization
            writeInt32(0).  // Number of bytes available for materialization
            toBytes();
        byte[] mat_opt = MATCTXOptionTmpl.toBytes(0x08); // object type code = 0x08, USRPRF
        ProgramParameter[] plist_matctx = new ProgramParameter[] {
            new ProgramParameter(new byte[] {0x00, 0x27}),  // input, instruction index of MATCTX1
            new ProgramParameter(mat_tmpl, 8),  // inout, materialization template
            new ProgramParameter(mat_opt) // input, materialization options
        };

        AS400 i = new AS400();
        ProgramCall portal = new ProgramCall(i,
                                             "/qsys.lib/i5toolkit.lib/miportal.pgm",
                                             plist_matctx);

        try {

            byte[] rtn = plist_matctx[1].getOutputData();
            int a = ByteArray.load(rtn, 8).readInt32();
            portal.run();

        } catch(Exception e) {
            e.printStackTrace();
        }

    }

} // class ListUesrProfile

class MATCTXOptionTmpl {

    public static final int TEMPLATE_LENGTH = 46;

    public static
        byte[]
        toBytes(int objectTypeCode)
        throws IOException
    {
        ByteArray barr = new ByteArray(TEMPLATE_LENGTH);
        barr.writeBytes(0x05, 1)   // Do NOT validate system pointers; returns only symbolic IDs
            .writeBytes(0x01, 1)   // Materialize the machine context; select by 1-byte object type code
            .writeInt16(0)         // UBin(2) length of object-name; not used
            .writeBytes(objectTypeCode, 1)   // 1-byte object type code, hex 08 (USRPRF)
            .writeBytes(0x00, 1)   // 1-byte object subtype code; not used
            .writeBytes(0x00, 30)  // 30-byte object name; not used
            .writeBytes(0x00, 8)   // 8-byte timestamp
            .writeInt16(0);        // UBin(2) independent ASP number; not used

        return barr.toBytes();
    }

}
