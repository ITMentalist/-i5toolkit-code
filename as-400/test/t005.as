/**
 * @file t005.as
 *
 * Test of calling IBM i APIs using class RemoteCommand.
 * @todo reuse a program-call object
 */

package {

    import flash.display.Sprite;
    import flash.utils.ByteArray;

    import as400.prototype.*;

    public class t005 extends Sprite {

        private var host:String = "g525";
        private var user:String = "ljl";
        private var pwd:String  = "ydostars";
        private var pgm_call:RemoteCommand;
        private var q:Vector.<Function>;
        private var argl:Vector.<ProgramArgument>;
        private var cmd_argl:Vector.<ProgramArgument>;

        public function t005() {

            pgm_call
                = new RemoteCommand(host,
                                    user,
                                    pwd,
                                    "QSYS",
                                    "QUSCRTUS");

            q = new Vector.<Function>();

            q.push(change_usrspc);
            q.push(dump_usrspc);
            q.push(delete_usrspc);

            create_usrspc();
        }

        private function create_usrspc() : void {

            pgm_call
                = new RemoteCommand(host,
                                    user,
                                    pwd,
                                    "QSYS",
                                    "QUSCRTUS");
            // create a *USRSPC, AS3, in QGPL
            argl
                = new <ProgramArgument>[new ProgramArgument(new EBCDIC(20),
                                                            ProgramArgument.INPUT,
                                                            "AS3       QGPL"),
                                        new ProgramArgument(new EBCDIC(10),
                                                            ProgramArgument.INPUT,
                                                            "AS3SPC"),
                                        new ProgramArgument(new Bin4(),
                                                            ProgramArgument.INPUT,
                                                            4096),
                                        new ProgramArgument(new EBCDIC(1),
                                                            ProgramArgument.INPUT,
                                                            String.fromCharCode(0)),
                                        new ProgramArgument(new EBCDIC(10),
                                                            ProgramArgument.INPUT,
                                                            "*CHANGE"),
                                        new ProgramArgument(new EBCDIC(50),
                                                            ProgramArgument.INPUT,
                                                            "Created by ...") ];
            pgm_call.callx(this, cb_usrspc, argl);
        }

        private function change_usrspc() : void {
            pgm_call
                = new RemoteCommand(host,
                                    user,
                                    pwd,
                                    "QSYS",
                                    "QCMDEXC");
            // change the content of *USRSPC via the CHGUSRSPC command from i5/OS Programmer's Toolkit
            cmd_argl
                = new <ProgramArgument>[new ProgramArgument(new EBCDIC(100),
                                                            ProgramArgument.INPUT,
                                                            "CHGUSRSPC USRSPC(QGPL/AS3) DTA('So nice to meet you!') DTALEN(*CALC)"),
                                        new ProgramArgument(new Packed(15, 5),
                                                            ProgramArgument.INPUT,
                                                            new Number(100)) ];
            pgm_call.callx(this, cb_usrspc, cmd_argl);
        }

        private function dump_usrspc() : void {
            pgm_call
                = new RemoteCommand(host,
                                    user,
                                    pwd,
                                    "QSYS",
                                    "QCMDEXC");
            // dump *USRSPC
            cmd_argl[0].value = "DMPOBJ QGPL/AS3 *USRSPC";
            pgm_call.callx(this, cb_usrspc, cmd_argl);
        }

        private function delete_usrspc() : void {
            pgm_call
                = new RemoteCommand(host,
                                    user,
                                    pwd,
                                    "QSYS",
                                    "QUSDLTUS");
            // delete *USRSPC AS3
            var qusec:ByteArray = new ByteArray();
            qusec.writeInt(16);
            for(var i:int = 0; i < 12; i++) qusec.writeByte(0);
            argl.splice(1, 5,
                        new ProgramArgument(new HexData(16),
                                            ProgramArgument.INOUT, // @todo here: total length of arg[ 1 ]: 28 , which should be: 16
                                            qusec) );
            pgm_call.callx(this, cb_usrspc, argl);
        }

        private function cb_usrspc(rc:int,
                                   argl:Vector.<ProgramArgument>,
                                   msg:String = null) : void {
            trace("return code:", rc);

            // next job to do
            var func:Function = q.shift();
            func.call(this);
        }

    }

}
