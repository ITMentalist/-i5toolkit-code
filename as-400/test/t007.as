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
 * @file t007.as
 *
 * Test of the Queue Object APIs provided by subproject Queue Tools
 * (http://i5toolkit.sourceforge.net/q/index.html).
 *
 * @pre *USRQ QGPL/Q007
  4 > CALL PGM(QUSCRTUQ) PARM('Q007      QGPL' 'UUQQ' 'F' X'00000000' X'0000004
      0' X'00000010' X'00000010' '*CHANGE' 'FIFO *USRQ, max message length: 64'
      )                                                                        
 */

package {

    import flash.display.*;
    import flash.utils.*;
    import flash.events.*;
    import flash.text.*;

    import as400.prototype.*;

    public class t007 extends Sprite {

        private var s_fmt:TextFormat;
        private var i_fmt:TextFormat;
        private var s_host:TextField;
        private var i_host:TextField;
        private var s_user:TextField;
        private var i_user:TextField;
        private var s_pwd:TextField;
        private var i_pwd:TextField;
        private var s_msg:TextField;
        private var i_msg:TextField;
        private var i_sts:TextField; // the status line

        private var btn_:Button1;

        public function t007() {

            init();
        }

        private function onBtnClick(evt:MouseEvent) : void {
            trace("天哪 ...");
            var pgm_call:RemoteCommand =
                new RemoteCommand(i_host.text,
                                  i_user.text,
                                  i_pwd.text,
                                  "I5TOOLKIT",
                                  "ENQ");
            var i:int = 0;
            var exp_id:String = ""; for(i = 0; i < 7; i++) exp_id += String.fromCharCode(0);
            var exp_data:ByteArray = new ByteArray(); for(i = 0; i < 16; i++) exp_data.writeByte(0);
            var argl:Vector.<ProgramArgument> =
                new <ProgramArgument>[new ProgramArgument(new EBCDIC(20),
                                                          ProgramArgument.INPUT,
                                                          "Q007      QGPL"),
                                      new ProgramArgument(new EBCDIC(1),
                                                          ProgramArgument.INPUT,
                                                          String.fromCharCode(2)),
                                      new ProgramArgument(new Bin4(),
                                                          ProgramArgument.INPUT,
                                                          0),
                                      new ProgramArgument(new EBCDIC(1),
                                                          ProgramArgument.INPUT,
                                                          String.fromCharCode(0)),
                                      new ProgramArgument(new Bin4(),
                                                          ProgramArgument.INPUT,
                                                          64),
                                      new ProgramArgument(new EBCDIC(64),
                                                          ProgramArgument.INPUT,
                                                          i_msg.text),
                                      new ProgramArgument(new CompositeType(new Bin4(),
                                                                            new Bin4(),
                                                                            new EBCDIC(7),
                                                                            new EBCDIC(1),
                                                                            new HexData(16)),
                                                          ProgramArgument.INOUT,
                                                          new CompositeData(32,
                                                                            0,
                                                                            exp_id,
                                                                            String.fromCharCode(0),
                                                                            exp_data)
                                                          ) // Qus_EC_t
                                      ];
            pgm_call.callx(this, enq_callback, argl);

        }

        private function enq_callback(rc:int,
                                      argl:Vector.<ProgramArgument>,
                                      msg:String = null) : void {
            trace("Call to ENQ returns ...");

            var ec:CompositeData = argl[6].value as CompositeData;
            var ds:Vector.<Object> = ec.elements;
            trace("ec.bytes-in:", ds[0]); // ec.bytes-in
            if(ds.length > 1) {
                trace("ec.bytes-out:", ds[1]); // ec.bytes-out
                trace("ec.exp_id:", ds[2]);
            } else
                trace("ec.bytes-out NOT returned!!");
        }

        private function init() : void {
            // size of stage
            // trace("<<<<<<<<<< size of stage:", root.stage.stageWidth, root.stage.stageHeight);

            // root.stage.displayState = StageDisplayState.FULL_SCREEN;
            // trace("<<<<<<<<<< size of stage:", root.stage.stageWidth, root.stage.stageHeight);

            i_sts = new TextField();
            var fmt:TextFormat = new TextFormat("Courier", 18, 0xb8860b, true);
            i_sts.alpha = 0.65;
            i_sts.text  = "... Click the apple!";
            i_sts.width = 200;
            i_sts.height = 90;
            i_sts.x = 500 - i_sts.width;
            i_sts.y = 375 - i_sts.height;
            i_sts.autoSize = TextFieldAutoSize.RIGHT;
            i_sts.setTextFormat(fmt);  // 太气人了, 这个调用是不是成居然跟 调用时点有关系 ~~ FAINT!!
            addChild(i_sts);

            s_fmt = new TextFormat("Courier", 16, 0x483d8b, true);
            i_fmt = new TextFormat("Courier", 16, 0xffa500, true);

            // host server
            s_host = new TextField();
            s_host.autoSize = TextFieldAutoSize.RIGHT;
            s_host.text = "Host name";
            s_host.x = 100;
            s_host.y = 70;
            s_host.width = 100;
            s_host.height = 20;
            s_host.setTextFormat(s_fmt);
            addChild(s_host);

            i_host = new TextField();
            i_host.x = s_host.x + s_host.width + 20;
            i_host.y = s_host.y;
            i_host.width = 100 + 50;
            i_host.height = 20;
            i_host.border = true;
            i_host.text = "demo.???.com";
            i_host.type   = TextFieldType.INPUT;
            i_host.setTextFormat(i_fmt);
            addChild(i_host);

            // user name/password
            s_user = new TextField();
            s_user.autoSize = TextFieldAutoSize.RIGHT;
            s_user.text = "User name";
            s_user.x = 100;
            s_user.y = s_host.y + 30;
            s_user.width = 100;
            s_user.height = 20;
            s_user.setTextFormat(s_fmt);
            addChild(s_user);

            i_user = new TextField();
            i_user.x = s_user.x + s_user.width + 20;
            i_user.y = s_user.y;
            i_user.width = 100;
            i_user.height = 20;
            i_user.border = true;
            i_user.text = "HENRY";
            i_user.type   = TextFieldType.INPUT;
            i_user.setTextFormat(i_fmt);
            addChild(i_user);

            s_pwd = new TextField();
            s_pwd.autoSize = TextFieldAutoSize.RIGHT;
            s_pwd.text = "Password";
            s_pwd.x = 100;
            s_pwd.y = s_user.y + 30;
            s_pwd.width = 100;
            s_pwd.height = 20;
            s_pwd.setTextFormat(s_fmt);
            addChild(s_pwd);

            i_pwd = new TextField();
            i_pwd.x = s_pwd.x + s_pwd.width + 20;
            i_pwd.y = s_pwd.y;
            i_pwd.width = 100;
            i_pwd.height = 20;
            i_pwd.border = true;
            i_pwd.text = "HENRY";
            i_pwd.displayAsPassword = true;
            i_pwd.type   = TextFieldType.INPUT;
            i_pwd.setTextFormat(i_fmt);
            addChild(i_pwd);

            // message to enqueue
            s_msg = new TextField();
            s_msg.autoSize = TextFieldAutoSize.RIGHT;
            s_msg.text = "Message to ENQ";
            s_msg.x = 100;
            s_msg.y = s_pwd.y + 30;
            s_msg.width = 100;
            s_msg.height = 20;
            s_msg.setTextFormat(s_fmt);
            addChild(s_msg);

            i_msg = new TextField();
            i_msg.x = s_msg.x + s_msg.width + 20;
            i_msg.y = s_msg.y;
            i_msg.width = 210;
            i_msg.height = 20;
            i_msg.border = true;
            i_msg.text = "Glad to meet you :p";
            i_msg.type   = TextFieldType.INPUT;
            i_msg.setTextFormat(i_fmt);
            addChild(i_msg);

            // a button
            // @todo i think i need a pretty on
            //            var btn:Sprite = new Sprite();
            var apple:*;
            apple = new RedApple();
            var red:BitmapData = apple.load();
            apple = new GreenApple();
            var green:BitmapData = apple.load();

            btn_ = new Button1(green, red, 15);
            btn_.x = 100;
            btn_.y = i_sts.y;
            // register event listener
            btn_.addEventListener(MouseEvent.CLICK, onBtnClick);
            addChild(btn_);
        }

    } // class t007

}
