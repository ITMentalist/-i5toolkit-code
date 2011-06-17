/**
 * @file IAS400Data.as
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public interface IAS400Data {

        function read(from:ByteArray) : Object;
        function write(to:ByteArray, val:Object) : void;
    }

}
