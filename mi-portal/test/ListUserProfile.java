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
 * @file ListUserProfile.java
 *
 * This example Java program lists all User Profiles (USRSRFs) on an
 * IBM i server via the Materrialize Context (MATCTX) MI instruction.
 *
 * @remark This program can run locally at an IBM i server or remotely at a client PC.
 *
 * @todo Finish it!
 */

import java.io.IOException;
import com.ibm.as400.access.*;
import u.ByteArray;

public class ListUserProfile {

    public static void main(String[] args) {

        ListUserProfile l = new ListUserProfile();
        l.run();
    }

    private static final String MIPORTAL =
        "/qsys.lib/i5toolkit.lib/miportal.pgm";

    private ProgramCall portal_;

    public void run() {

        byte[] heap_spp = null;
        int len = 0;
        byte[] mat_tmpl = null;
        byte[] mat_opt = null;

        try {
            // allocate 8 bytes of heap storage at the server side
            heap_spp = alloc_heap_storage(8);

            // MATCTX1_H, get number of bytes available
            len = bytes_needed();
            System.out.println("Number of bytes needed to materialize USRPRF names: "
                               + len);

            // reallocate heap storage

            // MATCTX1_H, actually materialize usrprf names

            // report what we get

            // free allocated heap storage
            free_heap_storage(heap_spp);

        } catch(Exception e) { e.printStackTrace(); }

    }

    /// call ALCHSS to allocate heap storage on server jobs' default heap
    private byte[] alloc_heap_storage(int len)
        throws Exception
    {
        ProgramParameter[] plist = new ProgramParameter[] {
            new ProgramParameter(new byte[] {0x00, 0x1f}), // instruction index of ALCHSS
            new ProgramParameter(16),  // returned space pointer ID
            new ProgramParameter(ByteArray.fromInt32(0)),  // heap ID
            new ProgramParameter(ByteArray.fromInt32(8))   // number of bytes to allocate
        };

        AS400 i = new AS400();
        portal_ = new ProgramCall(i, MIPORTAL, plist);
        // portal_.setParameterList(plist);
        if(!portal_.run())
            throw new Exception("alloc_heap_storage()");

        return plist[1].getOutputData();
    }

    private void free_heap_storage(byte[] heap_spp)
        throws Exception
    {
        ProgramParameter[] plist = new ProgramParameter[] {
            new ProgramParameter(new byte[] {0x00, 0x22}), // instruction index of FREHSS
            new ProgramParameter(heap_spp)                 // space pointer ID
        };

        portal_.setParameterList(plist);
        if(!portal_.run())
            throw new Exception("free_heap_storage()");
    }

    private int bytes_needed() // @todo should use previously allocated heap storage as TMPL
        throws Exception
    {
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

        portal_.setParameterList(plist_matctx);
        if(!portal_.run())
            throw new Exception("bytes_needed()");

        byte[] rtn = plist_matctx[1].getOutputData();
        int bytes_available = ByteArray.load(rtn, 4, 4).readInt32();
        return bytes_available;
    }

} // class ListUserProfile

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
