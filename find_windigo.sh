#!/bin/bash

#####################################################
## Written by Eric Johnfelt @ Stony Brook University
#####################################################
## Copyright 6/2019 - No Warranty or Fitness Implied
#####################################################
## Use at your own risk, do not assume validation
## without further testing.
#####################################################

declare -a valid
declare -a libs
# Future Expansion Currently Unused
declare -a liblist

DEBUGMODE=no
# Library to check as a stand-in during debugmode
testlib="libcheese.so.8"

# Title for this iteration of the script
title="windigo"
# Library this iteration of the script is looking for
library="libkeyutils.so.1"
LIBLOC=""

# Future Expansion, currently unused
listfile=""

valid=( lib.so.6 libdl.so.2 )

# Usage Text
function Usage()
{
	echo -e "**********************************************************"
	echo -e "* find_${title} : Script to detect ${title} IOC/Infection"
	echo -e "**********************************************************"
	echo -e "\n-h\tThis message\"
	echo -e "-l [name of library to hunt for] (optional)"
	# echo -e "-f [file]\tread libraries names from file [format: library.name comma-seperated-list-of-valid-symbols]"
}

# Print Debug Messsages
function DebugMsg()
{
	if [ "${DEBUGMODE}" = "yes" ]; then
		printf "$(date) : %s\n" "${*}"
	fi
}

# IsValid : Determine if supplied library name is in the list of valid included symbols in library we are searching thorugh
function IsValid()
{
	for ((item=0; item < ${#valid[@]}; ++item)); do
		if [ "${1}" = "${valid[${item}]}" ]; then
			return 0
		fi
	done

	return 1
}

#
# Main Loop
#

# Process cmdline args
while getopts "hf:l:d" OPT; do
	case "${OPT}" in
	"h")	Usage; exit 0 ;;
	"l")	library="${OPTARG}" ;;
	"f")	listfile="${OPTARG}" ;;				# Future expansion, currently unused
	"d")	DEBUGMODE=yes; library="${testlib}" ;;
	esac
done

LIBLOC=$(whereis ${library} | cut -d":" -f2 | tr -d " ")

if [ ! "${LIBLOC}" = "" ]; then
	printf "Checking %s at %s\n" "${library}" "${LIBLOC}"

	foundInvalid=0

	mapfile -t libs <<< $(objdump -x "${LIBLOC}" | tr -s " " | grep "NEEDED" | cut -d" " -f3 | tr -d " ")

	for ((index=0; index < ${#libs[@]}; ++index)); do
		if ! IsValid "${libs[${index}]}"; then
			foundInvalid=1
			printf "Symbol %s is *NOT* in the approved list\n" "${libs[${index}]}"
		fi
	done

	if [ ${foundInvalid} -gt 0 ]; then
		printf "*** Some unexpected symbols were found, you might have a problem\n"
	else
    		printf "You seem to be ok\n"
	fi
else
  printf "Can't locate ${library}, sorry...\n"
fi
