/**
 * @file UButton.as
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

