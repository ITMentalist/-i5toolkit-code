/**
 * @file Button1.as
 */

package {

    import flash.display.*;
    import flash.events.*;

    public class Button1 extends Sprite {

        private var normal_:BitmapData;
        private var under_mouse_:BitmapData;
        private var disp_:int; // displacement from original X position
        private var X_:int;
        private var cur_disp_:int;

        /// ctor
        public function Button1(normal:BitmapData,
                                under_mouse:BitmapData,
                                disp:int) {

            normal_ = normal;
            under_mouse_ = under_mouse;
            disp_ = disp;

            // draw normal image
            graphics.beginBitmapFill(normal, null, false);
            graphics.drawRect(0, 0, normal.width, normal.height);
            graphics.endFill();

            addEventListener(MouseEvent.CLICK, on_click);
            addEventListener(MouseEvent.MOUSE_OVER, on_mouse_over);
            addEventListener(MouseEvent.MOUSE_OUT, on_mouse_out);
        }

        private function on_click(e:MouseEvent) : void {
            X_ = x; trace("original X =", X_);
            x += disp_;
            addEventListener(Event.ENTER_FRAME, on_enter_frame);
        }

        private function on_enter_frame(e:Event) : void {

            x = X_ - (x - X_) + ((x - X_) > 0 ? 1 : -1 );

            if(Math.abs(x - X_) < 1) {
                x = X_; trace("current X =", X_);
                removeEventListener(Event.ENTER_FRAME, on_enter_frame);
            }
        }

        private function on_mouse_over(e:MouseEvent) : void {
            // draw under-mouse image
            graphics.beginBitmapFill(under_mouse_, null, false);
            graphics.drawRect(0, 0, under_mouse_.width, under_mouse_.height);
            graphics.endFill();
        }

        private function on_mouse_out(e:MouseEvent) : void {
            // draw normal image
            graphics.beginBitmapFill(normal_, null, false);
            graphics.drawRect(0, 0, normal_.width, normal_.height);
            graphics.endFill();
        }

    }

}

