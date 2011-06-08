/**
 * @file test2.as
 *
 * Test of class RemoteCommand.
 */

package {

    import flash.display.*;
    import flash.system.*;
    import flash.text.*;
    import flash.events.*;

    import as400.prototype.*;

    public class test2 extends Sprite {

        private var host_:TextField;
        private var user_:TextField;
        private var pwd_:TextField;
        private var ts_:TextField;   // current timestamp on the remote server
        private var btn_:UButton;

        /// ctor
        public function test2() {

            this.opaqueBackground = new Number(0x8b3a3a);

            // host name
            var host:TextField = new TextField();
            host.width = 200;
            host.alpha     = 0.85;
            host.textColor = 0xff4500;  // orange red
            host.autoSize  = TextFieldAutoSize.RIGHT;
            host.text = "Name of your IBM i server";
            addChild(host);

            host_ = new TextField();
            host_.x = 220;
            host_.width = 200;
            host_.height = 20;
            host_.alpha  = 0.85;
            host_.border = true;
            host_.background = true;
            host_.type   = TextFieldType.INPUT;
            addChild(host_);

            // user name
            var user:TextField = new TextField();
            user.width = 200;
            user.y     = 30
            user.alpha     = 0.85;
            user.textColor = 0xff4500;  // orange red
            user.autoSize  = TextFieldAutoSize.RIGHT;
            user.text = "User name";
            addChild(user);

            user_ = new TextField();
            user_.x = 220;
            user_.y     = 30
            user_.width = 200;
            user_.height = 20;
            user_.alpha  = 0.85;
            user_.border = true;
            user_.background = true;
            user_.type   = TextFieldType.INPUT;
            addChild(user_);

            // password: pwd_.displayAsPassword = true;
            var pwd:TextField = new TextField();
            pwd.width = 200;
            pwd.y     = 60
            pwd.alpha     = 0.85;
            pwd.textColor = 0xff4500;  // orange red
            pwd.autoSize  = TextFieldAutoSize.RIGHT;
            pwd.text = "Password";
            addChild(pwd);

            pwd_ = new TextField();
            pwd_.x = 220;
            pwd_.y     = 60
            pwd_.width = 200;
            pwd_.height = 20;
            pwd_.alpha  = 0.85;
            pwd_.border = true;
            pwd_.background = true;
            pwd_.type   = TextFieldType.INPUT;
            pwd_.displayAsPassword = true;
            addChild(pwd_);

            ts_ = new TextField();
            ts_.x = 100;
            ts_.y = 100;
            ts_.width = 300;
            ts_.height = 20;
            ts_.textColor = 0xadff2f; // green yellow
            ts_.alpha     = 0.8;
            // ts_.autoSize = TextFieldAutoSize.LEFT;
            ts_.antiAliasType = AntiAliasType.ADVANCED;
            ts_.text = "Current timestamp on your IBM i server";
            addChild(ts_);

            btn_ = new UButton();
            btn_.addEventListener(MouseEvent.CLICK, onBtnClick);
            btn_.y = 100;
            addChild(btn_);
        }

        private function onBtnClick(evt:MouseEvent) : void {
            test_call();
        }

        private function pgmcall_callback(outp:String) : void {
            ts_.text = outp;
        }

        private function test_call() : void {

            var pgm_call:RemoteCommand
                = new RemoteCommand(host_.text,
                                    user_.text,
                                    pwd_.text,
                                    "QGPL",
                                    "YY275"
                                    );
            pgm_call.callx(this, pgmcall_callback);
        }

    } // class
} // package
