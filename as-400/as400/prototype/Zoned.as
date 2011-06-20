/**
 * @file Zoned.as
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class Zoned implements IAS400Data {

        public function get length() : uint { return length_; }
        public function set length(len:uint) : void {}

        private var total_digits_:uint;
        private var fractional_digits_:uint;
        private var length_:uint;

        public function Zoned(total_digits:uint,
                               fractional_digits:uint = 0) {

            total_digits_ = total_digits;
            fractional_digits_ = fractional_digits;
            length_ = total_digits;
        }

        public function read(from:ByteArray) : Object {

            var dec:int = 0;
            var sign_bits:int = 0;
            var value:Number = new Number(0);
            var exponent:int =
                total_digits_ - fractional_digits_ - 1;
            for(var i:int = 0; i < length_; i++, exponent--) {

                var e:int = from.readByte();
                dec = e & 0x0F;
                value += dec * Math.pow(10, exponent);

                if(i == length_ - 1)
                    sign_bits = (e & 0xF0) >> 4;
            }

            // sign-bits
            // +: 0-9, A, C, E, F
            // -: B, D
            if(sign_bits == 0x0B || sign_bits == 0x0D)
                value = -value;

            return new Number(value.toFixed(fractional_digits_));
        } // read()

        public function write(to:ByteArray, val:Object) : void {

            var value:Number = Number(val);
            value *= Math.pow(10, fractional_digits_);
            var n:int = int(value.toPrecision(total_digits_));

            var negative:Boolean = n < 0;
            if(negative)
                n = -n;
            var dec:int = 0;
            var exponent:int = total_digits_ - 1;
            for(var i:int = 0; i < length_; i++, exponent--) {

                dec = n / Math.pow(10, exponent);
                n -= dec * Math.pow(10, exponent);

                var place:int = 0;
                if(i == length_ - 1 && negative)
                    place = 0xd0 | dec;
                else
                    place = 0xf0 | dec;

                to.writeByte(place);
            }
        } // write()

    } // class Zoned

}
