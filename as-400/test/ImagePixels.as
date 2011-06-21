/**
 * @file ImagePixels.as
 *
 * Interface tool.ImagePixels
 */

package {

    import flash.display.*;

    public class ImagePixels {

        protected var width_:int;
        protected var height_:int;
        /// must be override by subclasses
        protected var pixels_:Vector.<int> = null;

        public function load(transparent:Boolean = true) : BitmapData {

            var r:BitmapData
                = new BitmapData(width_, height_, transparent);
            for(var i:int = 0; i < width_; i++)
                for(var j:int = 0; j < height_; j++)
                    r.setPixel32(i, j,
                                 uint(pixels_[i * height_ + j]));

            return r;
        }

    }

}
