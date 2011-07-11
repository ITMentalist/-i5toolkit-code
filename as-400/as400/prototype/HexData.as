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
 * @file HexData.as
 *
 * Hexadecimal data. Hex data is transferred between AS3 client and the IBM i host servers without translation.
 *
 * @todo Add a 'actualLength:uint = 0' parameter to all as400-data classes.
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class HexData implements IAS400Data {

        private var length_:uint;
        public function get length() : uint { return length_; }
        public function set length(len:uint) : void {}

        /**
         * ctor
         * @param [in] len, length in bytes of the hex data
         */
        public function HexData(len:uint) {
            length_ = len;
        }

        /// @return a ByteArray object
        public function read(from:ByteArray,
                             actualLength:uint = 0) : Object {

            var len:uint = length_;
            if(actualLength != 0)   // read number of bytes as what is explicitly specified!
                len = actualLength;

            var r:ByteArray = new ByteArray();
            from.readBytes(r, 0, len);

            return r;
        } // read()

        public function write(to:ByteArray, val:Object,
                              ... no_more) : void {

            var barr:ByteArray = ByteArray(val);
            if(barr.length < length_)
                trace("<< ERROR >>: HexData.write(), input byte-array does not contains enough length of data");
            barr.position = 0;
            to.writeBytes(barr, 0, length_);

        } // write()

    } // class HexData

}
