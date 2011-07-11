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
 * @file UButton.as
 *
 * @deprecated Rewrite this class or replace it with other classes.
 */

package {

    import flash.display.*;
    import flash.system.*;
    import flash.text.*;
    import flash.events.*;
    import flash.utils.*;

    public class UButton extends Sprite {

        private var t_:TextField;

        public function UButton() {

            trace("UButton()");
            this.addEventListener(Event.ENTER_FRAME, doEveryFrame);

            t_ = new TextField;
            t_.width = 80;
            t_.autoSize = TextFieldAutoSize.CENTER;
            t_.textColor = 0xffc125; // goldenrod1
            t_.alpha = 0.8;
            t_.text = "Click me";
            addChild(t_);
        }

        private function doEveryFrame(evt:Event) : void {

            graphics.clear();
            graphics.beginFill(0xbc8f8f /* rosy brown*/, 0.6);
            graphics.drawRoundRect(0, 0, 90, 20, 10);
            graphics.endFill();
        }

    }


}

