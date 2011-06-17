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
