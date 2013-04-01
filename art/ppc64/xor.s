	#
        # @file xor.s
	#
        # e.g.
        #  > n=$(./xor 1 9); echo $n
        #    8
        # @todo 查一下 aix libc's atol(), atoll(), 有区别吗?
        #

	.file   "xor.s"

	.extern .exit[pr]
        .extern .atol[pr]
        .extern .printf[pr]

        .toc            # TOC
T.tc.main:
        .tc     .main[tc],      .main[pr]
tc.fmt: .tc     tc.fmt[tc],     fmt_str[ro]

        .globl  .main[pr]
        .csect  .main[pr]
.main:
        # Save argv[1], argv[2]
        ld      28, 0x8(4)      # load addr of argv[1] to r3
                                # r28 = *(r4 + 8)
        ld      29, 0x10(4)     # r29 = *(r4 + 16)

        # Convert argv[1] to integer
        addi    3, 28, 0
        bl      .atol[pr]
        cror    31,31,31        # Check return value of atoll() in $r3

        # Store the return value in r27
        addi    27, 3, 0

        # Convert argv[2] to integer
        addi    3, 29, 0
        bl      .atol[pr]       # atol() use r12
        cror    31,31,31

        # XOR
        xor     27, 3, 27       # Save XOR result in r27

        # Output
        ld      3, tc.fmt(2)
        addi    4, 27, 0
        bl      .printf[pr]
        cror    31, 31, 31

        # exit
        addi    3,0,0
        bl      .exit[pr]
        cror    31, 31, 31

        .csect  fmt_str[ro],3
fmt:    .byte   "%d"
        .byte   0xa, 0x0
