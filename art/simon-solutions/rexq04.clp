/** @file rexq04.clp                */
/** Test of rexq02.rpgle            */

dcl &line *char 16
dcl &len  *dec  len(11 0) value(16)
dcl &msglen *dec len(11 0)
dcl &num  *dec  len(11 0)

       rtvrexqln &num
pull:  if cond(&num *eq 0) then(goto end)
       call REXQ02 (&line &len &msglen)
       sndpgmmsg &line
       chgvar &line ' '
       rtvrexqln &num
       goto pull

end:   endpgm
