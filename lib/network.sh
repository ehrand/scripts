#!/usr/bin/env bash
#
# This file contains functions that are often used to connect to other machines.
#
###############################################################################

set -e
set -u
set -x

###############################################################################

conn2ssh() {
	local -r pass_word="${1}";
	local -r user_name="${2:-${USER}}";
	local -r host_name="${3:-${HOSTNAME}}";

	which ssh &>/dev/null || return $?;

	if [[ -n "${pass_word}" ]]; then
		which sshpass &>/dev/null || \
			eval "ssh ${user_name}@${host_name}" && \
			eval "sshpass -p ${pass_word} ssh ${user_name}@${host_name}";
	else
		eval "ssh ${user_name}@${host_name}";
	fi
}

###############################################################################

doRsync() {

	for exe in rsync ssh; do
		which "${exe}" &>/dev/null || return $?;
	done

	local usr="";
	local src="";
	local dst="";

	while [[ $# -gt 0 ]]; do
		case "${1}" in
			-u) [[ -n "${2}" ]] && usr="${2}" && shift 1;;
			-s) [[ -n "${2}" ]] && src="${2}" && shift 1;;
			-d) [[ -n "${2}" ]] && dst="${2}" && shift 1;;
		esac
		shift 1
	done

	local cmd=("rsync");
	cmd+=("--rsh=\"$(which ssh) -l ${usr:?Please specify user name}\"");
	cmd+=("--verbose");			# be verbose during backup
	cmd+=("--recursive");		# copy directories recursively
	cmd+=("--delete-during");	# delete files in destination folder that are not available in source folder during backup
	cmd+=("--force");			# force deletion of directories even if they are not empty
	cmd+=("--times");			# preserve modification time stamps
	cmd+=("--timeout=60");		# if no data is transferred during timeout [seconds] then the rsync will exit
	cmd+=("--progress");		# show progress during backup is being performed
	cmd+=("--human-readable");	# show numbers in a more human readable format"
	cmd+=("${src:?Please specify source directory for backup}");
	cmd+=("${dst:?Please specify destination directory for backup}");

	eval "${cmd[@]}";
}

###############################################################################
