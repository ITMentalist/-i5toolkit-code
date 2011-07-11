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
 * @file t006.as
 *
 * Test of class as400.prototype.CompositeData
 */

package {

    import flash.display.*;
    import flash.utils.*;
    import as400.prototype.*;

    public class t006 extends Sprite {

        public function t006() {

            var a:CompositeData =
                new CompositeData(new Bin2(),
                                  new EBCDIC(30));

            var host_data:ByteArray = new ByteArray();

            // write()
            var obj_name:String = "E006                          ";
            a.write(host_data, 0x1934, obj_name);

            // read()
            host_data.position = 0;
            var b2:int = a.read(host_data) as int;
            var str:String = a.read(host_data) as String;

            trace(b2, ",", "'" + str + "'");
        }

    } // class t006

}
