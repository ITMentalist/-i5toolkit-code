/**
 * @file HexData.as
 *
 * Hexadecimal data. Hex data is transferred between AS3 client and the IBM i host servers without translation.
 *
 * @todo Add a 'actualLength:uint = 0' parameter to all as400-data classes.
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class HexData implements IAS400Data {

        private var length_:uint;
        public function get length() : uint { return length_; }
        public function set length(len:uint) : void {}

        /**
         * ctor
         * @param [in] len, length in bytes of the hex data
         */
        public function HexData(len:uint) {
            length_ = len;
        }

        /// @return a ByteArray object
        public function read(from:ByteArray,
                             actualLength:uint = 0) : Object {

            var len:uint = length_;
            if(actualLength != 0)   // read number of bytes as what is explicitly specified!
                len = actualLength;

            var r:ByteArray = new ByteArray();
            from.readBytes(r, 0, len);

            return r;
        } // read()

        public function write(to:ByteArray, val:Object) : void {

            var barr:ByteArray = ByteArray(val);
            if(barr.length < length_)
                trace("<< ERROR >>: HexData.write(), input byte-array does not contains enough length of data");
            barr.position = 0;
            to.writeBytes(barr, 0, length_);

        } // write()

    } // class HexData

}
