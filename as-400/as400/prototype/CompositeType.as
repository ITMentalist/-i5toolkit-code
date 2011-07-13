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
 * @file Compositetype.as
 *
 * @todo methods to allower the user to append elements to <var>e_</var>
 * @attention This class is unstable!
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class CompositeType implements IAS400Data {

        private var length_:uint;
        /**
         * @remark it's important for classes subclass IAS400Dta to
         * return a valid length value via this
         * method. RemoteCommand.call_program_rqs() relies on this
         * method to tell how many bytes to send to the host server
         * for a single program arguemnt.
         */
        public function get length() : uint {

            length_ = 0;
            for(var i:int = 0; i < e_.length; i++) {
                var element:IAS400Data = e_[i];
                length_ += element.length;
            }

            return length_;
        }
        public function set length(len:uint) : void {}

        private var e_:Vector.<IAS400Data>;

        public function CompositeType(... elements) {

            e_ = new Vector.<IAS400Data>();
            for(var i:int = 0; i < elements.length; i++) {
                if(elements[i] is IAS400Data) {
                    e_.push(elements[i]);
                } else
                    ; // @todo raise exception
            }
        }

        public function read(from:ByteArray,
                             actualLength:uint = 0) : Object
        {
            var len:uint = length_;
            if(actualLength != 0)   // read number of bytes as what is explicitly specified!
                len = actualLength;

            // new CompositeData
            var comp:CompositeData = new CompositeData();
            var vals:Vector.<Object> = comp.elements;

            // read each element from ByteArray `from'
            var bytes_read:uint = 0;
            for(var i:int = 0; i < e_.length && bytes_read < actualLength; i++) {
                var element:IAS400Data = e_[i];
                vals.push(element.read(from));
                bytes_read += element.length;
            }

            return comp;
        }

        public function write(to:ByteArray,
                              val:Object) : void
        {
            // @here Type checking, `is CompositeData'
            var comp:CompositeData = val as CompositeData;
            var vals:Vector.<Object> = comp.elements;

            // write each element of CompositeData to ByteArray `to'
            for(var i:int = 0; i < e_.length; i++) {
                var element:IAS400Data = e_[i];
                element.write(to, vals[i]);
            }
        }

    } // class
} // package
