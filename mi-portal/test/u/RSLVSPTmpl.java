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

package u;

/**
 * Resolve option template for MI instruction RSLVSP
 */
public class RSLVSPTmpl implements InstructionTemplate {

    private int type_;
    private String name_;
    private int req_auth_;
    public static final int TMPL_LEN = 34;

    /// ctor
    public RSLVSPTmpl(int objectType,    // 2-byte MI object type (type code + subtype code)
                      String objectName,
                      int requiredAuth)  // 2-byte required authority
    {
        type_ = objectType;
        name_ = objectName;
        req_auth_ = requiredAuth;
    }

    public byte[] toBytes()
        throws java.io.IOException
    {
        String obj_name = "";
        if(name_.length() > 30)
            obj_name = name_.substring(0, 30);
        else
            for(obj_name = name_; obj_name.length() < 30;)
                obj_name += " ";

        ByteArray barr = new ByteArray(TMPL_LEN);
        barr.writeInt16(type_).
            writeEBCDIC37(obj_name).
            writeInt16(req_auth_);

        return barr.toBytes();
    }

    public void fromBytes(byte[] hostData) throws java.io.IOException {}
}
