/**
 * @file ProgramArgument.as
 */

package as400.prototype {

    public class ProgramArgument {

        public static const INPUT:int  = 11;
        public static const OUTPUT:int = 12;
        public static const INOUT:int  = 13;

        private var name_:String;
        public function get name() : String { return name_; }
        public function set name(n:String) : void { name_ = n; }

        private var value_:*;
        public function get value() : * { return value_; }
        public function set value(v:*) : void { value_ = v; }

        private var as400Dta_:IAS400Data;
        public function get as400Dta() : IAS400Data { return as400Dta_; }

        private var argType_:int;
        public function get argType() : int { return argType_; }

        /// ctor
        public function ProgramArgument(dta:IAS400Data,
                                        type:int  = INPUT,  // ProgramArgumentType.INPUT
                                        val:Object = null,
                                        n:String  = null)
        {
            as400Dta_ = dta;
            argType_  = type;
            value_    = val;
            name_     = n;
        } // ctor

    }

}
