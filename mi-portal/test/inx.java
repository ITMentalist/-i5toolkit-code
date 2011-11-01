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
 * @file inx.java
 *
 * Test of Independent Index Management instructions.
 */

import com.ibm.as400.access.*;
import u.*;

public class inx {

    public static final String MI_PORTAL = "/qsys.lib/i5toolkit.lib/miportal.pgm";

    public static void main(String[] args) {

        try {

            AS400 i = new AS400();
            CRTINXTmpl tmpl = new CRTINXTmpl("Happy Halloween", 32, 16);
            tmpl.immed_update_ = true;
            tmpl.insert_by_key_ = true;
            tmpl.ptr_data_ = true;
            // Argument list for issuing CRTINX
            ProgramParameter[] argl = new ProgramParameter[] {
                new ProgramParameter(new byte[] {0x00, 0x2E}),  // instruction index of CRTINX
                new ProgramParameter(16),   // returned ptr-ID
                new ProgramParameter(tmpl.toBytes()) // creation template
            };
            ProgramCall portal = new ProgramCall(i, MI_PORTAL, argl);

            // Create index object
            if(!portal.run())
                System.out.println("CRTINX failed!");
            else {

                // Destroy the created index object
                byte[] inx_ptr = argl[1].getOutputData();
                argl = new ProgramParameter[] {
                    new ProgramParameter(new byte[] {0x00, 0x2F}),  // instruction index of DESINX
                    new ProgramParameter(inx_ptr)        // input returned ptr-ID
                };
                portal.setParameterList(argl);
                if(!portal.run())
                    System.out.println("DESINX failed!");
            }

        } catch(Exception e) { e.printStackTrace(); }
    }

}
