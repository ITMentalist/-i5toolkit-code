/**
 * @file crtmtx.java
 *
 * Test of CRTMTX
 */

import com.ibm.as400.access.*;
import u.*;
import java.io.IOException;

public class crtmtx {

    public static void main(String[] args) {

        // @here
    }

}

class CRTMTXTmpl implements InstructionTemplate {

    private boolean named_ = false;
    // Mutex will remain valid or be destroyed when its owning thread
    // is terminated
    private boolean remain_valid_ = false;
    // can be locked recursively or not
    private boolean recursive_ = false;

    private static final int CRT_TMPL_LEN = 32;

    /// ctor
    public CRTMTXTmpl() {
    }
    public CRTMTXTmpl(boolean named,
                      boolean remainValid,
                      boolean recursive) {
        named_ = named;
        remain_valid_ = remainValid;
        recursive_ = recursive;
    }

    public byte[] toBytes()
        throws IOException
    {

        ByteArray barr = new ByteArray(CRT_TMPL_LEN);
        int name_opt = named_ ? 0x01 : 0x00;
        int validity_opt = remain_valid_ ? 0x01 : 0x00;
        int recursive_opt = recursive_ ? 0x01 : 0x00;
        barr.writeBytes(0x00, 1).         // reserved
            writeBytes(name_opt, 1).
            writeBytes(validity_opt, 1).
            writeBytes(recursive_opt, 1).
            writeBytes(0x00, 28)          // reserved
            ;

        return barr.toBytes();
    }

    public void fromBytes(byte[] hostData)
        throws Exception
    {
        throw new Exception("Oops! This method is yet not implemented!");
    }
}
