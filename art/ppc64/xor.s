	#
        # @file xor.s
	#
        # e.g. 2^35 XOR (2^35+1)
        #  > n=$(./xor 34359738368 34359738369); echo $n
        #    1
        #  > echo $(./xor 1 3)
        #    2
        # Demo of XOR swap algorithm
        #  > a=8; b=1; echo $a $b
        #    8 1
        #    $
        #  > echo $(xor $a $(xor $a $b)) $(xor $b $(xor $b $a))
        #    1 8
        #    $
        # or
        #  > a=8; b=1; echo $a $b
        #    8 1
        #    $
        #  > a=$(xor $a $b); b=$(xor $a $b); a=$(xor $a $b); echo $a $b
        #    1 8
        #    $
        #

	.file   "xor.s"

	.extern .exit[pr]       # [1] libc routines to use
        .extern .atoll[pr]
        .extern .printf[pr]

        .toc                    # [2] TOC
T.tc.main:
        .tc     .main[tc],      .main[pr]       # [3] TOC entries
tc.fmt: .tc     tc.fmt[tc],     fmt_str[rw]

        .globl  .main[pr]       # [4]
        .csect  .main[pr]
main:
        # [5] Save input arguments: argv[1], argv[2]
        ld      28, 0x8(4)      # load addr of argv[1] to r28
                                # r28 = *(r4 + 8)
        ld      29, 0x10(4)     # r29 = *(r4 + 16)

        # [6] Convert argv[1] to integer
        addi    3, 28, 0
        bl      .atoll[pr]
        cror    31, 31, 31
        addi    27, 3, 0        # Store the return value in r27

        # Convert argv[2] to integer
        addi    3, 29, 0
        bl      .atoll[pr]
        cror    31,31,31

        # [7] XOR
        xor     27, 3, 27       # Save XOR result in r27

        # [8] Print XOR result
        ld      3, tc.fmt(2)    # Load addr of fmt_str to r3 via TOC
        addi    4, 27, 0
        bl      .printf[pr]
        cror    31, 31, 31

        # [9] Exit
        addi    3,0,0
        bl      .exit[pr]
        cror    31, 31, 31

        .csect  fmt_str[rw],3
fmt:    .byte   "%lld"          # Format string for XOR result
        .byte   0xa, 0x0        # NewLine, nil
