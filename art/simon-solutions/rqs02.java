/**
 * @file ii274.java
 *
 * utilizing jt400's MessageQueue class to ... SNDMSG
 */

import com.ibm.as400.access.*;

public class ii274 {

    public static void main(String[] args) {

        if(args.length == 0) {
            System.out.println("usage: java ii274 cl-cmd");
            System.exit(1);
        }

        MessageQueue mm1 =
            new MessageQueue(new AS400(),
                             /* new AS400("system-name", "user-name", "password"), */
                             "/qsys.lib/*libl.lib/bchmch.msgq");
        try {
            mm1.sendInformational(args[0]);
        } catch(Exception e) {
            System.out.println("Oops! " + e.getMessage());
        }
        System.out.println("Command: " + args[0]);
    }

}
