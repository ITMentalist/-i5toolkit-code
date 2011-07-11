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
 * @file misc.as
 *
 * Tests of misc function of class DES.
 */

package {

    import flash.display.*;
    import flash.utils.*;

    import as400.prototype.*;

    public class misc extends Sprite {

        public function misc() {

            test_expand8byte();
            test_162345();
            test_expand4bit();
            test_conv();
            test_messup8byte();
            test_lc();
        }

        private function test_lc() : void {

            trace("<<<<<<<<<<<  test of ADDLC >>>>>>>>>>>>");
            var a1:ByteArray = new ByteArray();
            a1.writeByte(0x81);
            a1.writeByte(0x82);
            a1.writeByte(0x83);
            a1.writeByte(0x05);
            a1.writeByte(0xC2);
            a1.writeByte(0xD3);
            a1.writeByte(0xE4);
            a1.writeByte(0xF5);
            var a2:ByteArray = new ByteArray();
            a2.writeByte(0x81);
            a2.writeByte(0x82);
            a2.writeByte(0x83);
            a2.writeByte(0x95);
            a2.writeByte(0xC2);
            a2.writeByte(0xD3);
            a2.writeByte(0xE4);
            a2.writeByte(0xF5);

            var enc:ENC = new ENC();
            var a:ByteArray = enc.logicalAdd(a1, a2, 8);
            trace(a);

            for(var i:int = 0; i < 8; i++)
                trace(i, a.readByte());
        }

        private function test_messup8byte() : void {

            trace("======== misc.test_messup8byte() ========");

            var b8:ByteArray = new ByteArray();
            b8.writeByte(0xD1);
            b8.writeByte(0xE9);
            b8.writeByte(0xD2);
            b8.writeByte(0xD1);
            b8.writeByte(0x40);
            b8.writeByte(0x40);
            b8.writeByte(0x40);
            b8.writeByte(0x40);

            var enc:ENC = new ENC();
            var messed:ByteArray = enc.messup8byte(b8);
            for(var i:int = 0; i < 8; i++)
                trace(i, messed.readByte());
        }

        private function test_conv() : void {

            trace(" <<<<<<<<< test_conv() >>>>>>>>");

            var ibm_str:ByteArray = Conv37.to_ebcdic("Hello");
            /*
            ibm_str.writeByte(0xC8);
            ibm_str.writeByte(0x85);
            ibm_str.writeByte(0x93);
            ibm_str.writeByte(0x93);
            ibm_str.writeByte(0x96);
            */
            var str:String = Conv37.from_ebcdic(ibm_str);
            trace("PC string:", str);
        }

        private function test_expand4bit() : void {

            trace("======== misc.test_expand4bit() ========");

            var d:DES = new DES();
            trace(d.expand4bit(0x0C).join()); // 1,1,0,0
            trace(d.expand4bit(0x0F).join()); // 1,1,1,1
            trace(d.expand4bit(0x06).join()); // 0,1,1,0
            trace(d.expand4bit(0x03).join()); // 0,0,1,1

            var B:Vector.<int> = new <int>[0x01, 0x02, 0x03, 0x07, 0x09, 0x0B, 0x0D, 0x0E];
            var B8:Vector.<int> = new Vector.<int>();
            for(var j:int = 0; j < 8; j++)
                B8 = B8.concat(d.expand4bit(B[j]));
            trace("B8 (", B8.length, ") :", B8.join());

        }

        private function test_162345() : void {

            trace("======== misc.test_162345() ========");

            var d:DES = new DES();

            var v:Vector.<int> = new <int>[1, 0, 0, 0, 1, 1];
            var i:int = d.getBits162345(v);
            trace("i == 0x31", i == 0x31);
        }

        private function test_expand8byte() : void {

            var d:DES = new DES();
            var c8:ByteArray = new ByteArray();
            c8.writeByte(0xFF);
            c8.writeByte(0x88);
            c8.writeByte(0x44);
            c8.writeByte(0x22);
            c8.writeByte(0x11);
            c8.writeByte(0x0A);
            c8.writeByte(0x0B);
            c8.writeByte(0x0C);

            var i64:Vector.<int> = d.expand8byte(c8);
            for(var i:int = 0; i < 64; i++)
                trace(i, ": ", i64[i]);

            c8 = d.compress8byte(i64);
            for(i = 0; i < 8; i++)
                trace(i, ": ", c8.readByte());
        }

    }

}
