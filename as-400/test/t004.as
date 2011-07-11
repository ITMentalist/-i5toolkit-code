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
 * @file t004.as
 *
 * Test of class RemoteCommand.
 * This test program calls RPG program YY282, which accepts an INPUT bin(2) arg and OUTPUT arg of type bin(4), packed(8,2), zoned(16,5) respectively.
 */

package {

    import flash.display.*;
    import flash.system.*;
    import flash.text.*;
    import flash.events.*;
    import flash.net.URLRequest;

    import as400.prototype.*;

    public class t004 extends Sprite {

        private var host_:TextField;
        private var user_:TextField;
        private var pwd_:TextField;
        private var ts_:TextField;   // current timestamp on the remote server
        private var btn_:UButton;

        private var pgm_call:RemoteCommand;
        private var argl:Vector.<ProgramArgument>;

        /// ctor
        public function t004() {

            load_image();

            var fmt:TextFormat = new TextFormat("Courier");
            fmt.bold = true;
            fmt.size = 14;
            // host name
            var host:TextField = new TextField();
            host.x = 50;
            host.y = 230;
            host.width = 200;
            host.alpha     = 0.85;
            host.textColor = 0xff4500;  // orange red
            host.autoSize  = TextFieldAutoSize.RIGHT;
            host.text = "Name of your IBM i server";
            host.setTextFormat(fmt);
            addChild(host);

            host_ = new TextField();
            host_.x = 220 + 50;
            host_.y = 230;
            host_.width = 200;
            host_.height = 20;
            host_.alpha  = 0.65;
            host_.border = true;
            host_.background = true;
            host_.type   = TextFieldType.INPUT;
            addChild(host_);

            // user name
            var user:TextField = new TextField();
            user.width = 200;
            user.y     = 30 + 230;
            user.alpha     = 0.85;
            user.textColor = 0xff4500;  // orange red
            user.autoSize  = TextFieldAutoSize.RIGHT;
            user.text = "User name";
            user.setTextFormat(fmt);
            addChild(user);

            user_ = new TextField();
            user_.x = 220 + 50;
            user_.y     = 30 + 230;
            user_.width = 200;
            user_.height = 20;
            user_.alpha  = 0.65;
            user_.border = true;
            user_.background = true;
            user_.type   = TextFieldType.INPUT;
            addChild(user_);

            // password: pwd_.displayAsPassword = true;
            var pwd:TextField = new TextField();
            pwd.width = 200;
            pwd.y     = 60 + 230;
            pwd.alpha     = 0.85;
            pwd.textColor = 0xff4500;  // orange red
            pwd.autoSize  = TextFieldAutoSize.RIGHT;
            pwd.text = "Password";
            pwd.setTextFormat(fmt);
            addChild(pwd);

            pwd_ = new TextField();
            pwd_.x = 220 + 50;
            pwd_.y     = 60 + 230;
            pwd_.width = 200;
            pwd_.height = 20;
            pwd_.alpha  = 0.65;
            pwd_.border = true;
            pwd_.background = true;
            pwd_.type   = TextFieldType.INPUT;
            pwd_.displayAsPassword = true;
            addChild(pwd_);

            ts_ = new TextField();
            ts_.x = 100 + 50;
            ts_.y = 100 + 230;
            ts_.width = 300;
            ts_.height = 20;
            ts_.textColor = 0xadff2f; // green yellow
            ts_.alpha     = 0.9;
            // ts_.autoSize = TextFieldAutoSize.LEFT;
            ts_.antiAliasType = AntiAliasType.ADVANCED;
            ts_.text = "OUTPUT arguments of *PGM YY282";
            ts_.setTextFormat(fmt);
            addChild(ts_);

            btn_ = new UButton();
            btn_.addEventListener(MouseEvent.CLICK, onBtnClick);
            btn_.x = 50;
            btn_.y = 100 + 230;
            addChild(btn_);

        }

        private function onBtnClick(evt:MouseEvent) : void {
            test_call();
        }

        private function pgmcall_callback(rc:int,
                                          argl:Vector.<ProgramArgument>,
                                          msg:String = null) : void {
            if(rc != 0)
                ts_.text = msg;
            else
                ts_.text = "OUTPUT arguments of *PGM YY282: "
                    + argl[1].value.toString()
                    + ", "
                    + argl[2].value.toString()
                    + ", "
                    + argl[3].value.toString();
        }

        private function test_call() : void {

            if(pgm_call == null) {
                pgm_call
                    = new RemoteCommand(host_.text,
                                        user_.text,
                                        pwd_.text,
                                        "QGPL",
                                        "YY282",
                                        true        // reuse the pgm-call object
                                        );

                // compose the argument list
                argl
                    = new <ProgramArgument>[new ProgramArgument(new Bin2(),
                                                                ProgramArgument.INPUT,
                                                                95),
                                            new ProgramArgument(new Bin4(),
                                                                ProgramArgument.OUTPUT),
                                            new ProgramArgument(new Packed(8, 2),
                                                                ProgramArgument.OUTPUT),
                                            new ProgramArgument(new Zoned(16, 5),
                                                                ProgramArgument.OUTPUT)];

            }

            // call target program on host server
            pgm_call.callx(this, pgmcall_callback, argl);
        }

        private function load_image() : void {

            var l:Loader = new Loader();
            l.load(new URLRequest("./yy282.png"));
            addChild(l);
        }

    } // class
} // package
