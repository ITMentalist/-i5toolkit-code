/**
 * @file test.as
 *
 * Test of class DES.
 */

package {

    import flash.display.*;
    import flash.system.*;
    import flash.utils.*; // ByteArray

    import as400.prototype.*;

    public class test extends Sprite {

        /// ctor
        public function test() {

            // test_des();
            // test_enc();
            // test_call();
        }

        private function pgmcall_callback(outp:String) : void {
            trace("test.pgmcall_callback():", outp);
        }

        private function test_call() : void {

            var pgm_call:RemoteCommand
                = new RemoteCommand("g525",
                                    "JZKJ      ",
                                    "JZKJ      ",
                                    "LSBIN     ",
                                    "YY275     "
                                    );
            pgm_call.callx(this, pgmcall_callback);
        }

        private function fillb8(v:Vector.<int>) : ByteArray {

            var r:ByteArray = new ByteArray();
            for(var i:int = 0; i < 8; i++)
                r.writeByte(v[i]);
            r.position = 0;
            return r;
        }

        /// prepare an encrypted password for authentication
        private function test_enc() : void {

            trace(">>>>>>>>>> test_enc() <<<<<<<<");

            var user:String = "JZKJ";
            var pwd:String = "JZKJ";
            var e_user:ByteArray = Conv37.to_ebcdic(user); trace("e_user", ENC.listb8(e_user));
            var e_pwd:ByteArray = Conv37.to_ebcdic(pwd);   trace("e_pwd", ENC.listb8(e_pwd));

            // prepared client-side seed and server-side seed
            var cseed:ByteArray = fillb8(new <int>[0, 0, 1, 48, 63, -74, -70, 52]);  trace("cseed", ENC.listb8(cseed));
            var sseed:ByteArray =  fillb8(new <int>[-63, -70, 117, -118, -122, -74, 50, -113]); trace("sseed", ENC.listb8(sseed));

            // @here
            var enc_pwd:ByteArray
                = ENC.encrypt_password(e_user,
                                       user.length,
                                       e_pwd,
                                       pwd.length,
                                       cseed,
                                       sseed); // -71, 36, -11, -38, -118, -71, -54, 50
            for(var i:int = 0; i < 8; i++)
                trace(i, enc_pwd.readByte());

        }

        private function test_des() : void {

            trace(">>>>>>>>>> test_des() <<<<<<<<");

            // user name: JZKJ
            var user:ByteArray
                = fillb8(new <int>[-47, -23, -46, -47, 64, 64, 64, 64, 64, 64]);
            user.position = 0;

            // pwd: JZKJ after messed up
            var pwd:ByteArray
                = fillb8(new <int>[9, 121, 15, 8, 42, 42, 42, 42, 64, 64]);
            pwd.position = 0;

            var des:DES = new DES();
            var encDta:ByteArray = des.encode_des(user, pwd);
            trace("encrypted pwd:", ENC.listb8(encDta));
            for(var i:int = 0; i < encDta.length; i++)
                trace(i, " - ", encDta.readByte());

            // what's expeceted is: hex DD, CC, 89, 27, 0B, 84, 55, E2
        }

    }

}
