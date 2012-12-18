/**
 * @file rqs02.java
 */

import com.ibm.as400.access.*;

public class rqs02 {

    public static void main(String[] args) {

        if(args.length == 0) {
            System.out.println("usage: java rqs02 cl-cmd");
            System.exit(1);
        }

        MessageQueue bchmch =
            new MessageQueue(new AS400("system-name", "user-name", "password"),
                             "/qsys.lib/*libl.lib/bchmch.msgq");
        try {
            bchmch.sendInformational(args[0]);
        } catch(Exception e) {
            System.out.println("Oops! " + e.getMessage());
        }
        System.out.println("Command: " + args[0]);
    }

}
