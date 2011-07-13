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
 * @file RemoteCommand.as
 *
 * @todo 不理解ing, request 里的 server-id 开始被自己错填成了
 *       hex 0E08, 但 XCHG-SEED, START-PJ 都成功了 ?!
 */

package as400.prototype {

    import flash.net.*;
    import flash.utils.*;
    import flash.events.*;
    import flash.system.*;

    public class RemoteCommand {

        private var security_policy_loaded_:Boolean;
        private var s_:Socket;
        private var jobq_:Vector.<Function>;
        private var host_:String;
        private var user_:String;
        private var pwd_:String;

        private var lib_:String;
        public function get lib() : String { return lib_; }
        public function set lib(l:String) : void { lib_ = l; }

        private var pgm_:String;
        public function get pgm() : String { return pgm_; }
        public function set pgm(l:String) : void { pgm_ = l; }

        // reuse this program-call object
        private var reuse_:Boolean;
        public function get reuse() : Boolean { return reuse_; }

        // client-side seed
        private var cseed_:ByteArray;
        // server-side seed
        private var sseed_:ByteArray;
        // encrypted password
        private var enc_pwd_:ByteArray;

        // 通知谁?
        private var caller_:*;
        private var notifier_:Function;
        private var argl_:Vector.<ProgramArgument>;

        // server-side information
        /**
         * CCSID used by server job
         * @remark this is critical to converting returned EBCDIC-character data into Unicode strings.
         * @remark To reuse the server job, set <var>reuse</var> to true.
         */
        private var ccsid_:uint;
        public function get ccsid() : uint { return ccsid_; }

        /**
         * ctor
         *
         * @remark 这里收所有 PGM 相关属性
         */
        public function RemoteCommand(host:String,
                                      user:String,
                                      password:String,
                                      library:String,
                                      program:String,
                                      reuse:Boolean = false) {

            security_policy_loaded_ = false;
            host_ = host;
            user_ = user.toUpperCase();      // convert input user name to upper case
            pwd_  = password.toUpperCase();  // convert input password to upper case
            lib_  = library;
            pgm_  = program;
            reuse_ = reuse;

            // what i should do
            jobq_ = new Vector.<Function>();
            initiated_ = false;
        }

        /// @todo is there a better way?
        private var initiated_:Boolean;

        /**
         * call target AS/400 program
         *
         *  - passing input parameters
         *  - returning output parameters to the caller
         */
        public function callx(caller:*,
                              notifier:Function,
                              argl:Vector.<ProgramArgument> = null) : void {

            caller_   = caller;
            notifier_ = notifier;
            argl_     = argl;

            if(!initiated_) {
                // @todo the URL and port
                if(!security_policy_loaded_)
                    Security.loadPolicyFile("xmlsocket://" + host_ + ":55556");

                s_ = new Socket();
                s_.addEventListener(Event.CONNECT, onConnected);
                s_.addEventListener(ProgressEvent.SOCKET_DATA, onData);
                s_.addEventListener(Event.CLOSE, onClose);

                jobq_.push(xchg_seeds_rqs);
                jobq_.push(xchg_seeds_rpy);
                jobq_.push(start_pj_rqs);
                jobq_.push(start_pj_rpy);
                jobq_.push(xchg_attr_rqs);
                jobq_.push(xchg_attr_rpy);
            }

            // @here 解决复用时的同步问题!
            jobq_.push(call_program_rqs); trace("++++++++++++++++++++++++++++++ JOB enqueued: ", lib_ + "/" + pgm_);
            jobq_.push(call_program_rpy);
            if(!reuse)
                jobq_.push(say_farewell);

            // connect to "as-rmtcmd" server
            if(!initiated_) {         
                s_.connect(host_, AS400.get_server_port(AS400.RMTCMD));
                initiated_ = true;
            } else jobq_.shift().call(this);
        }

        public function close() : void {
            say_farewell();
        }

        private function onConnected(evt:Event) : void {
            trace("Oops, we get connected.");

            // 开始做事
            jobq_.shift().call(this);
        }

        private function onClose(evt:Event) : void {
            trace("onClose() ... ", evt.type);
        }

        /// each time we send a request to the server, we'll get
        /// a reply later. Here's the function we deal with a
        /// reply from the server.
        private function onData(evt:ProgressEvent) : void {

            trace("onData()...", evt.type);
            // receive host reply
            jobq_.shift().call(this);
        }

        private function say_farewell() : void {

            trace("<<<<<<<<<<<< say_farewell() >>>>>>>>>");

            var i:int = 0;
            var rqs:ByteArray = new ByteArray();
            rqs.writeInt(20);
            rqs.writeByte(0x00);  // client-attr, 0x00
            rqs.writeByte(0x00);  // server-attr
            // server ID of as-rmtcmd, 0xE008
            rqs.writeShort(0xE008);
            // 8-byte filler (reserved, not used)
            for(i = 0; i < 8; i++) rqs.writeByte(0x00);
            rqs.writeShort(0); // rqs-dta-len (0x0000)
            rqs.writeShort(0x1004); // request ID
            trace("FAREWELL, rqs.length:", rqs.length);
            trace("FAREWELL, rqs:", ENC.listbarr(rqs));

            s_.writeBytes(rqs);
            s_.flush();
            s_.close();
        }

        /**
         * work with reply of program-call request
         */
        private function call_program_rpy() : void {

            trace("<<<<<<<<<<<< call_program_rpy() >>>>>>>>>");

            var i:int = 0, len:int = 0, pgm_arg_len:int = 0;;
            // recieve 20-byte header
            var rpy:ByteArray = new ByteArray();
            s_.readBytes(rpy, 0, 20);
            trace("Header of PGM-CALL reply, rpy.length:", rpy.length);
            trace("Header of PGM-CALL reply, rpy:", ENC.listbarr(rpy));
            // total length of server's reply
            rpy.position = 0;
            len = rpy.readInt();
            len -= 20;
            // receiver the remainder of server's reply
            s_.readBytes(rpy, 20, len);
            // the whole reply is recieved now!
            trace("PGM-CALL, rpy.length:", rpy.length);
            trace("PGM-CALL, rpy:", ENC.listbarr(rpy));

            // deal with the 2-byte return-code in server's reply
            var rc:int = rpy.readShort();
            trace("call_program_rpy(), rc:", rc);
            // @remark server ID of as-rmtcmd, hex E008
            var server_id:int = rpy.readShort();
            trace("call_program_rpy(), server ID:", server_id);

            // output args or returned message
            var msg:String = "@todo implement me!";
            if(rc != 0) {
                // @todo retrieve message text from the reply package
            } else { // retrieve inout/output args

                rpy.position = 20 + 2 + 2; // offset of returned arg-list
                for(i = 0; i < argl_.length; i++) {
                    var arg:ProgramArgument = argl_[i];
                    if(arg.argType == ProgramArgument.INPUT)
                        continue; // skip INPUT args

                    // 12-byte arg-header
                    pgm_arg_len = rpy.readInt(); // total length
                    if(len != (12 + arg.as400Dta.length)) {
                        // @todo what if the caller has set a wrong arg-length value
                        trace("total length of arg[", i, "]:", 12 + arg.as400Dta.length, ", which should be:", len);
                    }
                    var cp:int = rpy.readShort();
                    trace("arg[", i, "], cp:", cp);
                    // data length of the arg
                    len = rpy.readInt();         // @todo 可能错吗? 怕它错, 下面实际收 arg-data 时, 长度用了 pgm_arg_len - 12
                                                 // @remark 哎呀, 这个值还真得不能用, 在使用 INOUT 传 QUSEC_T 时, 这个值会和 qusec_t.bytes_in 相同
                                                 // @see    t005.as 中 delete-usrspc 的情况
                    if(len != arg.as400Dta.length) {
                        // @todo
                        trace("data length of arg[", i, "]:", arg.as400Dta.length, ", which should be:", len);
                    }
                    var usage:int = rpy.readShort();
                    if(usage != arg.argType) {
                        // @todo
                        trace("usage of arg[", i, "] is",
                              arg.argType,
                              ", which should be:",
                              usage);
                    }
                    trace("length in bytes to read (pgm_arg_len - 12):", pgm_arg_len - 12);
                    if(pgm_arg_len - 12 > 0)  // @todo need review, 2011-07-12
                        arg.value = arg.as400Dta.read(rpy, pgm_arg_len - 12); // @remark arg length actually returned MIGHT NOT be the same as what it expectected to be, either longer or shorter!
                    trace("value of arg[", i, "]:", arg.value);
                }
            }

            // ------------------------------
            // notify the caller: rc, argl, msg
            // ------------------------------
            notifier_.call(caller_, rc, argl_, msg);

            // start next request
            // @remark If reuse_ == false, the next request is FAREWELL, otherwise there is NO next request.
            if(jobq_.length > 0)
                jobq_.shift().call(this);
        }

        private function call_program_rqs() : void {

            trace("<<<<<<<<<<<< call_program_rqs(): " + lib_ + "/" + pgm_ + " >>>>>>>>>");

            var i:int = 0, len:int = 0;
            // compose request package of PGM-CALL request
            var rqs:ByteArray = new ByteArray();

            // calculate total length of request pkg
            len = 43; // basic PKG-SIZE that do NOT including arg-list
            for(i = 0; i < argl_.length; i++) {
                var arg:ProgramArgument = argl_[i];
                len += 12 + ((arg.argType == ProgramArgument.OUTPUT) ? 0 : arg.as400Dta.length);
            }
            trace("call_program_rqs, size of request-package:",
                  len);

            rqs.writeInt(len);     // pakage length
            rqs.writeByte(0x00);  // client-attr, 0x00
            rqs.writeByte(0x00);  // server-attr
            // server ID of as-rmtcmd, 0xE008
            rqs.writeShort(0xE008);
            // 8-byte filler (reserved, not used)
            for(i = 0; i < 8; i++) rqs.writeByte(0x00);
            // length of request data, 23
            // @remark note that this length does not include the length of argument to be passed to the called program
            rqs.writeShort(23);
            // rqsuest ID, here is hex 1003 (PGM-CALL)
            rqs.writeShort(0x1003);
            // <<<<< END of package header >>>>>>
            // pad white spaces
            var pgm:String = pgm_;
            while(pgm.length < 10) pgm += " ";
            var e_pgm:ByteArray = Conv37.to_ebcdic(pgm);
            rqs.writeBytes(e_pgm, 0, 10);
            // pad white spaces
            var lib:String = lib_;
            while(lib.length < 10) lib += " ";
            var e_lib:ByteArray = Conv37.to_ebcdic(lib);
            rqs.writeBytes(e_lib, 0, 10);
            rqs.writeByte(0x00);  // message count
            // Number of arguemnts passed
            len = 0;
            if(argl_ != null)
                len = argl_.length;
            rqs.writeShort(len);
            // END of the fixed portion of PGM-CALL request package
            // the following is the list of arguments
            // in this example, the pgm we called has 1 OUTPUT parameter

            // argument list
            if(argl_ != null) {

                // calculate the total length of the arg-list
                for(i = 0; i < argl_.length; i++) {

                    arg = argl_[i];
                    len = 12 + ((arg.argType == ProgramArgument.OUTPUT) ? 0 : arg.as400Dta.length);
                    rqs.writeInt(len); // total length
                    rqs.writeShort(0x1103); // ??
                    rqs.writeInt(arg.as400Dta.length); // arg length
                    rqs.writeShort(arg.argType);       // usage
                    // arg-data for INPUT/INOUT argument
                    if(arg.argType != ProgramArgument.OUTPUT)
                        arg.as400Dta.write(rqs, arg.value);

                } // for-loop
                trace("PGM-CALL, rqs.length:", rqs.length);
                trace("PGM-CALL, rqs:", ENC.listbarr(rqs));
            }

            // send PGM-CALL request
            s_.writeBytes(rqs);
            s_.flush();
         }

        private function xchg_attr_rpy() : void {

            trace("<<<<<<<<<<<< xchg_attr_rqs() >>>>>>>>>");

            var rpy:ByteArray = new ByteArray();
            s_.readBytes(rpy, 0, 20);
            trace("XCHG-ATTR, rpy.length:", rpy.length);
            trace("XCHG-ATTR, rpy:", ENC.listbarr(rpy));

            rpy.position = 0;
            var len:int = rpy.readInt();
            len -= 20;
            s_.readBytes(rpy, 20, len);
            trace("XCHG-ATTR, rpy.length:", rpy.length);
            trace("XCHG-ATTR, rpy:", ENC.listbarr(rpy));

            rpy.position = 20;
            // @remark 2-byte return-code
            var rc:int = rpy.readShort();
            trace("rc of XCHG-ATTR reply:", rc);
            ccsid_ = rpy.readInt();
            trace("XCHG-ATTR, reply, server side CCSID:", ccsid_);
            rpy.position += 8;
            // 2-byte datastream level
            var ds_level:int = rpy.readShort();
            trace("XCHG-ATTR, reply, datastream level:", ds_level);

            // start next request
            jobq_.shift().call(this);
        }

        private function xchg_attr_rqs() : void {

            trace("<<<<<<<<<<<< xchg_attr_rqs() >>>>>>>>>");

            var i:int = 0;
            // compose request package of XCHG-ATTR request
            var rqs:ByteArray = new ByteArray();
            rqs.writeInt(34); // package length, 34
            rqs.writeByte(0x00); // client attr
            rqs.writeByte(0x00); // server attr
            rqs.writeShort(0xE008); // server ID of as-rmtcmd
            // 8-byte filler
            for(i = 0; i < 8; i++) rqs.writeByte(0x00);
            rqs.writeShort(14); // length of request data
            rqs.writeShort(0x1001); // request ID
            // <<<<< END of package header >>>>>>
            rqs.writeInt(13488);  // CCSID, 13488 (UCS-2)
            // 4-byte NLV (National Language Version) feature code,
            // e.g. '2989' for simplified Chinese, '2928' for Frech, and '2924' for English
            // @see Refer to the "Globalization reference information" doc in info-center for details
            var NLV:ByteArray = Conv37.to_ebcdic("2924"); // 2989
            rqs.writeBytes(NLV, 0, 4);
            // 4-byte client version, hex 00000001
            rqs.writeInt(1);
            // 2-byte client datastream level, 0
            rqs.writeShort(0x00);
            trace("XCHG-ATTR, rqs.length:", rqs.length);
            trace("XCHG-ATTR, rqs:", ENC.listbarr(rqs));

            // send XCHG-ATTR request
            s_.writeBytes(rqs);
            s_.flush();
        }

        private function start_pj_rpy() : void {

            trace("<<<<<<<<<<<< start_pj_rpy() >>>>>>>>>");

            var rpy:ByteArray = new ByteArray();
            s_.readBytes(rpy, 0, 20);
            trace("Header of START-PJ reply, rpy.length:", rpy.length);
            trace("Header of START-PJ reply, rpy:", ENC.listbarr(rpy));
            rpy.position = 0;
            var len:int = rpy.readInt();
            len -= 20;
            s_.readBytes(rpy, 20, len);
            trace("START-PJ, rpy.length:", rpy.length);
            trace("START-PJ, rpy:", ENC.listbarr(rpy));

            rpy.position = 20;
            var rc:int = rpy.readInt();
            trace("rc of START-PJ reply:", rc);
            var job_name:String
                = Conv37.from_ebcdic(rpy, 20 + 4 + 10);
            trace("START-PJ reply, job_name:", job_name);

            // start next request
            jobq_.shift().call(this);
        }

        /**
         * Send a START-PJ to as-rmtcmd server
         * @pre enc_pwd_
         */
        private function start_pj_rqs() : void {

            trace("<<<<<<<<<<<< start_pj_rqs() >>>>>>>>>");

            // generate encrypted password
            gen_enc_pwd();

            var i:int = 0;
            // compose request package of START-PJ request
            var rqs:ByteArray = new ByteArray();
            rqs.writeInt(52);     // pakage length
            rqs.writeByte(0x02);  // client-attr, 0x01
            rqs.writeByte(0x00);  // server-attr
            // server ID of as-rmtcmd, 0xE008
            rqs.writeShort(0xE008);
            // 8-byte filler (reserved, not used)
            for(i = 0; i < 8; i++) rqs.writeByte(0x00);
            // length of request data, 8 for START-PJ
            rqs.writeShort(2);
            // rqsuest ID, here is hex 7001 (START-PJ)
            rqs.writeShort(0x7002);
            // <<<<< END of package header >>>>>>
            rqs.writeByte(0x01); // byte type, hex 01
            rqs.writeByte(0x01); // reply flag, hex 01
            // authentication data; 14 bytes
            rqs.writeInt(14);    // length of authentication data in bytes
            rqs.writeShort(0x1105);  // authentication type; AUTHENTICATION_SCHEME_PASSWORD = hex 1105; otherwise, hex 1115
            rqs.writeBytes(enc_pwd_); // authentication data. here is the 8-byte encrypted password
            // user ID info; 16 bytes
            rqs.writeInt(16);  // length of user ID info
            rqs.writeShort(0x1104);  // ??
            var user:String = user_;
            while(user.length < 10) user += " ";
            var e_user:ByteArray = Conv37.to_ebcdic(user);
            rqs.writeBytes(e_user);  // 10-byte EBCDIC user ID
            trace("START-PJ, rqs.length", rqs.length);
            trace("START-PJ, rqs", ENC.listbarr(rqs));

            // send START-PJ request
            s_.writeBytes(rqs);
            s_.flush();
        }

        /**
         * @pre user_, pwd_, cseed_, sseed_
         *
         * @post enc_pwd_
         */
        private function gen_enc_pwd() : void {

            trace(">>>>>>>>>> gen_enc_pwd() <<<<<<<<");

            var user:String = user_;
            while(user.length < 10) user += " ";
            var e_user:ByteArray = Conv37.to_ebcdic(user);

            var pwd:String = pwd_;
            while(pwd.length < 10) pwd += " ";
            var e_pwd:ByteArray = Conv37.to_ebcdic(pwd);

            var enc:ENC = new ENC();
            enc_pwd_
                = enc.encrypt_password(e_user,
                                       user_.length,
                                       e_pwd,
                                       pwd_.length,
                                       cseed_,
                                       sseed_);
            trace("enc_pwd_", ENC.listbarr(enc_pwd_));
        }

        private function xchg_seeds_rpy() : void {

            trace("<<<<<<<<<<<< xchg_seeds_rpy() >>>>>>>>>");

            var rpy:ByteArray = new ByteArray();
            s_.readBytes(rpy, 0, 20);
            trace("XCHG-SEED, rpy.length:", rpy.length);
            trace("XCHG-SEED, rpy:", ENC.listbarr(rpy));
            rpy.position = 0;
            var len:int = rpy.readInt();
            len -= 20;
            var rc:int = s_.readInt();
            trace("XCHG-SEED, rc:", rc);
            sseed_ = new ByteArray();
            s_.readBytes(sseed_, 0, 8);
            trace("XCHG-SEED, sseed_:", ENC.listbarr(sseed_));

            // start next request
            jobq_.shift().call(this);
        }

        private function xchg_seeds_rqs() : void {

            trace("<<<<<<<<<<<< xchg_seeds_rqs() >>>>>>>>>");

            var c_hi:uint = Math.random() * 0x0100000000;
            var c_lo:uint = Math.random() * 0x0100000000;
            cseed_ = new ByteArray();
            cseed_.writeInt(c_hi);
            cseed_.writeInt(c_lo);
            cseed_.position = 0;

            var i:int = 0;
            // compose request package of XCHG-SEED request
            var rqs:ByteArray = new ByteArray();
            rqs.writeInt(28);     // pakage length
            rqs.writeByte(0x01);  // client-attr, 0x01
            rqs.writeByte(0x00);  // server-attr
            // server ID of as-rmtcmd, 0xE008
            rqs.writeShort(0xE008);
            // 8-byte filler (reserved, not used)
            for(i = 0; i < 8; i++) rqs.writeByte(0x00);
            // length of request data, 8 for XCHG-SEED
            rqs.writeShort(8);
            // rqsuest ID, here is hex 7001 (XCHG-SEED)
            rqs.writeShort(0x7001);
            // <<<<< END of package header >>>>>>
            // client seed
            rqs.writeBytes(cseed_);
            trace("XCHG-SEED, rqs.length:", rqs.length);
            trace("XCHG-SEED, rqs:", ENC.listbarr(rqs));

            // send XCHG-SEED request
            s_.writeBytes(rqs);
            s_.flush();
        }

    } // class

} // package
