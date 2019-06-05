#!/bin/bash

library=libkeyutils.so.1
LIBLOC=$(whereis ${library} | cut -d":" -f2 | tr -d " ")

if [ ! "${LIBLOC}" = "" ]; then
  output=$(objdump -x "${LIBLOC}" | grep NEEDED)
  
  lines=$(wc -l <<< "${output}" | cut -d" " -f 1)
  
  if [ ${lines} -gt 1 ]; then
    printf "You probably have a problem, more than one NEEDED symbol is present\n> %s\n" "${output}"
  else
    printf "You seem to be ok\n"
  fi
else
  printf "Can't locate ${library}, sorry...\n"
fi
