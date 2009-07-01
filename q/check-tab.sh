#! /bin/sh

#
# @file check-tab.sh
#
# @param source_files to check
#

for file in $*
  do
  sed -s 's/\t/\"制表符\"/' $file | grep -n 制表符;
  if [ $? -eq 0 ]
      then
      printf "====> 制表符 found in source file '$file', replace them by white spaces?(y,n): "
      read reply
      if [ $reply == "y" ] || [ $reply == "Y" ]
          then
          sed -si 's/\t/        /' $file
      fi
  fi

done
