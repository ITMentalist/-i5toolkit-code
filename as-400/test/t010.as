/**
 * @file t010.as
 *
 * Test of MI Portal. MI instructions involved in this programs are:
 *  - _RSLVSP2
 *  - _DEQWAIT
 */

package {

    import flash.display.*;
    import flash.events.*;
    import as400.prototype.*;

    public class t010 extends Sprite {

        private var hib_:HostInfoBar;
        private var btn_:Button1;
        private var miportal_:RemoteCommand;
        private var fp_:FloatPanel;

        /// ctor
        public function t010() {

            fp_ = new FloatPanel();
            fp_.x = 300;
            fp_.y = 150;
            fp_.width = 100;
            fp_.height = 100;
            addChild(fp_);

            hib_ = new HostInfoBar();
            hib_.x = hib_.y = 0;
            hib_.width = 500; hib_.height = 60;
            addChild(hib_);

            var apple:*;
            apple = new RedApple();
            var red:BitmapData = apple.load();
            apple = new GreenApple();
            var green:BitmapData = apple.load();

            btn_ = new Button1(green, red, 15);
            btn_.x = 100;
            btn_.y = 300;
            // register event listener
            btn_.addEventListener(MouseEvent.CLICK, onBtnClick);
            addChild(btn_);

            miportal_ =
                new RemoteCommand(hib_.host,
                                  hib_.user,
                                  hib_.password,
                                  "I5TOOLKIT",
                                  "MIPORTAL",
                                  true);
        }

        private function onBtnClick(evt:MouseEvent) : void {

            // @here resolve targe queue object, deq, ...
        }

    }

}

import flash.display.*;
import flash.text.*;

class FloatPanel extends Sprite {
    private var btn_:Button1;

    public function FloatPanel() {

        var g:Graphics = graphics;
        g.beginFill(0xbdb76b, 0.1);
        g.drawRect(0, 0, 500, 300);
        g.endFill();

        var apple:*;
        apple = new RedApple();
        var red:BitmapData = apple.load();
        apple = new GreenApple();
        var green:BitmapData = apple.load();

        btn_ = new Button1(green, red, 15);
        btn_.x = 10;
        btn_.y = 30;
        addChild(btn_);
    }
}

class HostInfoBar extends Sprite {

    private var s_fmt:TextFormat;
    private var i_fmt:TextFormat;
    private var u_fmt:TextFormat;

    private var s_host:TextField;
    private var i_host:TextField;
    private var s_user:TextField;
    private var i_user:TextField;
    private var s_pwd:TextField;
    private var i_pwd:TextField;

    public function get host() : String {
        return i_host.text;
    }

    public function get user() : String {
        return i_user.text;
    }

    public function get password() : String {
        return i_pwd.text;
    }

    /// ctor
    public function HostInfoBar() {

        s_fmt = new TextFormat("Courier", 6, 0x483d8b, true);
        i_fmt = new TextFormat("Courier", 6, 0xffa500, true);

        // host server
        s_host = new TextField();
        s_host.autoSize = TextFieldAutoSize.RIGHT;
        s_host.text = "Host name";
        s_host.x = 10;
        s_host.y = 10;
        s_host.width = 30;
        s_host.height = 12;
        s_host.setTextFormat(s_fmt);
        addChild(s_host);

        i_host = new TextField();
        i_host.x = s_host.x + s_host.width + 2;
        i_host.y = s_host.y;
        i_host.width = 30;
        i_host.height = 12;
        i_host.border = true;
        i_host.text = "demo.xxx.com";
        i_host.type   = TextFieldType.INPUT;
        i_host.setTextFormat(i_fmt);
        addChild(i_host);

        // user name/password
        s_user = new TextField();
        s_user.autoSize = TextFieldAutoSize.RIGHT;
        s_user.text = "User name";
        s_user.x = 10;
        s_user.y = s_host.y + 18;
        s_user.width = 30;
        s_user.height = 12;
        s_user.setTextFormat(s_fmt);
        addChild(s_user);

        i_user = new TextField();
        i_user.x = s_user.x + s_user.width + 2;
        i_user.y = s_user.y;
        i_user.width = 30;
        i_user.height = 12;
        i_user.border = true;
        i_user.text = "HENRY";
        i_user.type   = TextFieldType.INPUT;
        i_user.setTextFormat(i_fmt);
        addChild(i_user);

        s_pwd = new TextField();
        s_pwd.autoSize = TextFieldAutoSize.RIGHT;
        s_pwd.text = "Password";
        s_pwd.x = 10;
        s_pwd.y = s_user.y + 18;
        s_pwd.width = 30;
        s_pwd.height = 12;
        s_pwd.setTextFormat(s_fmt);
        addChild(s_pwd);

        i_pwd = new TextField();
        i_pwd.x = s_pwd.x + s_pwd.width + 2;
        i_pwd.y = s_pwd.y;
        i_pwd.width = 30;
        i_pwd.height = 12;
        i_pwd.border = true;
        i_pwd.text = "HENRY";
        i_pwd.displayAsPassword = true;
        i_pwd.type   = TextFieldType.INPUT;
        i_pwd.setTextFormat(i_fmt);
        addChild(i_pwd);

    }
}
