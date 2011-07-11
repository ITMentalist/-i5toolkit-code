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
 * @file EBCDIC.as
 *
 * @attention design of this class might be modified soon!
 * @todo by now, property <var>ccsid_</var> has no use
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class EBCDIC implements IAS400Data {

        public function get length() : uint { return length_; }
        public function set length(len:uint) : void {}

        private var length_:uint;
        private var ccsid_:uint;
        public function get ccsid() : uint { return ccsid_; }

        /**
         * ctor
         * @param [in] len, length in bytes of the EBCDIC character scalar
         * @param [in] ccsid, CCSID of the EBCDIC character scalar. Default to 37
         */
        public function EBCDIC(len:uint,
                               ccsid:uint = 37) {
            length_ = len;
            ccsid_  = ccsid;
        }

        /// @return a String object
        public function read(from:ByteArray,
                             actualLength:uint = 0) : Object {

            var len:uint = length_;
            if(actualLength != 0)   // read number of bytes as what is explicitly specified!
                len = actualLength;

            var r:String = "";
            for(var i:int = 0; i < len; i++) {

                var ch:int = from.readByte();
                if(ch < 0)
                    ch &= 0XFF;
                r += String.fromCharCode(Conv37._qascii[ch]);
            }

            return r;
        } // read()

        public function write(to:ByteArray, val:Object,
                              ... no_more) : void {

            var str:String = String(val);
            // pad str with white spaces
            while(str.length < length_) str += " ";

            for(var i:int = 0; i < length_; i++) {

                var ch:int = int(str.charCodeAt(i));
                if(ch < 0)
                    ch &= 0xFF;
                to.writeByte(Conv37._qebcdic[ch]);
            }

        } // write()

    } // class EBCDIC

}
