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
        public var as400Dta_:IAS400Data;
        public var argType_:int;

        /// ctor
        public function ProgramArgument(as400Dta:IAS400Data,
                                        argType:int  = INPUT,  // ProgramArgumentType.INPUT
                                        value:Object = null,
                                        name:Object  = null)
        {
            as400Dta_ = as400Dta;
            argType_  = argType;
            value_    = value;
            name_     = name;
        } // ctor

    }

}
