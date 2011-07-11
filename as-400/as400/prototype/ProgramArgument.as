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
