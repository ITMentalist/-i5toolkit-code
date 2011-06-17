/**
 * @file UBin2.as
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class UBin2 extends AS400Data implements IAS400Data {

        public function read(from:ByteArray) : Object {

            var value:uint = from.readUnsignedShort();
            return value;
        }

        public function write(to:ByteArray, val:Object) : void {

            var value:uint = uint(val);
            to.writeShort(value);
        }

    }

}
