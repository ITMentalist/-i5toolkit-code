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
 * @attention This class is unstable!
 */

package as400.prototype {

    public class CompositeData {

        // properties
        // public, vecotr of Object
        private var e_:Vector.<Object>;
        public function get elements() : Vector.<Object> { return e_; }
        public function set elements(e:Vector.<Object>) : void { e_ = e; }

        public function CompositeData(... elements) {

            e_ = new Vector.<Object>();
            for(var i:int = 0; i < elements.length; i++)
                e_.push(elements[i]);
        }

    } // class
} // package
