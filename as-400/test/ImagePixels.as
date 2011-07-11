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
