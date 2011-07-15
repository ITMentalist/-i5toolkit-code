/**
 * @file t008.as
 *
 * Test of UI components classes.
 */

package {

    import flash.display.*;
    import flash.events.*;

    public class t008 extends Sprite {

        private var btn_:Button1;

        /// ctor
        public function t008() {

            var mushroom:GMush = new GMush();
            var bmp:BitmapData = mushroom.load();
            graphics.beginBitmapFill(bmp, null, false);
            graphics.drawRect(0, 0, bmp.width, bmp.height);
            graphics.endFill();

            var apple:*;
            apple = new RedApple();
            var red:BitmapData = apple.load();
            apple = new GreenApple();
            var green:BitmapData = apple.load();

            btn_ = new Button1(green, red, 15);
            btn_.x = 100;
            btn_.y = 300;
            addChild(btn_);
        }

    }

}
