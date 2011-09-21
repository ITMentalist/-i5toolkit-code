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

package u;

import java.io.IOException;
import java.io.PrintStream;

/**
 * The ByteArray class is designed to ease the jobs of preparing data
 * items and structures in host data types.
 *
 * @attention Since user is allowed to rewrite the content of a
 * ByteArray, the value of <var>pos_</var> can be less than the value
 * ov <var>len_</var>.
 *
 * @todo write/read pkd/znd 4/8-byte float
 */
public class ByteArray {

    private int pos_;
    public int position() { return pos_; }
    public void position(int pos) { pos_ = pos; }

    private byte[] arr_;
    private int init_size_;
    /// current size of arr_
    private int cur_size_;
    /// length of data stored in arr_
    private int len_;

    private boolean endian_ = true; // true = Big, false = little
    public boolean endian() { return endian_; }

    public static final int DEFAULT_INITCAP = 4096;

    /// ctors
    public ByteArray(int initialCapacity) {
        pos_ = 0;
        len_ = 0;
        init_size_ = (initialCapacity <= 0) ? DEFAULT_INITCAP : initialCapacity;
        arr_ = new byte[init_size_];
        cur_size_ = init_size_;
    }
    public ByteArray() {
        pos_ = 0;
        len_ = 0;
        init_size_ = DEFAULT_INITCAP;
        arr_ = new byte[init_size_];
        cur_size_ = init_size_;
    }

    /// for convenience of debugging
    public void dump(PrintStream out) {
        out.println(this);
        out.println("pos_: " + pos_);
        out.println("init_size_: " + init_size_);
        out.println("cur_size_: " + cur_size_);
        out.println("len_: " + len_);

        dumpBArray(out, arr_, len_);
    }

    public static void dumpBArray(PrintStream out, byte[] data, int length) {

        char[] z8 = {'0', '0', '0', '0', '0', '0', '0', '0'};
        for(int i = 0; i < length; i++) {

            // offset value
            if(i % 32 == 0)
                out.print(Integer.toHexString(i + 0x10000000).substring(3) + "   ");

            String hex_byte = Integer.toHexString((int)data[i]);
            // pad hex_byte from left with `0' to 8-byte
            hex_byte = new String(z8, 0, 8 - hex_byte.length())
                + hex_byte;
            // display the rightmost 2 bytes
            out.print(hex_byte.substring(6));

            if((i + 1)% 32 == 0)
                out.println();
            else if((i + 1)% 16 == 0)
                out.print("   ");
            else if((i + 1)% 8 == 0)
                out.print(" ");
            else
                ;
        }
        out.println();
        // @todo offset value at the beginning of each line
        // @todo hexadecimal output
        // @todo insert a ' ' after each 8-byte,
        //       insert double ' ' after each 16-byte,
        //       and a newline character after each 32-byte
    }

    /**
     * reset ByteArray to initial state:
     *  - pos_ = 0
     *  - len_ = 0
     *  - cur_size_ (size of arr_) = init_size_
     *  - data in arr_ is cleared
     */
    public void clear() {
        pos_ = 0;
        len_ = 0;
        arr_ = new byte[init_size_];
        cur_size_ = init_size_;
    }

    /// @todo not implemented
    private void extend(int min_expension)
        throws IOException
    {
        throw new IOException("Method ByteArray.extend() is not yet implemented");
    }

    /// @todo not implemented
    private boolean should_extend(int min_expension) {
        return false;
    }

    /**
     * @attention 允许覆盖写 (擦着写), 因此 pos_ 可能小于 len_
     *
     * @param [in] data, data to write
     * @param [in] bytes, number of bytes to convert and write
     * @param [in] off, offset from the beginning of data
     */
    public synchronized ByteArray writeBytes(byte[] data, int bytes, int off)
        throws IOException
    {

        int bytes_to_write = 0, i = 0;
        bytes_to_write = (bytes <= 0) ? data.length : bytes;

        // append data to arr_
        if(should_extend(bytes_to_write))
            extend(bytes_to_write);

        for(i = 0; i < bytes_to_write; i++, pos_++)
            arr_[pos_] = data[off + i];

        // update len_
        len_ = (len_ >= pos_) ? len_ : pos_;
        return this;
    }
    public ByteArray writeBytes(byte[] data)
        throws IOException
    { writeBytes(data, -1, 0); return this; }

    public ByteArray writeBytes(int value, int replication)
        throws IOException
    {
        int bytes_to_write = replication, i = 0;

        // append data to arr_
        if(should_extend(bytes_to_write))
            extend(bytes_to_write);

        for(i = 0; i < bytes_to_write; i++, pos_++)
            arr_[pos_] = (byte)value;

        // update len_
        len_ = (len_ >= pos_) ? len_ : pos_;
        return this;
    }

    public synchronized ByteArray readBytes(byte[] data, int bytes, int off)
        throws IOException
    {
        if((pos_ + bytes - 1) > len_)
            throw new IOException("No enough data left.");

        for(int i = 0; i < bytes; i++, pos_++)
            data[off + i] = arr_[pos_];

        return this;
    }
    public synchronized ByteArray readBytes(byte[] data, int bytes)
        throws IOException
    { readBytes(data, bytes, 0); return this; }

    /**
     * Convert a ASCII character string to CCSID 37 EBCDIC string and write
     * the conversion result into ByteArray
     *
     * @param [in] asciiString, ASCII character string
     * @param [in] bytes, number of bytes to convert and write
     * @param [in] off, offset from the beginning of data
     */
    public synchronized ByteArray writeEBCDIC37(String asciiString, int bytes, int off)
        throws IOException
    {
        byte[] data = asciiString.getBytes();
        int bytes_to_write = 0, i = 0;
        bytes_to_write = (bytes <= 0) ? data.length : bytes;

        // append data to arr_
        if(should_extend(bytes_to_write))
            extend(bytes_to_write);

        int inx = 0;
        for(i = 0; i < bytes_to_write; i++, pos_++) {
            inx = (int)data[off + i] & 0xFF;
            arr_[pos_] = (byte)_qebcdic[inx];
        }

        // update len_
        len_ = (len_ >= pos_) ? len_ : pos_;
        return this;
    }
    public ByteArray writeEBCDIC37(String asciiString)
        throws IOException
    { writeEBCDIC37(asciiString, -1, 0); return this; }

    public synchronized ByteArray readEBCDIC37(byte[] data, int bytes, int off)
        throws IOException
    {
        if((pos_ + bytes - 1) > len_)
            throw new IOException("No enough data left.");

        int inx = 0;
        for(int i = 0; i < bytes; i++, pos_++) {
            inx = (int)arr_[pos_] & 0xFF;
            data[off + i] = (byte)_qascii[inx];
        }

        return this;
    }
    public synchronized ByteArray readEBCDIC37(byte[] data, int bytes)
        throws IOException
    { readEBCDIC37(data, bytes, 0); return this; }
    public synchronized String readEBCDIC37(int bytes)
        throws IOException
    {
        byte[] data = new byte[bytes];
        readEBCDIC37(data, bytes, 0);
        return new String(data);
    }

    /// write a bin(4)
    public synchronized ByteArray writeInt32(int v)
        throws IOException
    {
        if(should_extend(4))
            extend(4);

        // using either `>>>' or `>>' the result is the same
        arr_[pos_] = (byte)(v >>> 24);
        arr_[pos_ + 1] = (byte)(v >>> 16);
        arr_[pos_ + 2] = (byte)(v >>> 8);
        arr_[pos_ + 3] = (byte)(v);

        pos_ += 4;
        len_ = (len_ >= pos_) ? len_ : pos_;
        return this;
    }

    /// read a bin(4)
    public synchronized ByteArray readInt32(int[] v)
        throws IOException
    {
        if((pos_ + 4 - 1) > len_)
            throw new IOException("No enough data left.");

        v[0] = arr_[pos_ + 3] & 0x000000FF;
        v[0] |= (arr_[pos_ + 2] << 8) & 0x0000FF00;
        v[0] |= (arr_[pos_ + 1] << 16) & 0x00FF0000;
        v[0] |= (arr_[pos_] << 24) & 0xFF000000;

        pos_ += 4;
        return this;
    }
    /// read a bin(4)
    public synchronized int readInt32()
        throws IOException
    {
        int[] r = {0};
        readInt32(r);

        return r[0];
    }

    /// write a bin(2)
    public synchronized ByteArray writeInt16(int v)
        throws IOException
    {
        if(should_extend(2))
            extend(2);

        // using either `>>>' or `>>' the result is the same
        arr_[pos_] = (byte)(v >>> 8);
        arr_[pos_ + 1] = (byte)(v);

        pos_ += 2;
        len_ = (len_ >= pos_) ? len_ : pos_;
        return this;
    }

    /// read a bin(2)
    public synchronized ByteArray readInt16(int[] v)
        throws IOException
    {
        if((pos_ + 2 - 1) > len_)
            throw new IOException("No enough data left.");

        v[0] = arr_[pos_ + 1] & 0x000000FF;
        v[0] |= (arr_[pos_] << 8) & 0x0000FF00;

        pos_ += 2;
        return this;
    }
    /// read a bin(2)
    public synchronized int readInt16()
        throws IOException
    {
        int[] r = {0};
        readInt16(r);

        return r[0];
    }

    /// @todo read/writeInt32(), Int16, float, double, pkd
    /// znd, ebcdic37

    /// toBytes(), fromBytes()
    public synchronized void fromBytes(byte[] data, int bytes, int off)
        throws IOException
    {
        // clear ...
        clear();

        arr_ = new byte[bytes];
        writeBytes(data, bytes, off);
        pos_ = 0;
    }
    public synchronized void fromBytes(byte[] data, int bytes)
        throws IOException
    { fromBytes(data, bytes, 0); }
    public synchronized void fromBytes(byte[] data)
        throws IOException
    { fromBytes(data, data.length, 0); }

    public synchronized byte[] toBytes() {

        byte[] copy = new byte[len_];
        for(int i = 0; i < len_; i++)
            copy[i] = arr_[i];

        return copy;
    }

    public static ByteArray load(byte[] data, int bytes, int off)
        throws IOException
    {
        ByteArray r = new ByteArray(bytes);
        r.writeBytes(data, bytes, off);
        r.pos_ = 0;

        return r;
    }
    public static ByteArray load(byte[] data, int bytes)
        throws IOException
    { return load(data, bytes, 0); }
    public static ByteArray load(byte[] data)
        throws IOException
    { return load(data, data.length, 0); }

    /// @todo is it proper to add some conversion functionalities to this class

    public static byte[] fromInt32(int val)
        throws IOException
    {

        ByteArray b = new ByteArray(4);
        b.writeInt32(val);
        b.pos_ = 0;

        return b.toBytes();
    }

    /// Content of *TBL QSYS/QEBCDIC
    public static final int[] _qebcdic = {
        0x00, 0x01, 0x02, 0x03, 0x37, 0x2D, 0x2E, 0x2F, 
        0x16, 0x05, 0x25, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 
        0x10, 0x11, 0x12, 0x13, 0x3C, 0x3D, 0x32, 0x26, 
        0x18, 0x19, 0x3F, 0x27, 0x1C, 0x1D, 0x1E, 0x1F, 
        0x40, 0x4F, 0x7F, 0x7B, 0x5B, 0x6C, 0x50, 0x7D, 
        0x4D, 0x5D, 0x5C, 0x4E, 0x6B, 0x60, 0x4B, 0x61, 
        0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 
        0xF8, 0xF9, 0x7A, 0x5E, 0x4C, 0x7E, 0x6E, 0x6F, 
        0x7C, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 
        0xC8, 0xC9, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 
        0xD7, 0xD8, 0xD9, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 
        0xE7, 0xE8, 0xE9, 0x4A, 0xE0, 0x5A, 0x5F, 0x6D, 
        0x79, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 
        0x88, 0x89, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 
        0x97, 0x98, 0x99, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 
        0xA7, 0xA8, 0xA9, 0xC0, 0x6A, 0xD0, 0xA1, 0x07, 
        0x20, 0x21, 0x22, 0x23, 0x24, 0x15, 0x06, 0x17, 
        0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x09, 0x0A, 0x1B, 
        0x30, 0x31, 0x1A, 0x33, 0x34, 0x35, 0x36, 0x08, 
        0x38, 0x39, 0x3A, 0x3B, 0x04, 0x14, 0x3E, 0xE1, 
        0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 
        0x49, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 
        0x58, 0x59, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 
        0x68, 0x69, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 
        0x76, 0x77, 0x78, 0x80, 0x8A, 0x8B, 0x8C, 0x8D, 
        0x8E, 0x8F, 0x90, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 
        0x9F, 0xA0, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF, 
        0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 
        0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF, 
        0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF, 0xDA, 0xDB, 
        0xDC, 0xDD, 0xDE, 0xDF, 0xEA, 0xEB, 0xEC, 0xED, 
        0xEE, 0xEF, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF
    };

    /// Content of *TBL QSYS/QASCII
    public static final int[] _qascii = {
        0x00, 0x01, 0x02, 0x03, 0x9C, 0x09, 0x86, 0x7F,
        0x97, 0x8D, 0x8E, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
        0x10, 0x11, 0x12, 0x13, 0x9D, 0x85, 0x08, 0x87,
        0x18, 0x19, 0x92, 0x8F, 0x1C, 0x1D, 0x1E, 0x1F,
        0x80, 0x81, 0x82, 0x83, 0x84, 0x0A, 0x17, 0x1B,
        0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x05, 0x06, 0x07,
        0x90, 0x91, 0x16, 0x93, 0x94, 0x95, 0x96, 0x04,
        0x98, 0x99, 0x9A, 0x9B, 0x14, 0x15, 0x9E, 0x1A,
        0x20, 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6,
        0xA7, 0xA8, 0x5B, 0x2E, 0x3C, 0x28, 0x2B, 0x21,
        0x26, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF,
        0xB0, 0xB1, 0x5D, 0x24, 0x2A, 0x29, 0x3B, 0x5E,
        0x2D, 0x2F, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7,
        0xB8, 0xB9, 0x7C, 0x2C, 0x25, 0x5F, 0x3E, 0x3F,
        0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF, 0xC0, 0xC1,
        0xC2, 0x60, 0x3A, 0x23, 0x40, 0x27, 0x3D, 0x22,
        0xC3, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
        0x68, 0x69, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9,
        0xCA, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70,
        0x71, 0x72, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF, 0xD0,
        0xD1, 0x7E, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
        0x79, 0x7A, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7,
        0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF,
        0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7,
        0x7B, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
        0x48, 0x49, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED,
        0x7D, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50,
        0x51, 0x52, 0xEE, 0xEF, 0xF0, 0xF1, 0xF2, 0xF3,
        0x5C, 0x9F, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
        0x59, 0x5A, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9,
        0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
        0x38, 0x39, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF
    };

}
