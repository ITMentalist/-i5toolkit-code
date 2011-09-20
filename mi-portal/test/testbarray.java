/**
 * This file is part of i5/OS Programmer's Toolkit.
 * 
 * Copyright (C) 2010, 2011  Junlei Li (李君磊).
 * 
 * i5/OS Programmer's Toolkit is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * i5/OS Programmer's Toolkit is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with i5/OS Programmer's Toolkit.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/**
 * @file testbarray.java
 *
 * Test of class ByteArray.
 */

import u.ByteArray;

public class testbarray {

    public static void main(String[] args) {

        ByteArray arr = new ByteArray();
        System.out.println(arr.position());

        byte[] a = new byte[3];
        a[0] = a[1] = a[2] = (byte)0x90;
        byte[] b = new byte[3];
        b[0] = b[1] = b[2] = (byte)0x7F;
        byte[] c = new byte[3];
        c[0] = c[1] = c[2] = (byte)-0x11;
        try {
            arr.writeBytes(a).writeBytes(b).writeBytes(c);
            arr.position(arr.position() - 2);
            arr.writeBytes(a);

            arr.dump(System.out);

            // test of clear(), writeBytes(byte, replication)
            arr.clear();
            arr.writeBytes(0x15, 20).writeBytes(0x16, 10).writeBytes(-0x11, 10);
            arr.dump(System.out);

            // test of writeInt32(), readInt32()
            arr.clear();
            arr.writeInt32(0x05060708).writeInt32(0xC1C2C3C4).writeInt32(0x99AAFFEE);
            arr.dump(System.out);
            int[] nval = {0, 0};
            arr.position(0);
            nval[0] = arr.readInt32();
            nval[1] = arr.readInt32();
            System.out.println(
                               Integer.toHexString(nval[0])
                               + ", "
                               + Integer.toHexString(nval[1]));

            // test of writeInt16(), readInt16()
            arr.clear();
            arr.writeInt16(0x0506).writeInt16(0xC1C2).writeInt16(0x99EF);
            arr.dump(System.out);
            arr.position(0);
            nval[0] = arr.readInt16();
            nval[1] = arr.readInt16();
            System.out.println(
                               Integer.toHexString(nval[0])
                               + ", "
                               + Integer.toHexString(nval[1]));

            // test of writeEBCDIC37() and readEBCDIC37()
            arr.clear();
            arr.writeEBCDIC37("How are you?").writeEBCDIC37(" ").
                writeEBCDIC37("Fine!").writeEBCDIC37(" ").
                writeEBCDIC37("Thank you! :)");
            arr.dump(System.out);
            arr.position(0);
            String str = arr.readEBCDIC37(20);
            System.out.println("str: '" + str + "'");

        } catch(Exception e) {
            e.printStackTrace();
        }
    }

}
