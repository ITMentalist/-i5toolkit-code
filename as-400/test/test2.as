/**
 * @file test.as
 *
 * Test of class DES.
 */

package {

    import flash.display.*;
    import flash.system.*;
    import flash.text.*;
    import flash.events.*;
    import flash.utils.*; // ByteArray

    import as400.prototype.*;

    public class test2 extends Sprite {

        private var host_fld_:TextField;
        private var ts_fld_:TextField;   // current timestamp on the remote server
        private var btn_:UButton;
        private var host_:String;

        /// ctor
        public function test2() {

            host_ = "g525";

            this.opaqueBackground = new Number(0x00);

            host_fld_ = new TextField();
            host_fld_.width = 200;
            host_fld_.textColor = 0xff4500; // orange red
            host_fld_.alpha     = 0.85;
            host_fld_.text = "Name of your IBM i server: " + host_;
            addChild(host_fld_);

            ts_fld_ = new TextField();
            ts_fld_.width = 200;
            ts_fld_.textColor = 0xadff2f; // green yellow
            ts_fld_.alpha     = 0.8;
            // ts_fld_.autoSize = TextFieldAutoSize.LEFT;
            ts_fld_.antiAliasType = AntiAliasType.ADVANCED;
            ts_fld_.text = "Current Timestamp on " + host_;
            ts_fld_.y = 30;
            addChild(ts_fld_);

            btn_ = new UButton();
            btn_.addEventListener(MouseEvent.CLICK, onBtnClick);
            btn_.y = 100;
            addChild(btn_);
        }

        private function onBtnClick(evt:MouseEvent) : void {
            test_call();
        }

        private function pgmcall_callback(outp:String) : void {
            ts_fld_.text = outp;
        }

        private function test_call() : void {

            var pgm_call:RemoteCommand
                = new RemoteCommand(host_,
                                    "****",
                                    "****", // Can't tell you :p
                                    "QGPL",
                                    "YY275"
                                    );
            pgm_call.callx(this, pgmcall_callback);
        }

    } // class
} // package
