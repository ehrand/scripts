#! /bin/bash

source "${SCRIPTS_LIB}/network.sh"

###############################################################################

usage() {
	cat << EOF
NAME:
	$(basename "${0}") - restore data

SYNOPSIS:
	$(basename "${0}") [OPTIONS]

DESCRIPTION:
	This script will restore data from following directories:

	The OPTIONS are as follows:

	-h	Print this help an exit.
	-b	Restore directory "[${storage[eBooks]}]"
		into "[${PWD}]"
	-w	Restore directory "[${storage[walls]}]"
		into "[${PWD}]"
EOF
}

###############################################################################

declare -A storage=""
storage["eBooks"]="an3@nasbox.fritz.box:/home/an3/backup/docs/eBooks"
storage["walls"]="an3@nasbox.fritz.box:/home/an3/backup/pics/walls"

###############################################################################

doRestoreBooks() {
	doRsync \
		-u "an3" \
		-s "${storage[eBooks]}" \
		-d "${PWD}"
}

###############################################################################

doRestoreWalls() {
	doRsync \
		-u "an3" \
		-s "${storage[walls]}" \
		-d "${PWD}"
}

###############################################################################

isSourced && {
	printf "This script is aimed to be executed!\n";
	return 1;
}

while getopts hbw arg; do
	case "${arg}" in
		h) _doUsage="true";;
		b) _doResoreBooks="true";;
		w) _doResoreWalls="true";;
		*) usage && exit 1;;
	esac
done

[[ -z "${_doUsage}" ]] || {
	usage
	exit 0;
}

[[ -z "${_doResoreBooks}" ]] || doRestoreBooks;
[[ -z "${_doResoreWalls}" ]] || doRestoreWalls;

###############################################################################

