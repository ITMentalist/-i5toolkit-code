/**
 * @file Float8.as
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public class Float8 extends AS400Data implements IAS400Data {

        public function read(from:ByteArray) : Object {

            var value:Number = from.readDouble();
            return value;
        }

        public function write(to:ByteArray, val:Object) : void {

            var value:Number = Number(val);
            to.writeDouble(value);
        }

    }

}
