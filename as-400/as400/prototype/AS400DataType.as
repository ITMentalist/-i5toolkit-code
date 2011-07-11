/**
 * This file is part of i5/OS Programmer's Toolkit.
 * 
 * Copyright (C) 2010, 2011  Junlei Li (李君磊).
 * 
 * i5/OS Programmer's Toolkit is free software: you can redistribute
 * it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * i5/OS Programmer's Toolkit is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with i5/OS Programmer's Toolkit.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/**
 * @file AS400DataType.as
 *
 * AS/400 data types. Mappings between AS/400 data types and AS3 data
 * types are the following.
 * AS/400 data type                 AS3 type
 * ------------------               ---------
 * 2-byte binary                    Bin2
 * 2-byte unsigned binary           UBin2
 * 4-byte float                     Float4
 * 8-byte float                     Float8
 * Packed decimal                   Packed
 * Zoned decimal                    Zoned
 *
 * @remark remember try to be compatible with the format of the 3-byte DTAPTR attribute used by SETDPAT
 */

package as400.prototype {

    public class AS400DataType {

        // numeric data types
        public static const BIN2:int   = 0x00000002;
        public static const UBIN2:int  = 0x000a0002;
        public static const BIN4:int   = 0x00000004;
        public static const UBIN4:int  = 0x000a0004;
        public static const FLOAT4:int = 0x00010004;
        public static const FLOAT8:int = 0x00010008;
        public static const PACKED:int = 0x00030000;
        public static const ZONED:int  = 0x00020000;

        // character data types
        // @todo other character types
        public static const OPEN:int = 0x00090000;

    }

}
