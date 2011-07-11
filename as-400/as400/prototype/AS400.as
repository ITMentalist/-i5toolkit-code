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
 * @file AS400.as
 *
 * @remark 这个类型现在看会空了
 */

package as400.prototype {

    import flash.net.*;

    public class AS400 {

        public static var RMTCMD:String = "as-rmtcmd";
        public static var PORT_RMTCMD:int = 8475;

        /**
         * @todo implement this method
         *
         * - connect to as-svrmap server
         * - send server-name to the host
         * - receive port number from the host
         * @todo 有个问题, 连 as-svrmap (449) 被禁止!
         */
        public static function get_server_port(server_name:String) : int {
            var port:int = -1;

            if(server_name == RMTCMD)
                port = PORT_RMTCMD;

            return port;
        }

    }

}
