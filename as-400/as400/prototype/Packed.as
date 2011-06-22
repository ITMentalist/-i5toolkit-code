/**
 * @file Packed.as
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class Packed implements IAS400Data {

        public function get length() : uint { return length_; }
        public function set length(len:uint) : void {}

        private var total_digits_:uint;
        private var fractional_digits_:uint;
        private var length_:uint;

        public function Packed(total_digits:uint,
                               fractional_digits:uint = 0) {

            total_digits_ = total_digits;
            fractional_digits_ = fractional_digits;
            length_ = total_digits / 2 + 1;
        }

        public function read(from:ByteArray,
                             actualLength:uint = 0) : Object {

            /// @todo what to do with actualLength ??

            // convert
            var v:Vector.<int> = new Vector.<int>(length_ * 2);
            for(var i:int = 0; i < length_; i++) {
                var e:int = from.readByte();
                v[i * 2] = (e & 0xF0) >> 4;  // e.g. 0x9D
                v[i * 2 + 1] = e & 0x0F;
            }

            // is the the first 4-bit useful?
            if(total_digits_ % 2 == 0)
                v.shift(); // erase the first 4-bit

            var value:Number = new Number(0);
            var exponent:int =
                total_digits_ - fractional_digits_ - 1;
            for(i = 0; i < total_digits_; i++, exponent--) {
                var dec:uint = v.shift();
                value += dec * Math.pow(10, exponent);
            }

            // sign
            var sign_bits:int = v[v.length - 1];
            // +: 0-9, A, C, E, F
            // -: B, D
            if(sign_bits == 0x0B || sign_bits == 0x0D)
                value = -value;

            return new Number(value.toFixed(fractional_digits_));
        }

        public function write(to:ByteArray, val:Object) : void {

            var value:Number = Number(val);
            value *= Math.pow(10, fractional_digits_);
            var n:int = int(value.toPrecision(total_digits_));

            var negative:Boolean = n < 0;
            if(negative)
                n = -n;
            var dec:int = 0;
            var exponent:int = total_digits_ - 1;
            var v:Vector.<int> = new Vector.<int>();
            if(total_digits_ % 2 == 0)
                v.push(0);

            for(var i:int = 0; i < total_digits_; i++, exponent--) {

                dec = n / Math.pow(10, exponent);
                n -= dec * Math.pow(10, exponent);
                v.push(dec);
            }

            // add sign 4-bit at the end
            if(negative)
                v.push(0x0D);
            else
                v.push(0x0F);

            // write 4-bit values in v to `to'
            for(i = 0; i < v.length; i+=2) {
                var place:int = (v[i] << 4) | v[i+1];
                to.writeByte(place);
            }
        } // write()

    } // class Packed

}
