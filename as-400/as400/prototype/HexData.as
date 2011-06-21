/**
 * @file HexData.as
 *
 * Hexadecimal data. Hex data is transferred between AS3 client and the IBM i host servers without translation.
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
        public function read(from:ByteArray) : Object {

            var r:ByteArray = new ByteArray();
            from.readBytes(r, 0, length_);

            return r;
        } // read()

        public function write(to:ByteArray, val:Object) : void {

            var barr:ByteArray = ByteArray(val);
            if(barr.length < length_)
                trace("<< ERROR >>: HexData.write(), input byte-array does not contains enough length of data");
            to.writeBytes(barr, 0, length_);

        } // write()

    } // class HexData

}
