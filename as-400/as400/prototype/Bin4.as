/**
 * @file Bin4.as
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class Bin4 extends AS400Data implements IAS400Data {

        public function read(from:ByteArray) : Object {

            var value:int = from.readInt();
            return value;
        }

        public function write(to:ByteArray, val:Object) : void {

            var value:int = int(val);
            to.writeInt(value);
        }

    }

}
