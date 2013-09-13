/********************************************************************/
/*  PROGRAM  - PRTBUILTIN                                           */
/*  FUNCTION - print the ILE built-in functions, V5R3-specific      */
/*  LANGUAGE - REXX                                                 */
/*  AUTHOR   - Gene Gaunt                                           */
/********************************************************************/

"crtsavf file(qtemp/stdin)"
"savobj  obj(qwxcrtmd) ",
        "lib(qsys) ",
        "objtype(*pgm) ",
        "dev(*savf) ",
        "savf(qtemp/stdin) ",
        "updhst(*no) ",
        "dtacpr(*no)"
"ovrdbf  file(stdin) ",
        "tofile(qtemp/stdin)"
"ovrprtf file(stdout) ",
        "tofile(qsysprt) ",
        "splfname(prtbuiltin)"
data = ''
do forever
   parse linein record
   if record == '' then leave
   data = data || left( record, 512 )
end
walk = c2d( substr( data, X(  75 ),        3 ))
walk = c2d( substr( data, X(  1D ) + walk, 3 ))
walk = c2d( substr( data, X(  75 ) + walk, 3 ))
walk = c2d( substr( data, X(  45 ) + walk, 3 ))
walk = c2d( substr( data, X( 665 ) + walk, 3 )) + X( 0 )
name = walk + x2d( 22A0 )
code = walk + x2d( 3980 )
do while walk < name
   AA = c2d( substr( data, walk,      4 ))
   BB = c2d( substr( data, walk +  4, 2 ))
   CC = c2d( substr( data, walk +  6, 2 ))
   DD = c2d( substr( data, walk +  8, 2 ))
   EE = c2d( substr( data, walk + 10, 2 ))
   if BB == 0 then leave
   show = left( substr( data, name + AA, BB ), 20 )
   do DD while EE == 0
      show = show ||,
             right( c2d( substr( data, code + CC * 4, 4 )), 6 )
      CC = CC + 1
   end
   say show
   walk = walk + 12
end
return
X: return x2d( 5001 ) + x2d( arg( 1 ))
