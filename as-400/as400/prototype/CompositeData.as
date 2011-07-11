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
 * @file CompositeData.as
 *
 * @todo methods to allower the user to append elements to <var>e_</var>
 * @attention This class is unstable!
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class CompositeData implements IAS400Data {

        public function get length() : uint { return 0; }
        public function set length(len:uint) : void {}

        private var e_:Vector.<IAS400Data>;

        public function CompositeData(... elements) {

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
            var element:IAS400Data = e_.shift();
            return element.read(from);
        }

        public function write(to:ByteArray,
                              val:Object,
                              ... more_objs) : void
        {
            e_[0].write(to, val);

            for(var i:int = 1; i < e_.length; i++) {
                var element:IAS400Data = e_[i];
                element.write(to, more_objs[i - 1]);
            }
        }

    } // class
} // package
