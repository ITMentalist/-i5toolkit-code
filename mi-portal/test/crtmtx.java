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
 * @file crtmtx.java
 *
 * Test of CRTMTX
 *
 * @pre This example program stores created mutex in a User Space
 * object *LIBL/MTXPOT. Make sure it already exists on your IBM i
 * server before running this program. e.g.
 *  CALL PGM(QUSCRTUS)
 *       PARM('MTXPOT    *CURLIB'
 *            'MUTEX_POT'
 *            X'00001000'
 *            X'00'
 *            '*CHANGE'
 *            'Mutex Pot')                                                    
 */

import com.ibm.as400.access.*;
import u.*;
import java.io.IOException;

public class crtmtx {

    public static void main(String[] args) {

        crtmtx mtx = new crtmtx("Good pot *^_^*");
        mtx.create();
    }

    private String name_;
    private ProgramCall portal_;
    private static final String MIPORTAL =
        "/qsys.lib/i5toolkit.lib/miportal.pgm";

    public crtmtx(String name) {
        name_ = name;
    }

    public void create() {

        byte[] spc_spp = null;
        AS400 i = new AS400();
        ProgramParameter[] plist = new ProgramParameter[] {new ProgramParameter(1)};
        portal_ = new ProgramCall(i, MIPORTAL, plist);

        try {

            // get the space pointer addressing USRSPC *LIBL/MTXPOT
            spc_spp = get_spp_to_mtxpot();

            // create pointer-base mutex into MTXPOT's storage
            create_mutex(spc_spp);

            // Now have a look at the first 32-byte of USRSPC MTXPOT.
            // Either of the DMPxxx CL commands (DMP, DMPOBJ, or DMPSYSOBJ) can be used
            System.out.println("Now have a look at the first 32-byte of USRSPC MTXPOT. " +
                               "Either of the DMPxxx CL commands (DMP, DMPOBJ, or DMPSYSOBJ) " +
                               "can be used");

        } catch(Exception e) { e.printStackTrace(); }

        i.disconnectAllServices();
    }

    /**
     * RSLVSP2 MTXPOT-SYP, RSLV-OPT;
     * SETSPPFP SPP, MTXPOT-SYP;
     */
    private byte[] get_spp_to_mtxpot()
        throws Exception
    {
        RSLVSPTmpl rtmpl = new RSLVSPTmpl(0x1934, "MTXPOT", 0x0000);
        ProgramParameter[] plist_rslvsp = new ProgramParameter[] {
            new ProgramParameter(new byte[] {0x00, 0x03}), // inst-inx, RSLVSP2
            new ProgramParameter(16),  // output, pointer ID of resolved MI object
            new ProgramParameter(rtmpl.toBytes()) // input, resolve template
        };
        portal_.setParameterList(plist_rslvsp);
        if(!portal_.run())
            throw new Exception("get_spp_to_mtxopt(): call to RSLVSP2 failed.");

        byte[] syp =  plist_rslvsp[1].getOutputData(); // pointer ID of resolved system pointer
        ProgramParameter[] plist_setsppfp = new ProgramParameter[] {
            new ProgramParameter(new byte[] {0x00, 0x07}), // inst-inx, SETSPPFP
            new ProgramParameter(16),  // outout, pointer ID of returned space pointer 
            new ProgramParameter(syp)  // input, pointer ID of source pointer (syp to MTXPOT)
        };
        portal_.setParameterList(plist_setsppfp);
        if(!portal_.run())
            throw new Exception("get_spp_to_mtxopt() failed: call to SETSPPFP failed.");

        return plist_setsppfp[1].getOutputData();
    }

    /**
     * CRTMTX SPP, CRT-OPT, RTN-CODE;
     */
    private void create_mutex(byte[] spp)
        throws Exception
    {
        String mtx_name = "";
        if(name_.length() > 16)
            mtx_name = name_.substring(0, 16);
        else
            for(mtx_name = name_; mtx_name.length() < 16; )
                mtx_name += " ";
        ByteArray barr = new ByteArray(32);
        barr.writeBytes(0x00, 16).writeEBCDIC37(mtx_name);
        ProgramParameter[] plist_write = new ProgramParameter[] {
            new ProgramParameter(new byte[] {0x00, 0x09}),  // WRITE_TO_ADDR
            new ProgramParameter(spp),
            new ProgramParameter(barr.toBytes()),
            new ProgramParameter(ByteArray.fromInt32(32))   // number of bytes to write
        };
        portal_.setParameterList(plist_write);
        if(!portal_.run())
            throw new Exception("failed to invoked WRITE_TO_ADDR.");

        // create mutex
        CRTMTXTmpl tmpl = new CRTMTXTmpl(true,  // named mutex
                                         true,  // remain valid after owner thread bing terminated
                                         true); // can be locked recursively
        ProgramParameter[] plist_crtmtx = new ProgramParameter[] {
            new ProgramParameter(new byte[] {0x00, 0x2A}),  // CRTMTX
            new ProgramParameter(spp),  // input, pointer ID of space pointer
            new ProgramParameter(tmpl.toBytes()),
            new ProgramParameter(4),  // output, Bin(4) result code
        };
        portal_.setParameterList(plist_crtmtx);
        if(!portal_.run()) {
            AS400Message[] messagelist = portal_.getMessageList();
            for (int i = 0; i < messagelist.length; ++i)
                // Show each message.
                System.out.println(messagelist[i]);

            throw new Exception("Failed to invoke CRTMTX");
        }

        barr.fromBytes(plist_crtmtx[3].getOutputData());
        int return_code = barr.readInt32();
        System.out.println("Return code of CRTMTX: " + return_code);
    }

}

class CRTMTXTmpl implements InstructionTemplate {

    private boolean named_ = false;
    // Mutex will remain valid or be destroyed when its owning thread
    // is terminated
    private boolean remain_valid_ = false;
    // can be locked recursively or not
    private boolean recursive_ = false;

    private static final int CRT_TMPL_LEN = 32;

    /// ctor
    public CRTMTXTmpl() {
    }
    public CRTMTXTmpl(boolean named,
                      boolean remainValid,
                      boolean recursive) {
        named_ = named;
        remain_valid_ = remainValid;
        recursive_ = recursive;
    }

    public byte[] toBytes()
        throws IOException
    {
        ByteArray barr = new ByteArray(CRT_TMPL_LEN);
        int name_opt = named_ ? 0x01 : 0x00;
        int validity_opt = remain_valid_ ? 0x01 : 0x00;
        int recursive_opt = recursive_ ? 0x01 : 0x00;
        barr.writeBytes(0x00, 1).         // reserved
            writeBytes(name_opt, 1).
            writeBytes(validity_opt, 1).
            writeBytes(recursive_opt, 1).
            writeBytes(0x00, 28)          // reserved
            ;

        return barr.toBytes();
    }

    public void fromBytes(byte[] hostData)
        throws IOException
    {
    }
}
