#!/usr/bin/env bash
# This file contains useful functions that are often used for controlling
# purposes of execution purposes.

source "${SCRIPTS_LIB_DIR}/string.sh"

###############################################################################

# returns true when the script is sourced; false - when not
isSourced() {
	local len=${#BASH_SOURCE[@]}
	test "${0}" != "${BASH_SOURCE[${len}-1]}"
	return $?
}

###############################################################################

# returns true when the script is executed; false - when not
isExecuted() {
	isSourced && return 1 || return 0
}

###############################################################################

# returns true when all the binaries given in parameter list are installed;
# false - when not (number of missed utilities) & prints list of missing
# executable files to stderr in this case.
isInstalled() {
	local missed=();
	while [ $# -gt 0 ]; do
		local utility="${1}";
		which "${utility}" &>/dev/null || missed+=("${utility}")
		shift 1;
	done
	[[ ${#missed[@]} -eq 0 ]] || {
		printf "Following utilities are not available in \$PATH:\n" >&2;
		printf "\t'%s'\n" ${missed[@]} >&2;
	}
	return ${#missed[@]};
}

###############################################################################

# returns true when the given command was executed with success
# and number of retries has not been exceeded;
# returns error code of last execution when command failed
# and number of retries exceeded.
function executeWithRetries() {
	local -r expected_num_of_arguments="2";
	[[ $# -ge "${expected_num_of_arguments}" ]] || {
		printf "Not enough arguments provided!\n" >&2;
		printf "Please provide at least [%s] arguments!\n" "${expected_num_of_arguments}" >&2;
		return 1;
	}

	local -r retries="${1}";
	local -r command="${2}";

	local -i counter=0;
	while [ ${counter} -lt ${retries} ]; do
		${command} || {
			counter=$[$counter+1];
			sleep 1;
		} && {
			break;
		}
	done
}

###############################################################################

die() {
	[[ $# -gt 0 ]] && printf "$*\n"
	printStackTraceFormatted >&2
	exit 1
}

###############################################################################

printStackTrace() {
	# prints stack trace using 'caller' builtin directly
	local frame=0
	while caller ${frame}; do
		((frame++))
	done
}

###############################################################################

printStackTraceFormatted() {
	# prints stack trace in format FILE --> FUNCTION --> LINE
	local separator="${1:- --> }"

	mapfile <<< "$(printStackTrace)"
	for i in "${MAPFILE[@]}"; do
		IFS=' ' set -- ${i}
		local lines[${#lines[@]}]="${1}";
		local funcs[${#funcs[@]}]="${2}";
		local files[${#files[@]}]="${3}";
	done

	getLengthMax ${files[@]}
	local len_files=$?
	getLengthMax ${lines[@]}
	local len_lines=$?
	getLengthMax ${funcs[@]}
	local len_funcs=$?

	printf "%-${len_files}s${separator}%-${len_funcs}s${separator}%${len_lines}s\n" "FILE" "FUNCTION" "LINE"
	for (( i=0; i<${#files[@]}; i++ )); do
		printf "%-${len_files}s${separator}%-${len_funcs}s${separator}%${len_lines}d\n" \
			"${files[$i]}" "${funcs[$i]}" "${lines[$i]}"
		done
	}

###############################################################################
