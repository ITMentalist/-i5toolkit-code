/**
 * @file UBin4.as
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class UBin4 implements IAS400Data {

        public function get length() : uint { return 4; }
        public function set length(len:uint) : void {}

        public function read(from:ByteArray,
                             actualLength:uint = 0) : Object {

            /// @todo what to do with actualLength ??

            var value:uint = from.readUnsignedInt();
            return value;
        }

        public function write(to:ByteArray, val:Object) : void {

            var value:uint = uint(val);
            to.writeUnsignedInt(value);
        }

    }

}
