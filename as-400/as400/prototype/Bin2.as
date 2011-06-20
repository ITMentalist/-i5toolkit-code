/**
 * @file Bin2.as
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class Bin2 implements IAS400Data {

        public function get length() : uint { return 2; }
        public function set length(len:uint) : void {}

        public function read(from:ByteArray) : Object {

            var value:int = from.readShort();
            return value;
        }

        public function write(to:ByteArray, val:Object) : void {

            var value:int = int(val);
            to.writeShort(value);
        }

    }

}
