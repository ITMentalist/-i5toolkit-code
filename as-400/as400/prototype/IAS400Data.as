/**
 * @file IAS400Data.as
 */

package as400.prototype {

    import flash.utils.ByteArray;

    public interface IAS400Data {

        function read(from:ByteArray,
                      actualLength:uint = 0) : Object;
        function write(to:ByteArray,
                       val:Object) : void;
        function get length() : uint;
        function set length(len:uint) : void;
    }

}
