#!/bin/bash

library=libkeyutils.so.1
LIBLOC=""

# Usage Text
function Usage()
{
  echo -e "********************************************************"
  echo -e "* find_windigo : Script to detect windigo IOC/Infection
  echo -e "********************************************************"
  echo -e "\n-h\tThis message\"
  echo -e "-f [name of library to hunt for] (optional)"
}

#
# Main Loop
#

while getopts "hf:" OPT; do
  case "${OPT}" in
  "h")  Usage; exit 0 ;;
  "f")  library="${OPTARG}" ;;
  esac
done

LIBLOC=$(whereis ${library} | cut -d":" -f2 | tr -d " ")

if [ ! "${LIBLOC}" = "" ]; then
  output=$(objdump -x "${LIBLOC}" | grep NEEDED)
  
  lines=$(wc -l <<< "${output}" | cut -d" " -f 1)
  
  if [ ${lines} -gt 1 ]; then
    printf "You probably have a problem, more than one NEEDED symbol is present\n %s\n" "${output}"
  else
    printf "You seem to be ok\n"
  fi
else
  printf "Can't locate ${library}, sorry...\n"
fi
