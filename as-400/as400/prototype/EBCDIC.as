/**
 * @file EBCDIC.as
 *
 * @attention design of this class might be modified soon!
 * @todo by now, property <var>ccsid_</var> has no use
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class EBCDIC implements IAS400Data {

        public function get length() : uint { return length_; }
        public function set length(len:uint) : void {}

        private var length_:uint;
        private var ccsid_:uint;
        public function get ccsid() : uint { return ccsid_; }

        /**
         * ctor
         * @param [in] len, length in bytes of the EBCDIC character scalar
         * @param [in] ccsid, CCSID of the EBCDIC character scalar. Default to 37
         */
        public function EBCDIC(len:uint,
                               ccsid:uint = 37) {
            length_ = len;
            ccsid_  = ccsid;
        }

        /// @return a String object
        public function read(from:ByteArray,
                             actualLength:uint = 0) : Object {

            var len:uint = length_;
            if(actualLength != 0)   // read number of bytes as what is explicitly specified!
                len = actualLength;

            var r:String = "";
            for(var i:int = 0; i < len; i++) {

                var ch:int = from.readByte();
                if(ch < 0)
                    ch &= 0XFF;
                r += String.fromCharCode(Conv37._qascii[ch]);
            }

            return r;
        } // read()

        public function write(to:ByteArray, val:Object) : void {

            var str:String = String(val);
            // pad str with white spaces
            while(str.length < length_) str += " ";

            for(var i:int = 0; i < length_; i++) {

                var ch:int = int(str.charCodeAt(i));
                if(ch < 0)
                    ch &= 0xFF;
                to.writeByte(Conv37._qebcdic[ch]);
            }

        } // write()

    } // class EBCDIC

}
