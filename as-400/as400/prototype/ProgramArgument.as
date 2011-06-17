/**
 * @file ProgramArgument.as
 */

package as400.prototype {

    public class ProgramArgument {

        public static const INPUT:int  = 11;
        public static const OUTPUT:int = 12;
        public static const INOUT:int  = 13;

        public var name_:*;
        public var value_:*;
        public var as400Dta_:AS400Data;
        private var argType_:int;
        private var dataType_:int;

        /// ctor
        public function ProgramArgument(dataType:int,
                                        argType:int  = INPUT,  // ProgramArgumentType.INPUT
                                        value:Object = null,
                                        name:Object  = null)
        {
            dataType_ = dataType;
            argType_  = argType;
            value_    = value;
            name_     = name;

            switch(dataType_) {
            case AS400DataType.BIN2:
                as400Dta_ = new Bin2();
                break;
            case AS400DataType.UBIN2:
                as400Dta_ = new UBin2();
                break;
            case AS400DataType.BIN4:
                as400Dta_ = new Bin4();
                break;
            case AS400DataType.UBIN4:
                as400Dta_ = new UBin4();
                break;
            case AS400DataType.FLOAT4:
                as400Dta_ = new Float4();
                break;
            case AS400DataType.FLOAT8:
                as400Dta_ = new Float8();
                break;
                // todo more types
            default:
                // @todo
            }
        } // ctor

    }

}
