/**
 * @file DES.as
 *
 * @todo 把 encode() 以外的 methods 改为 private
 */

package as400.prototype {

    import flash.utils.*; // ByteArray

    public class DES {

        public function encode_des(dta:ByteArray,
                                   key:ByteArray)
            : ByteArray {

            var encDta:ByteArray = new ByteArray();

            var key_exp:Vector.<int> = expand8byte(key);
            var dta_exp:Vector.<int> = expand8byte(dta);

            // reduce the key to 56 bits by discarding each 8th bit (parity bit)
            var key56:Vector.<int> = new Vector.<int>(56);
            for(var i:int = 0; i < 56; i++)
                key56[i] = key_exp[PC1[i] - 1];       // via permution PC1
            var C:Vector.<int> = key56.splice(0, 28); // left half of key56
            var D:Vector.<int> = key56.splice(0, 28); // right half of key56

            // perform initial permutation on the data block
            var dta64:Vector.<int> = new Vector.<int>(64);
            for(i = 0; i < 64; i++)
                dta64[i] = dta_exp[IP[i] - 1];        // via permution IP
            var L:Vector.<int> = dta64.splice(0, 32); // left half of 64-bit data
            var R:Vector.<int> = dta64.splice(0, 32); // right half of 64-bit data

            var K:Vector.<int> = new Vector.<int>(48);
            var shifts:Vector.<int> = new <int>[1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1];
            for(i = 0; i < 16; i++) {
                // do circular left-shift(s) on C[i-1], D[i-1] to generate C[i], D[i]
                C.push(C.shift());
                if(shifts[i] > 1)
                    C.push(C.shift());
                D.push(D.shift());
                if(shifts[i] > 1)
                    D.push(D.shift());

                // concatenate C[i]D[i] go generate K[i]
                var CD:Vector.<int> = C.concat(D);
                for(var j:int = 0; j < 48; j++)
                    K[j] = CD[PC2[j] - 1];  // yield K by permute C[i]D[i] by PC2
                                        // via permution PC2

                // expand 32-bit R[i-1] to 48 bits with EXP[48]
                var E:Vector.<int> = new Vector.<int>(48);
                for(j = 0; j < 48; j++)
                    E[j] = R[EXP[j] - 1];  // via permution EXP

                // Exclusive-or E(R[i-1]) with K[i].
                for(j = 0; j < 48; j++)
                    E[j] ^= K[j];

                // @see NOTE.A --- B
                // Break E(R[i-1]) xor K[i] into eight 6-bit blocks. Bits 1-6 are
                // B[1], bits 7-12 are B[2], and so on with bits 43-48 being B[8].
                var B:Vector.<int> = new Vector.<int>(8);
                for(j = 0; j < 8; j++)
                    B[j] = getBits162345(E.splice(0, 6));

                // Replace B[j] with S[j][m][n].
                for(j = 0; j < 8; j++)
                    B[j] = S[j][B[j]];

                // Concatenate B[1] through B[8] into a 32-bit value,
                // B[j] is treated as a 4-bit value
                var B8:Vector.<int> = new Vector.<int>();
                for(j = 0; j < 8; j++)
                    B8 = B8.concat(expand4bit(B[j]));

                // Permute the concatenation of B[1] through B[8]
                var BP:Vector.<int> = new Vector.<int>(32);
                for(j = 0; j < 32; j++)
                    BP[j] = B8[PP[j] - 1];  // via permution PP

                // Save R[i-1]
                var R_save:Vector.<int> = R.slice(0);

                // R[i] = L[i-1] xor P(S[1](B[1])...S[8](B[8])), aka. R[i] = L[i-1] xor BP
                for(j = 0; j < 32; j++)
                    R[j] = L[j] ^ BP[j];

                // L[i] = R[i-1].
                L = R_save.slice(0);
            }

            // Perform the final permutation on the block R[16]L[16]
            var RL:Vector.<int> = R.concat(L);
            for(i = 0; i < 64; i++)
                dta64[i] = RL[FP[i] - 1];  // via permution FP

            // compress encrypted data back to 64 bits
            encDta = compress8byte(dta64);

            encDta.position = 0;
            return encDta;
        }

        /// expand a 4-bit value. e.g. expand4bit(0x0C) = [1, 1, 0, 0];
        public function expand4bit(i:int) : Vector.<int> {

            var r:Vector.<int> = new Vector.<int>(4);
            r[0] = (i & 0x08) ? 1 : 0;
            r[1] = (i & 0x04) ? 1 : 0;
            r[2] = (i & 0x02) ? 1 : 0;
            r[3] = (i & 0x01) ? 1 : 0;

            return r;
        }

        /// generate an integer using vec's bits 1, 6, 2, 3, 4, 5
        public function getBits162345(vec:Vector.<int>) : int {
            var r:int = 0;
            r |= (vec[0] > 0) ? 0x20 : 0x00;
            r |= (vec[5] > 0) ? 0x10 : 0x00;
            r |= (vec[1] > 0) ? 0x08 : 0x00;
            r |= (vec[2] > 0) ? 0x04 : 0x00;
            r |= (vec[3] > 0) ? 0x02 : 0x00;
            r |= (vec[4] > 0) ? 0x01 : 0x00;

            return r;
        }

        // expand 64-bit data to int[64]
        public function expand8byte(b64:ByteArray) : Vector.<int> {

            var r:Vector.<int> = new Vector.<int>(64, true); // fixed-length
            b64.position = 0;
            for(var i:int = 0; i < 8; i++) {
                var BYTE:int = b64.readByte();
                r[i * 8]     = (BYTE & 0x80) ? 1 : 0;
                r[i * 8 + 1] = (BYTE & 0x40) ? 1 : 0;
                r[i * 8 + 2] = (BYTE & 0x20) ? 1 : 0;
                r[i * 8 + 3] = (BYTE & 0x10) ? 1 : 0;
                r[i * 8 + 4] = (BYTE & 0x08) ? 1 : 0;
                r[i * 8 + 5] = (BYTE & 0x04) ? 1 : 0;
                r[i * 8 + 6] = (BYTE & 0x02) ? 1 : 0;
                r[i * 8 + 7] = (BYTE & 0x01) ? 1 : 0;
            }

            b64.position = 0;
            return r;
        }

        // compress int[64] back to 64-bit data
        public function compress8byte(i64:Vector.<int>) : ByteArray {

            var b64:ByteArray = new ByteArray();
            var c:int = 0; // char(1)
            for(var i:int = 0; i < 8; i++) {

                c = 0;
                if(i64[i * 8] > 0)     c |= 0x80;
                if(i64[i * 8 + 1] > 0) c |= 0x40;
                if(i64[i * 8 + 2] > 0) c |= 0x20;
                if(i64[i * 8 + 3] > 0) c |= 0x10;
                if(i64[i * 8 + 4] > 0) c |= 0x08;
                if(i64[i * 8 + 5] > 0) c |= 0x04;
                if(i64[i * 8 + 6] > 0) c |= 0x02;
                if(i64[i * 8 + 7] > 0) c |= 0x01;

                b64.writeByte(c);
            }

            b64.position = 0;
            return b64;
        }

        // properties of DES

        // @remark Note that when being used as array subcript, each
        //         value in a each permution mean a subscript start
        //         from 1, not 0.

        // PC1, int[56]
        private static var PC1:Vector.<int> =
            new <int>[57, 49, 41, 33, 25, 17,  9,
                      1, 58, 50, 42, 34, 26, 18,
                      10,  2, 59, 51, 43, 35, 27,
                      19, 11,  3, 60, 52, 44, 36,
                      63, 55, 47, 39, 31, 23, 15,
                      7, 62, 54, 46, 38, 30, 22,
                      14,  6, 61, 53, 45, 37, 29,
                      21, 13,  5, 28, 20, 12,  4];

        // PC2, int[48]
        private static var PC2:Vector.<int>
            = new <int>[14, 17, 11, 24,  1,  5,
                        3, 28, 15,  6, 21, 10,
                        23, 19, 12,  4, 26,  8,
                        16, 7,  27, 20, 13,  2,
                        41, 52, 31, 37, 47, 55,
                        30, 40, 51, 45, 33, 48,
                        44, 49, 39, 56, 34, 53,
                        46, 42, 50, 36, 29, 32];

        // Initial Permutation (IP)
        private static var IP:Vector.<int>
            = new <int>[58, 50, 42, 34, 26, 18, 10, 2,
                        60, 52, 44, 36, 28, 20, 12, 4,
                        62, 54, 46, 38, 30, 22, 14, 6,
                        64, 56, 48, 40, 32, 24, 16, 8,
                        57, 49, 41, 33, 25, 17,  9, 1,
                        59, 51, 43, 35, 27, 19, 11, 3,
                        61, 53, 45, 37, 29, 21, 13, 5,
                        63, 55, 47, 39, 31, 23, 15, 7];

        // Expansion (E)
        private static var EXP:Vector.<int>
            = new <int>[32,  1,  2,  3,  4,  5,
                        4,  5,  6,  7,  8,  9,
                        8,  9, 10, 11, 12, 13,
                        12, 13, 14, 15, 16, 17,
                        16, 17, 18, 19, 20, 21,
                        20, 21, 22, 23, 24, 25,
                        24, 25, 26, 27, 28, 29,
                        28, 29, 30, 31, 32,  1];

        // S boxes
        private static var S:Vector.<Vector.<int>>
            = new <Vector.<int>>[ new <int>[14,  4, 13,  1,  2, 15, 11,  8,  3, 10,  6, 12,  5,  9,  0,  7,
                                            0, 15,  7,  4, 14,  2, 13,  1, 10,  6, 12, 11,  9,  5,  3,  8,
                                            4,  1, 14,  8, 13,  6,  2, 11, 15, 12,  9,  7,  3, 10,  5,  0,
                                            15, 12,  8,  2,  4,  9,  1,  7,  5, 11,  3, 14, 10,  0,  6, 13],
                                  new <int>[15,  1,  8, 14,  6, 11,  3,  4,  9,  7,  2, 13, 12,  0,  5, 10,
                                            3, 13,  4,  7, 15,  2,  8, 14, 12,  0,  1, 10,  6,  9, 11,  5,
                                            0, 14,  7, 11, 10,  4, 13,  1,  5,  8, 12,  6,  9,  3,  2, 15,
                                            13,  8, 10,  1,  3, 15,  4,  2, 11,  6,  7, 12,  0,  5, 14,  9],
                                  new <int>[10,  0,  9, 14,  6,  3, 15,  5,  1, 13, 12,  7, 11,  4,  2,  8,
                                            13,  7,  0,  9,  3,  4,  6, 10,  2,  8,  5, 14, 12, 11, 15,  1,
                                            13,  6,  4,  9,  8, 15,  3,  0, 11,  1,  2, 12,  5, 10, 14,  7,
                                            1, 10, 13,  0,  6,  9,  8,  7,  4, 15, 14,  3, 11,  5,  2, 12],
                                  new <int>[7, 13, 14,  3,  0,  6,  9, 10,  1,  2,  8,  5, 11, 12,  4, 15,
                                            13,  8, 11,  5,  6, 15,  0,  3,  4,  7,  2, 12,  1, 10, 14,  9,
                                            10,  6,  9,  0, 12, 11,  7, 13, 15,  1,  3, 14,  5,  2,  8,  4,
                                            3, 15,  0,  6, 10,  1, 13,  8,  9,  4,  5, 11, 12,  7,  2, 14],
                                  new <int>[2, 12,  4,  1,  7, 10, 11,  6,  8,  5,  3, 15, 13,  0, 14,  9,
                                            14, 11,  2, 12,  4,  7, 13,  1,  5,  0, 15, 10,  3,  9,  8,  6,
                                            4,  2,  1, 11, 10, 13,  7,  8, 15,  9, 12,  5,  6,  3,  0, 14,
                                            11,  8, 12,  7,  1, 14,  2, 13,  6, 15,  0,  9, 10,  4,  5,  3],
                                  new <int>[12,  1, 10, 15,  9,  2,  6,  8,  0, 13,  3,  4, 14,  7,  5, 11,
                                            10, 15,  4,  2,  7, 12,  9,  5,  6,  1, 13, 14,  0, 11,  3,  8,
                                            9, 14, 15,  5,  2,  8, 12,  3,  7,  0,  4, 10,  1, 13, 11,  6,
                                            4,  3,  2, 12,  9,  5, 15, 10, 11, 14,  1,  7,  6,  0,  8, 13],
                                  new <int>[4, 11,  2, 14, 15,  0,  8, 13,  3, 12,  9,  7,  5, 10,  6,  1,
                                            13,  0, 11,  7,  4,  9,  1, 10, 14,  3,  5, 12,  2, 15,  8,  6,
                                            1,  4, 11, 13, 12,  3,  7, 14, 10, 15,  6,  8,  0,  5,  9,  2,
                                            6, 11, 13,  8,  1,  4, 10,  7,  9,  5,  0, 15, 14,  2,  3, 12],
                                  new <int>[13,  2,  8,  4,  6, 15, 11,  1, 10,  9,  3, 14,  5,  0, 12,  7,
                                            1, 15, 13,  8, 10,  3,  7,  4, 12,  5,  6, 11,  0, 14,  9,  2,
                                            7, 11,  4,  1,  9, 12, 14,  2,  0,  6, 10, 13, 15,  3,  5,  8,
                                            2,  1, 14,  7,  4, 10,  8, 13, 15, 12,  9,  0,  3,  5,  6, 11]
                                  ];

        // Permutation P that is used to permute the concatenation of B[1] through B[8] (32-bit)
        static private var PP:Vector.<int>
            = new <int>[16,  7, 20, 21,
                        29, 12, 28, 17,
                        1, 15, 23, 26,
                        5, 18, 31, 10,
                        2,  8, 24, 14,
                        32, 27,  3,  9,
                        19, 13, 30,  6,
                        22, 11,  4, 25];

        // Final Permutation
        static private var FP:Vector.<int>
            = new <int>[40, 8, 48, 16, 56, 24, 64, 32,
                        39, 7, 47, 15, 55, 23, 63, 31,
                        38, 6, 46, 14, 54, 22, 62, 30,
                        37, 5, 45, 13, 53, 21, 61, 29,
                        36, 4, 44, 12, 52, 20, 60, 28,
                        35, 3, 43, 11, 51, 19, 59, 27,
                        34, 2, 42, 10, 50, 18, 58, 26,
                        33, 1, 41,  9, 49, 17, 57, 25];

    } // class DES

} // package
