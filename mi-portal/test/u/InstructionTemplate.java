/**
 * @file InstructionTemplate.java
 *
 * MI instruction template. This interface defines methods must be
 * implemented by MI instruction template classes.
 */

package u;

public interface InstructionTemplate {

    /**
     *
     */
    byte[] toBytes();

    /**
     * Construct an instruction template from raw data returned from
     * an IBM i server
     */
    void fromBytes(byte[] hostData);
}
