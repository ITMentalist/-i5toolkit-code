/**
 * @file Float8.as
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class Float8 implements IAS400Data {

        public function get length() : uint { return 8; }
        public function set length(len:uint) : void {}

        public function read(from:ByteArray,
                             actualLength:uint = 0) : Object {

            /// @todo what to do with actualLength ??

            var value:Number = from.readDouble();
            return value;
        }

        public function write(to:ByteArray, val:Object) : void {

            var value:Number = Number(val);
            to.writeDouble(value);
        }

    }

}
