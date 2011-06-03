/**
 * @file ENC.as
 *
 * Encryption utility class.
 */

package as400.prototype {

    import flash.utils.*; // ByteArray

    public class ENC {

        /**
         * @param [in] 10-byte EBCDIC User ID
         * @param [in] Length of user-id that does NOT including trailing white spaces
         * @param [in] 10-byte EBCDIC password
         * @param [in] Length of password that does NOT including trailing white spaces
         * @param [in] 8-byte client-side seed
         * @param [in] 8-byte server-side seed
         *
         * @return 8-byte encrypted password
         */
        public function encrypt_password(e_usr:ByteArray,
                                         usr_len:int,
                                         e_pwd:ByteArray,
                                         pwd_len:int,
                                         client_seed:ByteArray,
                                         server_seed:ByteArray
                                         ) : ByteArray
        {
            var r:ByteArray = new ByteArray();
            var i:int = 0;
            client_seed.position = 0;
            server_seed.position = 0;

            // don't change the input user ID and password
            var usr:ByteArray = new ByteArray();
            e_usr.readBytes(usr);
            usr.position = 0; e_usr.position = 0;
            var pwd:ByteArray = new ByteArray();
            e_pwd.readBytes(pwd);
            pwd.position = 0; e_pwd.position = 0;

            // @remark feld_usr is used only in the token-generation progress
            var feld_usr:ByteArray = new ByteArray();
            // if usr.length > 8
            if(usr_len > 8)
                feld_usr = fold_user_id(usr);
            else
                usr.readBytes(feld_usr);
            trace("DEBUG >>>>>>", "feld_usr", listbarr(feld_usr));

            var token:ByteArray = null;
            var des:DES = new DES();
            // if pwd.length > 8
            if(pwd_len > 8) {

                // first 8-byte of ebcdic password
                var pwd_hi:ByteArray = new ByteArray();
                pwd.readBytes(pwd_hi, 0, 8);
                // last 2-byte of ebcdic password
                var pwd_lo:ByteArray = new ByteArray();
                pwd.readBytes(pwd_lo, 0, 2);
                pwd_lo.position = 2;
                for(i = 0; i < 6; i++) pwd_lo.writeByte(0x40);
                pwd.position = 0;

                var messed_pwd_hi:ByteArray = messup8byte(pwd_hi);
                var token_hi:ByteArray = des.encode_des(feld_usr, messed_pwd_hi);
                trace("DEBUG >>>>>", "token_hi", listb8(token_hi));
                var messed_pwd_lo:ByteArray = messup8byte(pwd_lo);
                var token_lo:ByteArray = des.encode_des(feld_usr, messed_pwd_lo);
                trace("DEBUG >>>>>", "token_lo", listb8(token_lo));
                // XOR token_hi and token_lo to generate token
                token = XORBytes(token_hi, token_lo, 8);
                trace("DEBUG >>>>>", "token", listb8(token));
            } else {

                // make a mess of the original password
                var messed_pwd:ByteArray = messup8byte(pwd);
                trace("messed_pwd", listb8(messed_pwd));

                token = des.encode_des(feld_usr, messed_pwd);
                trace("token", listb8(token));
            }

            // 0, 0, 0, 0, 0, 0, 0, 1
            var seqNum:ByteArray = new ByteArray();
            for(i = 0; i < 7; i++) seqNum.writeByte(0);
            seqNum.writeByte(1);
            var seq:ByteArray = logicalAdd(seqNum, server_seed, 8);
            trace("ADDLC", listb8(seq));

            // encrypt seq with token into next_enc_dta
            var next_enc_dta:ByteArray = des.encode_des(seq, token);
            trace("next_enc_dta:ByteArray = des.encode_des(seq, token);", listb8(next_enc_dta));

            // next_dta = next_enc_dta ^ client_seed
            var next_dta:ByteArray = XORBytes(next_enc_dta, client_seed, 8);
            trace("next_dta:ByteArray = XORBytes(next_enc_dta, client_seed, 8);", listb8(next_dta));

            // encrypt next_dat with token
            next_enc_dta = des.encode_des(next_dta, token);
            trace("next_enc_dta = des.encode_des(next_dta, token);", listb8(next_enc_dta));

            //
            next_dta = XORBytes(usr, seq, 8); trace("next_dta = XORBytes(usr, seq, 8);", listb8(next_dta));
            next_dta = XORBytes(next_dta, next_enc_dta, 8); trace("next_dta = XORBytes(next_dta, next_enc_dta, 8);", listb8(next_dta));
            next_enc_dta = des.encode_des(next_dta, token); trace("next_enc_dta = des.encode_des(next_dta, token);", listb8(next_enc_dta));

            // deal with the remaining 2-byte in user-ID
            next_dta = new ByteArray();
            usr.position = 0;
            for(i = 0; i < 8; i++) usr.readByte();
            next_dta.writeByte(usr.readByte()); // usr[8]
            next_dta.writeByte(usr.readByte()); // usr[9]
            // pad 6 white spaces
            for(i = 0; i < 6; i++) next_dta.writeByte(0x40);
            trace("for(i = 0; i < 6; i++) next_dta.writeByte(0x40);", listb8(next_dta));

            next_dta = XORBytes(seq, next_dta, 8);  trace("next_dta = XORBytes(seq, next_dta, 8);", listb8(next_dta));
            next_dta = XORBytes(next_dta, next_enc_dta, 8); trace("next_dta = XORBytes(next_dta, next_enc_dta, 8);", listb8(next_dta));
            // encrypt next_dta with token
            next_enc_dta = des.encode_des(next_dta, token); trace("next_enc_dta = des.encode_des(next_dta, token);", listb8(next_enc_dta));

            next_dta = XORBytes(seqNum, next_enc_dta, 8); trace("next_dta = XORBytes(seqNum, next_enc_dta, 8);", listb8(next_dta));
            // encrypt next_dta with token
            r = des.encode_des(next_dta, token); trace("r = des.encode_des(next_dta, token);", listb8(r));

            r.position = 0;
            return r;
        }

        /// for DEBUG
        public static function listb8(b8:ByteArray) : String {
            b8.position = 0;
            var v:Vector.<int> =  new Vector.<int>(8);
            for(var i:int = 0; i < 8; i++)
                v[i] = b8.readByte();

            b8.position = 0;
            return v.join(", ");
        }

        /// for DEBUG
        public static function listbarr(b:ByteArray) : String {
            var old_pos:int = b.position;
            b.position = 0;
            var v:Vector.<int> =  new Vector.<int>();
            for(var i:int = 0; i < b.length; i++)
                v.push(b.readByte());

            b.position = old_pos;
            return v.join(", ");
        }

        /**
         * XOR 8 bytes
         */
        public function XORBytes(arr1:ByteArray,
                                 arr2:ByteArray,
                                 len:int) : ByteArray {

            len = (len <= arr1.length) ? len : arr1.length;
            len = (len <= arr2.length) ? len : arr2.length;

            arr1.position = 0;
            arr2.position = 0;
            var r:ByteArray = new ByteArray();
            for(var i:int = 0; i < len; i++) {

                var j:int = arr1.readByte() ^ arr2.readByte();
                r.writeByte(j);
            }

            arr1.position = 0;
            arr2.position = 0;
            r.position = 0;
            return r;
        }

        /**
         * Add characters logically.
         *
         * in: 0x81, 0x82, 0x83, 0x05, 0xC2, 0xD3, 0xE4, 0xF5
         * in: 0x81, 0x82, 0x83, 0x95, 0xC2, 0xD3, 0xE4, 0xF5
         * out: 
         */
        public function logicalAdd(arr1:ByteArray,
                                   arr2:ByteArray,
                                   len:int) : ByteArray {

            var i:int = 0;
            len = (len <= arr1.length) ? len : arr1.length;
            len = (len <= arr2.length) ? len : arr2.length;

            arr1.position = 0;
            var v1:Vector.<int> = new Vector.<int>(len);
            for(i = 0; i < len; i++)
                v1[i] = arr1.readByte();
            arr2.position = 0;
            var v2:Vector.<int> = new Vector.<int>(len);
            for(i = 0; i < len; i++)
                v2[i] = arr2.readByte();

            var carry:int = 0;
            var v:Vector.<int> = new Vector.<int>(len);
            for(i = len - 1; i >= 0; i--) {

                var c:int = (v1[i] & 0xFF) + (v2[i] & 0xFF) + carry;
                carry = c >> 8;
                c &= 0xFF;
                v[i] = c;
            }
            arr1.position = 0;
            arr2.position = 0;

            var r:ByteArray = new ByteArray();
            for(i = 0; i < len; i++)
                r.writeByte(v[i]);
            r.position = 0;

            return r;
        }

        /**
         * @remark this method is invoked when the length or user-ID > 8
         * @param [in/out] user, 10-byte EBCDIC user ID
         */
        private function fold_user_id(user:ByteArray) : ByteArray {
            var v:Vector.<int> = new Vector.<int>(10);
            var len:int = user.length;
            if(len != 10) trace("Oops! len is NOT 10: ", len);
            user.position = 0;
            for(var i:int = 0; i < len; i++)
                v[i] = user.readByte();

            // XOR each 2-bit block of v[8], v[9] with x[0] through v[7]'s highest 2-bit
            v[0] ^= v[8] & 0xC0;
            v[1] ^= (v[8] & 0x30) << 2;
            v[2] ^= (v[8] & 0x0C) << 4;
            v[3] ^= (v[8] & 0x03) << 6;
            v[4] ^= v[9] & 0xC0;
            v[5] ^= (v[9] & 0x30) << 2;
            v[6] ^= (v[9] & 0x0C) << 4;
            v[7] ^= (v[9] & 0x03) << 6;

            var r:ByteArray = new ByteArray();
            for(i = 0; i < len; i++)
                r.writeByte(v[i]);
            r.position = 0;
            return r;
        }

        /// @todo change this method to private
        public function messup8byte(b8:ByteArray) : ByteArray {

            var b:int = 0;
            var i:int = 0;
            var v:Vector.<int> = new Vector.<int>(8);

            b8.position = 0;
            for(i = 0; i < 8; i++)
                v[i] = b8.readByte();
            b8.position = 0;

            // XOR each byte with hex 55
            for(i = 0; i < 8; i++)
                v[i] ^= 0x55;

            // CONCAT the lower 7 bits of b[i] with the highest bit of b[i+1]
            for(i = 0; i < 7; i++)
                v[i] = (v[i] << 1) | ((v[i + 1] & 0x80) >> 7);
            v[7] <<= 1;

            var r:ByteArray = new ByteArray();
            for(i = 0; i < 8; i++)
                r.writeByte(v[i]);
            r.position = 0;
            return r;
        }


    } // class

} // package
