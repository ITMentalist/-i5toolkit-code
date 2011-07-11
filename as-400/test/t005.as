/**
 * This file is part of i5/OS Programmer's Toolkit.
 * 
 * Copyright (C) 2010, 2011  Junlei Li (李君磊).
 * 
 * i5/OS Programmer's Toolkit is free software: you can redistribute
 * it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * i5/OS Programmer's Toolkit is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with i5/OS Programmer's Toolkit.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/**
 * @file t005.as
 *
 * Test of calling IBM i APIs using class RemoteCommand.
 *
 * @remark t005.as reuses a RemoteProgram object during 4 calls to different IBM i APIs (programs):
 *  - QUSCRTUS. This API is used to create a User Space (USRSPC) object.
 *  - QCMDEXC, which is called twice to execute 2 CL commands, CHGUSRSPC and DMPOBJ.
 *  - QUSDLTUS. This API is used to delete the created USRSPC.
 */

package {

    import flash.display.Sprite;
    import flash.utils.ByteArray;

    import as400.prototype.*;

    public class t005 extends Sprite {

        private var host:String = "******";
        private var user:String = "***";
        private var pwd:String  = "******";
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
                                    "QUSCRTUS",
                                    true);  // reuse this program-call object

            q = new Vector.<Function>();

            q.push(change_usrspc);
            q.push(dump_usrspc);
            q.push(delete_usrspc);
            q.push(thats_all);

            create_usrspc();
        }

        private function thats_all() : void {
            trace("<<<<<<<<<< THAT'S ALL :p >>>>>>>>>>");
        }

        private function create_usrspc() : void {

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

            /*
            pgm_call
                = new RemoteCommand(host,
                                    user,
                                    pwd,
                                    "QSYS",
                                    "QCMDEXC");
            */
            pgm_call.pgm = "QCMDEXC";
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
            /*
            pgm_call
                = new RemoteCommand(host,
                                    user,
                                    pwd,
                                    "QSYS",
                                    "QCMDEXC");
            */
            // dump *USRSPC
            cmd_argl[0].value = "DMPOBJ QGPL/AS3 *USRSPC";
            pgm_call.callx(this, cb_usrspc, cmd_argl);
        }

        private function delete_usrspc() : void {
            /*
            pgm_call
                = new RemoteCommand(host,
                                    user,
                                    pwd,
                                    "QSYS",
                                    "QUSDLTUS");
            */
            pgm_call.pgm = "QUSDLTUS";
            // delete *USRSPC AS3
            var qusec:ByteArray = new ByteArray();
            qusec.writeInt(64);
            for(var i:int = 0; i < 60; i++) qusec.writeByte(0);
            argl.splice(1, 5,
                        new ProgramArgument(new HexData(64),
                                            ProgramArgument.INOUT,
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
