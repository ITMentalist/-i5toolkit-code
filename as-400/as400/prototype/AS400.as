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
